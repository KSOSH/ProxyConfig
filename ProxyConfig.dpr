program ProxyConfig;

uses
  Vcl.Forms,
  Main in 'Main.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Proxy Configuration App';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
