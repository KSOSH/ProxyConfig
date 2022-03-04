unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.ComCtrls, Registry, Vcl.StdCtrls, Vcl.Buttons, Vcl.Menus;

type
  TMainForm = class(TForm)
    StatusBar1: TStatusBar;
    GetWind: TTimer;
    BitBtn1: TBitBtn;
    TrayIcon1: TTrayIcon;
    RE_1: TRadioButton;
    RE_2: TRadioButton;
    Memo1: TMemo;
    Button1: TButton;
    Panel1: TPanel;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    PopupMenu2: TPopupMenu;
    N2: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure GetWindTimer(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure N4Click(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure TrayIcon1DblClick(Sender: TObject);
  private
    { Private declarations }
    function GetCheckProxy():Integer;
    procedure ChangeApplicationVisibility;
    procedure ApplicationMinimize(Sender: TObject);
  public
    { Public declarations }
  end;

const
  CurrentPath = 'Software\Microsoft\Windows\CurrentVersion\Internet Settings';
  ProxyOverride = '*.localhost;*.school;*.localschool;*.hostname;<local>';
  ProxyVar = 'http=%ip:port%;https=%ip:port%;ftp=%ip:port%';
var
  MainForm: TMainForm;
  i: integer;
  Vers: Boolean;
  Reg: TRegistry;
  Proxy: String;
  MainCanClose: Boolean;
implementation

{$R *.dfm}

function WinVerNum: integer;
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

function TMainForm.GetCheckProxy: Integer;
var
  ProxyEnable: Integer;
begin
  ProxyEnable := Reg.ReadInteger('ProxyEnable');
  if ProxyEnable = 1 then
  begin
    StatusBar1.Panels[1].Text := 'Подключён';
  end
  else
  begin
    StatusBar1.Panels[1].Text := 'Отключён';
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
  end;
  if RE_2.Checked then
  begin
    Reg.WriteString('ProxyOverride', ProxyOverride);
    Reg.WriteString('ProxyServer', Proxy);
    Reg.WriteInteger('ProxyEnable', 0);
  end;
  GetWind.Enabled := True;
end;

procedure TMainForm.Button1Click(Sender: TObject);
begin
  Memo1.Lines.Add(IntToStr(WinVerNum));
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
  Memo1.Lines.Clear;
  MainCanClose := False;
  if WinVerNum >= 62 then
  begin
    // Windows 8 и Старше
    Vers := True;
    Proxy := '10.0.63.52:3128';
  end
  else
  begin
    // Младше Windows 8
    Vers := False;
    Proxy := StringReplace(ProxyVar, '%ip:port%', '10.0.63.52:3128', [rfReplaceAll, rfIgnoreCase]);
  end;
  Reg := TRegistry.Create;
  Reg.RootKey := HKEY_CURRENT_USER;
  Reg.OpenKey(CurrentPath, true);
  ProxyEnable := Reg.ReadInteger('ProxyEnable');
  if ProxyEnable = 1 then
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

procedure TMainForm.N4Click(Sender: TObject);
begin
  MainCanClose := True;
  MainForm.Close;
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
