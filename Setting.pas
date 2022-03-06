unit Setting;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.NumberBox, IpAdress,
  Vcl.Buttons, Registry, System.Types, StrUtils, System.RegularExpressions,
  Vcl.XPMan;

type
  TSettingForm = class(TForm)
    IpAdress: TIPAdress98;
    Label1: TLabel;
    Label2: TLabel;
    Port: TNumberBox;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    XPManifest1: TXPManifest;
    procedure FormShow(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  CurrentPath = 'Software\ProxyConfigApp';

var
  SettingForm: TSettingForm;
  //MainForm: TMainForm;
  Reg: TRegistry;
  RegIP: TRegEx;
  RegPort: TRegEx;
  tmpProxy: String;
  Values: TStringDynArray;
implementation

{$R *.dfm}

uses Main;

procedure TSettingForm.BitBtn1Click(Sender: TObject);
begin
  if Port.ValueInt = 1 then
    Port.ValueInt := 80;
  RegIP := TRegEx.Create('^\d{1,3}\.\d{1,3}\.\d{1,3}.\d{1,3}$');
  RegPort := TRegEx.Create('^\d{1,4}$');
  Reg := TRegistry.Create;
  Reg.RootKey := HKEY_CURRENT_USER;
  Reg.OpenKey(CurrentPath, true);
  Reg.WriteString('ProxyServer', IpAdress.IPAdress + ':' + IntToStr(Port.ValueInt));
  Reg.Free;
end;

procedure TSettingForm.FormShow(Sender: TObject);
begin
  //Port.ValueInt;
  RegIP := TRegEx.Create('^\d{1,3}\.\d{1,3}\.\d{1,3}.\d{1,3}$');
  RegPort := TRegEx.Create('^\d{1,4}$');
  Reg := TRegistry.Create;
  Reg.RootKey := HKEY_CURRENT_USER;
  Reg.OpenKey(CurrentPath, true);
  tmpProxy := Reg.ReadString('ProxyServer');
  if tmpProxy = '' then
  begin
    tmpProxy := '127.0.0.1:80';
    Reg.WriteString('ProxyServer', tmpProxy);
  end;
  Values := SplitString(tmpProxy, ':');
  if Length(Values) < 2 then
     Values[1] := '80';
  if Not RegIP.IsMatch(Values[0]) then
     Values[0] := '127.0.0.1';
  if Not RegPort.IsMatch(Values[1]) then
     Values[1] := '80';
  Reg.WriteString('ProxyServer', Values[0] + ':' + Values[1]);
  IpAdress.IPAdress := Values[0];
  Port.ValueInt := StrToInt(Values[1]);
  Reg.Free;
end;

end.
