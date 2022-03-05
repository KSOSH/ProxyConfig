unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.ComCtrls, Registry, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.Menus, Setting, StrUtils, System.Types, System.RegularExpressions,
  System.ImageList, Vcl.ImgList, SBPro, Vcl.XPMan;

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
    procedure FormCreate(Sender: TObject);
    procedure GetWindTimer(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure N4Click(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure TrayIcon1DblClick(Sender: TObject);
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
  public
    { Public declarations }
  end;

const
  CurrentPath = 'Software\Microsoft\Windows\CurrentVersion\Internet Settings';
  SettingPath = 'Software\ProxyConfigApp';
  ProxyOverride = '*.localhost;*.school;*.localschool;*.hostname;<local>';
  ProxyVar = 'http=%ip:port%;https=%ip:port%;ftp=%ip:port%';
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
  if Length(Values) < 2 then
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

function TMainForm.SetProxy: String;
var
  sProxy: String;
begin
  sProxy := ReadSetting;
  Memo1.Items.Add(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' > Load Config: ' + sProxy);
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
  SendMessage(Memo1.Handle,WM_VSCROLL,SB_BOTTOM,0);
end;

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

procedure TMainForm.WMQueryEndSession(var Message: TWMQueryEndSession);
begin
inherited;
  MainCanClose := True;
  MainForm.Close;
end;

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
    Memo1.Items.Add(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' > Proxy Подключен');
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
      Memo1.Items.Add(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' > Proxy Отключен');
    end;
  end;
  GetWind.Enabled := True;
  SendMessage(Memo1.Handle,WM_VSCROLL,SB_BOTTOM,0);
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

procedure TMainForm.GetWindTimer(Sender: TObject);
begin
  GetCheckProxy();
end;

procedure TMainForm.N1Click(Sender: TObject);
begin
  ChangeApplicationVisibility;
end;

procedure TMainForm.N2Click(Sender: TObject);
begin
  if SettingForm.ShowModal = 1 then
  begin
    Proxy := SetProxy;
    if Reg.ReadInteger('ProxyEnable') = 1 then
    begin
      Memo1.Items.Add(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' > Настройки будут приняты после переподключения');
      Reg.WriteString('ProxyOverride', ProxyOverride);
      Reg.WriteString('ProxyServer', Proxy);
      Reg.WriteInteger('ProxyEnable', 0);
      RE_1.Checked := True;
      RE_2.Checked := False;
      Memo1.Items.Add(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' > Proxy Отключен');
      SendMessage(Memo1.Handle,WM_VSCROLL,SB_BOTTOM,0);
    end;
  end;
end;

procedure TMainForm.N4Click(Sender: TObject);
begin
  MainCanClose := True;
  MainForm.Close;
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
begin
  StatusBar1.Panels.Items[2].Text := FormatDateTime('dd.mm.yyyy hh:mm:ss', Now);
end;

procedure TMainForm.TrayIcon1DblClick(Sender: TObject);
begin
  if Not Visible then
  begin
    ShowWindow(Application.Handle, SW_SHOW);
    Show;
    ShowWindow(Handle, WinApi.Windows.SW_NORMAL);
    Application.Restore;
    Application.BringToFront;
    N1.Caption := 'Свернуть';
  end;
end;

procedure TMainForm.ChangeApplicationVisibility;
begin
  if Visible then
  begin
    ShowWindow(Application.Handle,SW_HIDE);
    Hide;
    N1.Caption := 'Развернуть';
  end
  else
  begin
    ShowWindow(Application.Handle, SW_SHOW);
    Show;
    ShowWindow(Handle, WinApi.Windows.SW_NORMAL);
    Application.Restore;
    Application.BringToFront;
    N1.Caption := 'Свернуть';
  end;
end;

procedure TMainForm.ApplicationMinimize(Sender: TObject);
begin
  ChangeApplicationVisibility;
end;

end.
