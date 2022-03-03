unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ComCtrls;

type
  TMainForm = class(TForm)
    StatusBar1: TStatusBar;
    GetWind: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure GetWindTimer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;
  i: integer;
implementation

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  i := 0;
end;

procedure TMainForm.GetWindTimer(Sender: TObject);
begin
  i := i + 1;
  Caption:= 'Proxy Configuration ' + i.ToString;
end;

end.
