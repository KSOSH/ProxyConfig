unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.ComCtrls, Registry, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.Menus, Setting, StrUtils, System.Types, System.RegularExpressions,
  System.ImageList, Vcl.ImgList, SBPro, Vcl.XPMan, ShellAPI, ThreadUnit,
  System.IOUtils;

type
  TMainForm = class(TForm)
    GetWind: TTimer;
    BitBtn1: TBitBtn;
    TrayIcon1: TTrayIcon;
    RE_1: TRadioButton;
    RE_2: TRadioButton;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    PopupMenu2: TPopupMenu;
    N2: TMenuItem;
    Memo1: TListBox;
    ImageList1: TImageList;
    StatusBar1: TStatusBarPro;
    Timer1: TTimer;
    XPManifest1: TXPManifest;
    Grops: TGroupBox;
    N3: TMenuItem;
    N4: TMenuItem;
    Save: TSaveDialog;
    N5: TMenuItem;
    log1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure GetWindTimer(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure N4Click(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure TrayIcon1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    function GetCheckProxy():Integer;
    procedure ChangeApplicationVisibility;
    procedure ApplicationMinimize(Sender: TObject);
    function WinVerNum: integer;
    function ReadSetting: String;
    function SetProxy: String;
    procedure WMQueryEndSession(var Message: TWMQueryEndSession); message WM_QUERYENDSESSION;
    procedure OnEnabledTerminate( Sender: TObject );
    procedure OnDisabledTerminate( Sender: TObject );
  public
    { Public declarations }
    procedure LogApp(S: String; WR: Boolean);
  end;

const
  CurrentPath = 'Software\Microsoft\Windows\CurrentVersion\Internet Settings';
  SettingPath = 'Software\ProxyConfigApp';
  ProxyOverride = '*.localhost;*.school;*.localschool;*.hostname;<local>';
  ProxyVar = 'http=%ip:port%;https=%ip:port%';
  ProxyTestURL = 'https://sp-kolosok.minobr63.ru/proxy.txt';

var
  MainForm: TMainForm;
  i: integer;
  Vers: Boolean;
  Reg: TRegistry;
  RegSetting: TRegistry;
  MainCanClose: Boolean;
  RegIP: TRegEx;
  RegPort: TRegEx;
  Proxy: String;
  MyThread: ExecuteCMD;
  InitialDir: String;
  userDirectory: String;
  logerPath: String;

implementation

{$R *.dfm}


{*
  ** Функция Логирования
*}
procedure TMainForm.LogApp(S: String; WR: Boolean);
var
  f: TextFile;
  text: string;
begin
  text := FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' > ' + S;
  if Not WR then
    Memo1.Items.Add(text);
  SendMessage(Memo1.Handle,WM_VSCROLL,SB_BOTTOM,0);
  // Пишем в лог
  AssignFile(f, logerPath);
  If FileExists(logerPath) then
    Append(f)
  else
    rewrite(f);
  WriteLn(f, text);
  CloseFile(f);
end;

{*
  ** Функция чтения настроек программы
  ** Возвращает IP и Порт
*}
function TMainForm.ReadSetting: String;
var
  tProxy: String;
begin
  RegIP := TRegEx.Create('^\d{1,3}\.\d{1,3}\.\d{1,3}.\d{1,3}$');
  RegPort := TRegEx.Create('^\d{1,4}$');
  RegSetting := TRegistry.Create;
  RegSetting.RootKey := HKEY_CURRENT_USER;
  RegSetting.OpenKey(SettingPath, true);
  tProxy := RegSetting.ReadString('ProxyServer');
  if tProxy = '' then
  begin
    tProxy := '127.0.0.1:80';
  end;
  Values := SplitString(tProxy, ':');
  {* Если что-то ни так, то приводим к дефолту *}
  if Length(Values) < 1 then
     Values[1] := '80';
  if Not RegIP.IsMatch(Values[0]) then
     Values[0] := '127.0.0.1';
  if Not RegPort.IsMatch(Values[1]) then
     Values[1] := '80';
  tProxy := Values[0] + ':' + Values[1];
  RegSetting.WriteString('ProxyServer', tProxy);
  RegSetting.Free;
  Result := tProxy;
end;

{*
  ** Возвращаем строку прокси.
  ** Зависит от версии Windows
  ** У Windows 7 и ниже прокси применятся к http://, https://, ftp://
*}
function TMainForm.SetProxy: String;
var
  sProxy: String;
begin
  sProxy := ReadSetting;
  LogApp('Load Config: ' + sProxy, False);
  if WinVerNum >= 62 then
  begin
    // Windows 8 и Старше
    Vers := True;
    Result := sProxy;
  end
  else
  begin
    // Младше Windows 8
    Vers := False;
    Result := StringReplace(ProxyVar, '%ip:port%', sProxy, [rfReplaceAll, rfIgnoreCase]);
  end;
end;

{*
  ** Определение версии Windows
*}
function TMainForm.WinVerNum: integer;
var
  ver: TOSVersionInfo;
begin
  ver.dwOSVersionInfoSize := SizeOf(ver);
  if GetVersionEx(ver) then
  begin
    with ver do
      Result := StrToInt(IntToStr(dwMajorVersion) + '' + IntToStr(dwMinorVersion));
  end
  else
    Result := 1;
end;

{*
  ** Если Выход из системы или завершение работы
*}
procedure TMainForm.WMQueryEndSession(var Message: TWMQueryEndSession);
begin
inherited;
  MainCanClose := True;
  MainForm.Close;
end;

{*
  ** Состояние настроек прокси
*}
function TMainForm.GetCheckProxy: Integer;
var
  ProxyEnable: Integer;
begin
  ProxyEnable := Reg.ReadInteger('ProxyEnable');
  if ProxyEnable = 1 then
  begin
    StatusBar1.Panels[1].Text := ' Подключён';
    StatusBar1.Panels[1].ImageIndex := 1;
    TrayIcon1.IconIndex := 7;
  end
  else
  begin
    StatusBar1.Panels[1].Text := ' Отключён';
    StatusBar1.Panels[1].ImageIndex := 0;
    TrayIcon1.IconIndex := 6;
  end;
  Result := ProxyEnable;
end;

{*
  ** Отключение/Подключение Proxy
*}
procedure TMainForm.BitBtn1Click(Sender: TObject);
begin
  GetWind.Enabled := False;
  RE_1.Enabled := False;
  RE_2.Enabled := False;
  BitBtn1.Enabled := False;
  if RE_1.Checked then
  begin
    Reg.WriteString('ProxyOverride', ProxyOverride);
    Reg.WriteString('ProxyServer', Proxy);
    Reg.WriteInteger('ProxyEnable', 1);
    StatusBar1.PopupMenu := nil;
    MyThread := ExecuteCMD.Create(False);
    MyThread.OnTerminate := OnEnabledTerminate;
  end
  else
  begin
    if RE_2.Checked then
    begin
      Reg.WriteString('ProxyOverride', ProxyOverride);
      Reg.WriteString('ProxyServer', Proxy);
      Reg.WriteInteger('ProxyEnable', 0);
      StatusBar1.PopupMenu := nil;
      MyThread := ExecuteCMD.Create(False);
      MyThread.OnTerminate := OnDisabledTerminate;
    end;
  end;
end;

{*
  ** Закрытие программы
*}
procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
{*
  if Not MainCanClose then
     ChangeApplicationVisibility;
  if MainCanClose then
    LogApp('=========  Остановка Программы  ==========', True);
  CanClose := MainCanClose;
*}
end;

{*
  ** Запуск программы
*}
procedure TMainForm.FormCreate(Sender: TObject);
var
  s: String;
begin
  userDirectory := TPath.Combine(TPath.GetHomePath, 'ProxyConfig');
  if Not TDirectory.Exists(userDirectory) then
    TDirectory.CreateDirectory(userDirectory);
  logerPath := TPath.Combine(userDirectory, 'loger.log');
  {*
    ** Удалить файл если размер больще 100МБ
  *}
  if FileExists(logerPath) then
  begin
    try
      for s in TDirectory.GetFiles(TPath.GetDirectoryName(logerPath), TSearchOption.soAllDirectories,
          function(const Path: string; const SearchRec: TSearchRec): Boolean
          begin
            Result := SearchRec.Size > 104857600 // 100Mb  = 104857600
          end
      ) do DeleteFile(s);
    finally

    end;
  end;

  LogApp('=========   Запуск Программы    ==========', True);

  InitialDir := TPath.GetDirectoryName(TPath.GetDocumentsPath) + '\Desktop';

  Application.OnMinimize := ApplicationMinimize;
  Memo1.Items.Clear;
  MainCanClose := False;

  Proxy := SetProxy;

  Reg := TRegistry.Create;
  Reg.RootKey := HKEY_CURRENT_USER;
  Reg.OpenKey(CurrentPath, true);
  if Reg.ReadInteger('ProxyEnable') = 1 then
  begin
    RE_2.Checked := True;
    RE_1.Checked := False;
    LogApp('Proxy Подключен', False);
    TrayIcon1.IconIndex := 7;
  end
  else
  begin
    RE_2.Checked := False;
    RE_1.Checked := True;
    LogApp('Proxy Отключен', False);
    TrayIcon1.IconIndex := 6;
  end;
  GetWind.Enabled := True;
end;

{*
  ** Временная функция
*}
procedure TMainForm.GetWindTimer(Sender: TObject);
begin
  GetCheckProxy();
end;

{*
  ** Отключён Proxy
*}
procedure TMainForm.OnDisabledTerminate(Sender: TObject);
begin
  LogApp('Proxy Отключен', False);

  RE_1.Checked := True;
  RE_2.Checked := False;
  RE_1.Enabled := True;
  RE_2.Enabled := True;
  BitBtn1.Enabled := True;
  GetWind.Enabled := True;

  StatusBar1.PopupMenu := PopupMenu2;

  StatusBar1.Panels[1].Text := ' Отключён';
  StatusBar1.Panels[1].ImageIndex := 0;
  TrayIcon1.IconIndex := 6;
end;

{*
  ** Подключён Proxy
*}
procedure TMainForm.OnEnabledTerminate(Sender: TObject);
begin
  Reg.WriteString('ProxyOverride', ProxyOverride);
  Reg.WriteString('ProxyServer', Proxy);
  Reg.WriteInteger('ProxyEnable', 1);
  LogApp('Proxy Подключен', False);
                     
  RE_1.Checked := False;
  RE_2.Checked := True;
  RE_1.Enabled := True;
  RE_2.Enabled := True;
  BitBtn1.Enabled := True;
  GetWind.Enabled := True;

  StatusBar1.PopupMenu := PopupMenu2;
  StatusBar1.Panels[1].Text := ' Подключён';
  StatusBar1.Panels[1].ImageIndex := 1;
  TrayIcon1.IconIndex := 7;
end;

{*
  ** Развернуть/Свернуть программу по клику в PopupMenu
*}
procedure TMainForm.N1Click(Sender: TObject);
begin
  ChangeApplicationVisibility;
end;

{*
  ** Настройки программы
*}
procedure TMainForm.N2Click(Sender: TObject);
begin
  LogApp('Запуск Настройки программы', True);
  if SettingForm.ShowModal = 1 then
  begin
    LogApp('Настройки возможно изменялись', True);
    Proxy := SetProxy;
    if Reg.ReadInteger('ProxyEnable') = 1 then
    begin
      LogApp('Настройки будут приняты после переподключения', False);
      Reg.WriteString('ProxyOverride', ProxyOverride);
      Reg.WriteString('ProxyServer', Proxy);
      Reg.WriteInteger('ProxyEnable', 0);
      RE_1.Checked := True;
      RE_2.Checked := False;
      LogApp('Proxy Отключен', False);
    end;
  end;
  LogApp('Закрытие Настройки программы', True);
end;

{*
  ** Выгрузка файла *.log
*}
procedure TMainForm.N4Click(Sender: TObject);
var
  ext: String;
  path: String;
  fileName: String;
  oldFileName: String;
begin
  Save.InitialDir := InitialDir;
  Save.FileName := '';
  if Not FileExists(logerPath) then
  begin
    Memo1.Items.SaveToFile(logerPath);
  end;
  if Save.Execute then
  begin
    ext := TPath.GetExtension(Save.FileName);
    path := TPath.GetDirectoryName(Save.FileName);
    fileName := ChangeFileExt(ExtractFileName(Save.FileName), '');

    if(ext <> '')then
    begin
      oldFileName := path + '\' + fileName + '.log';
    end
    else
    begin
      oldFileName := path + '\' + fileName + ext;
    end;

    CopyFile(PWideChar(logerPath), PWideChar(oldFileName), false);

    ShellExecute(Application.Handle, 'OPEN', 'EXPLORER', PWideChar('/select, ' + oldFileName), '', SW_NORMAL);
    Save.InitialDir := InitialDir;
    Save.FileName := '';
  end;
end;

{*
  ** Выводим текущее время
*}
procedure TMainForm.Timer1Timer(Sender: TObject);
begin
  StatusBar1.Panels.Items[2].Text := FormatDateTime('dd.mm.yyyy hh:mm:ss', Now);
end;

{*
  ** Отобразить программу по клику на иконке в трее
*}
procedure TMainForm.TrayIcon1Click(Sender: TObject);
begin
  if Not Visible then
  begin
    ChangeApplicationVisibility;
  end;
end;

{*
  ** Развернуть и свернуть программу
*}
procedure TMainForm.ChangeApplicationVisibility;
begin
  if Visible then
  begin
    ShowWindow(Application.Handle,SW_HIDE);
    N1.Caption := '&Развернуть';
    N1.ImageIndex := 4;
    Hide;
  end
  else
  begin
    ShowWindow(Application.Handle, SW_SHOW);
    Show;
    ShowWindow(Handle, SW_NORMAL);
    Application.Restore;
    Application.BringToFront;
    N1.Caption := '&Свернуть';
    N1.ImageIndex := 3;
  end;
end;

{*
  ** Если программа сворачивается
*}
procedure TMainForm.ApplicationMinimize(Sender: TObject);
begin
  ShowWindow(Application.Handle,SW_HIDE);
  N1.Caption := '&Развернуть';
  N1.ImageIndex := 4;
  Hide;
end;

end.
