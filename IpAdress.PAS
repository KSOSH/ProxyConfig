////////////////////////////////////////////////////////////////////////////////
// IPADRESS98                                                                 //
////////////////////////////////////////////////////////////////////////////////
// An implementation of IE4's IPADDRESS Control                               //
////////////////////////////////////////////////////////////////////////////////
// Version 1.00 Beta                                                          //
// Date de création           : 20/10/1997                                    //
// Date dernière modification : 21/10/1997                                    //
////////////////////////////////////////////////////////////////////////////////
// Jean-Luc Mattei                                                            //
// jlucm@club-internet.fr  / jlucm@mygale.org                                 //
////////////////////////////////////////////////////////////////////////////////
// IMPORTANT NOTICE :                                                         //
//                                                                            //
//                                                                            //
// This program is FreeWare                                                   //
//                                                                            //
// Please do not release modified versions of this source code.               //
// If you've made any changes that you think should have been there,          //
// feel free to submit them to me at jlucm@club-internet.fr                   //
////////////////////////////////////////////////////////////////////////////////
//  REVISIONS :                                                               //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

unit IpAdress;

interface

uses
  Windows, Messages, SysUtils, Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ComCtrls, CommCtrl {, Comctl98};


type
{from comctl98}

  TCustomIPAdress98 = class;

  TIPAdressFieldChangeEvent = procedure (Sender: TCustomIPAdress98; OldField, Value: Byte) of object;
  TIPAdressChangeEvent = procedure (Sender: TCustomIPAdress98; IPAdress: String) of object;

  TCustomIPAdress98 = class(TWinControl)
  private
    FOnIPChange: TIPAdressChangeEvent;
    FOnIPFieldChange: TIPAdressFieldChangeEvent;
    FMinIPAddress: Longint;
    FMaxIPAddress: Longint;
    FActiveField: Byte;
    FAutoSize: Boolean;
    procedure CNNotify(var Message: TWMNotify); message CN_NOTIFY;
    procedure CNCommand(var Message: TWMCommand); message CN_COMMAND;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    function  GetMinIPAdress: String;
    function  GetMaxIPAdress: String;
    function  GetIPAdress: String;
    procedure SetMinIPAdress(Value: String);
    procedure SetMaxIPAdress(Value: String);
    procedure SetIPAdress(Value: String);
    function  GetEmpty: Boolean;
    procedure SetActiveField(Value: Byte);
  public
    constructor Create(AOwner: TComponent); override;
    function IPToString(Ip: Longint): String;
    function StringToIP(Value: String): Longint;
    procedure Clear;
    property ActiveField: Byte read FActiveField write SetActiveField;
    property Empty: Boolean read GetEmpty;
    property MinIPAdress: String read GetMinIPAdress write SetMinIPAdress;
    property MaxIPAdress: String read GetMaxIPAdress write SetMaxIPAdress;
    property IPAdress: String read GetIPAdress write SetIPAdress;
    property OnIPChange: TIPAdressChangeEvent read FOnIPChange write FOnIPChange;
    property OnIPFieldChange: TIPAdressFieldChangeEvent read FOnIPFieldChange write FOnIPFieldChange;
  end;

  TIPAdress98 = class(TCustomIPAdress98)
  published
    property ActiveField;
    property Empty;
    property MinIPAdress;
    property MaxIPAdress;
    property IPAdress;
    property OnIPChange;
    property OnIPFieldChange;
    property Font;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Tag;
    property DragCursor;
    property DragMode;
    property HelpContext;
  end;

function MakeIPRange(Low, High : Byte): Longint;
  //#define MAKEIPRANGE(low, high)    ((LPARAM)(WORD)(((BYTE)(high) << 8) + (BYTE)(low)))

// And this is a useful macro for making the IP Address to be passed
// as a LPARAM.

(*function MakeIPAdress(b1, b2, b3, b4 : Byte): Longint;
  //#define MAKEIPADDRESS(b1,b2,b3,b4)  ((LPARAM)(((DWORD)(b1)<<24)+((DWORD)(b2)<<16)+((DWORD)(b3)<<8)+((DWORD)(b4))))

function First_IPAdress(x : Longint): Byte;
  //#define FIRST_IPADDRESS(x)  ((x>>24) & 0xff)
function Second_IPAdress(x : Longint): Byte;
  //#define SECOND_IPADDRESS(x) ((x>>16) & 0xff)
function Third_IPAdress(x : Longint): Byte;
  //#define THIRD_IPADDRESS(x)  ((x>>8) & 0xff)
function Fourth_IPAdress(x : Longint): Byte;
  //#define FOURTH_IPADDRESS(x) (x & 0xff)
*)
procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [TIPAdress98]);
end;

constructor TCustomIPAdress98.Create(AOwner: TComponent);

begin
  inherited Create(AOwner);
  if NewStyleControls then
    ControlStyle := [csClickEvents, csSetCaption, csDoubleClicks, csFixedHeight]
  else
    ControlStyle := [csClickEvents, csSetCaption, csDoubleClicks, csFixedHeight, csFramed];
  ParentColor := False;
  FAutoSize := True;
  Width:= 100;
  Height:= 25;
  TabStop:= True;
  FMinIPAddress:= 0;
  FMaxIPAddress:= $0FFFFFFFF;
  FActiveField:= 0;
  FOnIPChange:= nil;
  FOnIPFieldChange:= nil;
end;

procedure TCustomIPAdress98.CreateParams(var Params: TCreateParams);
begin
  InitCommonControl(ICC_INTERNET_CLASSES);
  inherited CreateParams(Params);
  CreateSubClass(Params, WC_IPADDRESS);
  with Params do
  begin
    Style := WS_VISIBLE or WS_BORDER or WS_CHILD;
    if NewStyleControls and Ctl3D then
    begin
      Style := Style and not WS_BORDER;
      ExStyle := ExStyle or WS_EX_CLIENTEDGE;
    end;
  end;
