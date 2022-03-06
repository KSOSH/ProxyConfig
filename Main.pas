unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.ComCtrls, Registry, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.Menus, Setting, StrUtils, System.Types, System.RegularExpressions,
  System.ImageList, Vcl.ImgList, SBPro, Vcl.XPMan, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdHTTP;

type
  TMainForm = class(TForm)
    GetWind: TTimer;
    BitBtn1: TBitBtn;
    TrayIcon1: TTrayIcon;
    RE_1: TRadioButton;
    RE_2: TRadioButton;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    PopupMenu2: TPopupMenu;
    N2: TMenuItem;
    Memo1: TListBox;
    ImageList1: TImageList;
    StatusBar1: TStatusBarPro;
    Timer1: TTimer;
    XPManifest1: TXPManifest;
    Grops: TGroupBox;
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
    procedure LogApp(S: String);
  public
    { Public declarations }
  end;

const
  CurrentPath = 'Software\Microsoft\Windows\CurrentVersion\Internet Settings';
  SettingPath = 'Software\ProxyConfigApp';
  ProxyOverride = '*.localhost;*.school;*.localschool;*.hostname;<local>';
  ProxyVar = 'http=%ip:port%;https=%ip:port%;ftp=%ip:port%';
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
implementation

{$R *.dfm}

{*
  ** Функция запроса данных с сайта
  ** Определить с какого...
*}
function TryWebContentToInt(const AURL: string): Boolean;
var
  S: string;
  http: TIdHTTP;
begin
  http := TIdHTTP.Create(nil);
  try
    http.HandleRedirects := True;
    try
      S := http.Get(AURL);
      Result := True;
    except
      Result := False;
    end;
  finally
    http.Free;
  end;
end;

{*
  ** Функция Логирования
*}
procedure TMainForm.LogApp(S: String);
begin
  Memo1.Items.Add(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' > ' + S);
  SendMessage(Memo1.Handle,WM_VSCROLL,SB_BOTTOM,0);
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
  LogApp('Load Config: ' + sProxy);
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
    StatusBar1.Panels[1].Text := 'Подключён';
    StatusBar1.Panels[1].ImageIndex := 1;
  end
  else
  begin
    StatusBar1.Panels[1].Text := 'Отключён';
    StatusBar1.Panels[1].ImageIndex := 0;
  end;
  Result := ProxyEnable;
end;

procedure TMainForm.BitBtn1Click(Sender: TObject);
begin
  GetWind.Enabled := False;
  if RE_1.Checked then
  begin
    Reg.WriteString('ProxyOverride', ProxyOverride);
    Reg.WriteString('ProxyServer', Proxy);
    Reg.WriteInteger('ProxyEnable', 1);
    RE_1.Checked := False;
    RE_2.Checked := True;
    LogApp('Proxy Подключен');
  end
  else
  begin
    if RE_2.Checked then
    begin
      Reg.WriteString('ProxyOverride', ProxyOverride);
      Reg.WriteString('ProxyServer', Proxy);
      Reg.WriteInteger('ProxyEnable', 0);
      RE_1.Checked := True;
      RE_2.Checked := False;
      LogApp('Proxy Отключен');
    end;
  end;
  GetWind.Enabled := True;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if Not MainCanClose then
     ChangeApplicationVisibility;
  CanClose := MainCanClose;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  ProxyEnable: Integer;
  I: Integer;
begin
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
  end
  else
  begin
    RE_2.Checked := False;
    RE_1.Checked := True;
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
  if SettingForm.ShowModal = 1 then
  begin
    Proxy := SetProxy;
    if Reg.ReadInteger('ProxyEnable') = 1 then
    begin
      LogApp('Настройки будут приняты после переподключения');
      Reg.WriteString('ProxyOverride', ProxyOverride);
      Reg.WriteString('ProxyServer', Proxy);
      Reg.WriteInteger('ProxyEnable', 0);
      RE_1.Checked := True;
      RE_2.Checked := False;
      LogApp('Proxy Отключен');
    end;
  end;
end;

{*
  ** Закрытие Ghjuhfvvs
*}
procedure TMainForm.N4Click(Sender: TObject);
begin
  MainCanClose := True;
  MainForm.Close;
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
    ShowWindow(Application.Handle, SW_SHOW);
    Show;
    ShowWindow(Handle, WinApi.Windows.SW_NORMAL);
    Application.Restore;
    Application.BringToFront;
    N1.Caption := 'Свернуть';
    N1.ImageIndex := 3;
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
    Hide;
    N1.Caption := 'Развернуть';
    N1.ImageIndex := 4;
  end
  else
  begin
    ShowWindow(Application.Handle, SW_SHOW);
    Show;
    ShowWindow(Handle, WinApi.Windows.SW_NORMAL);
    Application.Restore;
    Application.BringToFront;
    N1.Caption := 'Свернуть';
    N1.ImageIndex := 3;
  end;
end;

{*
  ** Если программа сворачивается
*}
procedure TMainForm.ApplicationMinimize(Sender: TObject);
begin
  ChangeApplicationVisibility;
end;

end.
