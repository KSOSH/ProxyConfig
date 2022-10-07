program ProxyConfig;

uses
  Windows,
  Dialogs,
  System.SysUtils,
  System.UITypes,
  Vcl.Forms,
  Main in 'Main.pas' {MainForm} ,
  Setting in 'Setting.pas' {SettingForm} ,
  ThreadUnit in 'ThreadUnit.pas';

{$R *.res}

var
  H: THandle;
  n: String;

begin
  Application.Initialize;
  n := GetEnvironmentVariable('username');
  H := CreateMutex(nil, True,
    PWideChar(n + '{7D01BFAD-DEEC-4744-B075-FBE9C8307348}'));
  if GetLastError = ERROR_ALREADY_EXISTS then
  begin
    // Dialogs.MessageDlg('Для пользователя ' + n + #13#10 + 'Программа запущена', mtWarning, [mbOk], 0);
    Exit;
  end;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Proxy Configuration';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TSettingForm, SettingForm);
  Application.Run;
end.