end;

procedure TCustomIPAdress98.CNNotify(var Message: TWMNotify);
begin
  with Message.NMHdr^ do begin
    case Code of
      IPN_FIELDCHANGED :
        begin
          FActiveField:= PNMIPAddress(Message.NMHdr)^.iField;
          if Assigned(OnIpFieldChange) then
            with PNMIPAddress(Message.NMHdr)^ do begin
               OnIPFieldChange(Self, iField, iValue);
            end;
        end;
    end;
  end;
end;

function TCustomIPAdress98.GetIPAdress: String;
var Ip: Longint;
begin
  SendMessage(Handle, IPM_GETADDRESS, 0, Longint(@Ip));
  Result:= IPToString(Ip);
end;

function TCustomIPAdress98.GetMinIPAdress: String;
begin
  Result:= IPToString(FMinIPAddress);
end;

procedure TCustomIPAdress98.SetMinIPAdress(Value: String);
begin
  FMinIPAddress:= StringToIp(Value);
  SendMessage(Handle, IPM_SETRANGE, 0, MakeIpRange(First_IPAddress(FMinIPAddress), First_IPAddress(FMaxIPAddress)));
  SendMessage(Handle, IPM_SETRANGE, 1, MakeIpRange(Second_IPAddress(FMinIPAddress), Second_IPAddress(FMaxIPAddress)));
  SendMessage(Handle, IPM_SETRANGE, 2, MakeIpRange(Third_IPAddress(FMinIPAddress), Third_IPAddress(FMaxIPAddress)));
  SendMessage(Handle, IPM_SETRANGE, 3, MakeIpRange(Fourth_IPAddress(FMinIPAddress), Fourth_IPAddress(FMaxIPAddress)));
end;

function TCustomIPAdress98.GetMaxIPAdress: String;
begin
  Result:= IPToString(FMaxIPAddress);
end;

procedure TCustomIPAdress98.SetMaxIPAdress(Value: String);
begin
 FMaxIPAddress:= StringToIp(Value);
 SendMessage(Handle, IPM_SETRANGE, 0, MakeIpRange(First_IPAddress(FMinIPAddress), First_IPAddress(FMaxIPAddress)));
 SendMessage(Handle, IPM_SETRANGE, 1, MakeIpRange(Second_IPAddress(FMinIPAddress), Second_IPAddress(FMaxIPAddress)));
 SendMessage(Handle, IPM_SETRANGE, 2, MakeIpRange(Third_IPAddress(FMinIPAddress), Third_IPAddress(FMaxIPAddress)));
 SendMessage(Handle, IPM_SETRANGE, 3, MakeIpRange(Fourth_IPAddress(FMinIPAddress), Fourth_IPAddress(FMaxIPAddress)));
end;

procedure TCustomIPAdress98.SetIPAdress(Value: String);
begin
  SendMessage(Handle, IPM_SETADDRESS, 0, StringToIp(Value));
end;

function TCustomIPAdress98.GetEmpty: Boolean;
begin
  Result:= Boolean(SendMessage(Handle, IPM_ISBLANK, 0, 0));
end;

procedure TCustomIPAdress98.Clear;
begin
  SendMessage(Handle, IPM_CLEARADDRESS, 0, 0);
end;

procedure TCustomIPAdress98.SetActiveField(Value: Byte);
begin
  if ( Value < 4 ) then begin
    SendMessage(Handle, IPM_SETFOCUS, wParam(Value), 0);
    FActiveField:= Value;
  end;
end;

function TCustomIPAdress98.StringToIp(Value: String): Longint;
var B: Array[0..3] of Byte;
    Str: String;
    i, Cnt : Integer;
begin
  B[0]:= 0;
  B[1]:= 0;
  B[2]:= 0;
  B[3]:= 0;
  Cnt:= 0;
  i:= Pos('.', Value);
  while (Length(Value) > 0) and ( Cnt < 4 ) do begin
    if ( i = 0 ) then i:= Length(Value)+1;
    Str:= Copy(Value, 0, i-1);
    B[Cnt]:= StrToInt(Str);
    Value:= Copy(Value, i+1, Length(Value));
    i:= Pos('.', Value);
    Inc(Cnt);
  end;
  Result:= MakeIPAddress(b[0], b[1], b[2], b[3]);
end;

function TCustomIPAdress98.IPToString(Ip: Longint): String;
begin
  Result:= IntToStr(First_IPAddress(Ip))+'.'+IntToStr(Second_IPAddress(Ip))+'.'+
           IntToStr(Third_IPAddress(Ip))+'.'+IntToStr(Fourth_IPAddress(Ip));
end;

procedure TCustomIPAdress98.CNCommand(var Message: TWMCommand);
begin
  if (Message.NotifyCode = EN_CHANGE) and Assigned(OnIpChange) then
    OnIPChange(Self, IPAdress);
end;

function MakeIPRange(Low, High : Byte): Longint;
begin
  Result:= Longint((Longint(high) SHL 8) + Longint(low));
end;


{function First_IPAdress(x : Longint): Byte;
begin
  Result:= Byte((x Shr 24) and $0FF);
end;

function Second_IPAdress(x : Longint): Byte;
begin
  Result:= Byte((x Shr 16) and $0FF);
end;

function Third_IPAdress(x : Longint): Byte;
begin
  Result:= Byte((x Shr 8) and $0FF);
end;

function Fourth_IPAdress(x : Longint): Byte;
begin
  Result:= Byte(x and $0FF);
end;}


end.
