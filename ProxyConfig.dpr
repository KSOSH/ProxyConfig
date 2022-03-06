program ProxyConfig;

uses
  Windows,
  Vcl.Forms,
  Main in 'Main.pas' {MainForm},
  Setting in 'Setting.pas' {SettingForm},
  ThreadUnit in 'ThreadUnit.pas';

{$R *.res}

var
  H: THandle;
begin
  Application.Initialize;
  H := CreateMutex(nil, True, '{7D01BFAD-DEEC-4744-B075-FBE9C8307348}');
  if GetLastError = ERROR_ALREADY_EXISTS then
  begin
    Exit;
  end;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Прокси ЕСПД';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TSettingForm, SettingForm);
  Application.Run;
end.
