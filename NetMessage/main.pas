unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  IdUDPServer, IdSocketHandle, IdIPWatch, IdGlobal, documents;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    IdIPWatch1: TIdIPWatch;
    IdUDPServer1: TIdUDPServer;
    Memo1: TMemo;
    PingTimer: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PingTimerTimer(Sender: TObject);
  private
    FMyIP: string;
    FPort: integer;
    FMyID: string;
    FMyName: string;

    RIP: string;

    function GetMyID: string;
    function GetEnvironmentVariable(const key: string): string;
    procedure HandleDocument(const Document: TDocument);
    procedure Broadcast(S: string; const IP: string = '');
    procedure UDPServerRead(AThread: TIdUDPListenerThread; const AData: TIdBytes;
      ABinding: TIdSocketHandle);
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

uses IniFiles;

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var
  ComputerName: string;

  Ini: TIniFile;
begin
  Ini := TIniFile.Create(ChangeFileExt(Application.ExeName, '.cfg'));
  try
    FMyIP := ini.ReadString('Server', 'IP', '192.168.1.4');//'192.168.1.4';//IdIPWatch1.LocalIP;
    FPort := 9527;
    FMyID := ini.ReadString('Server', 'IP', FMyIP);
    RIP := ini.ReadString('Server', 'RIP', '192.168.1.8');
  finally
    Ini.Free;
  end;

  IdIPWatch1.Active := True;
  Memo1.Append('CurrentIP: ' + IdIPWatch1.CurrentIP);
  Memo1.Append('LocalIP: ' + FMyIP); //IdIPWatch1.LocalIP
  Memo1.Append('PreviousIP: ' + IdIPWatch1.PreviousIP);
  Memo1.Append('USERNAME: ' + GetEnvironmentVariable('USERNAME'));
  Memo1.Append('USERDNSDOMAIN: ' + GetEnvironmentVariable('USERDNSDOMAIN'));
  ComputerName := GetEnvironmentVariable('COMPUTERNAME');
  Memo1.Append('COMPUTERNAME: ' + ComputerName);

  //IdUDPServer1.DefaultPort := FPort;
  IdUDPServer1.Bindings.Add.IP := FMyIP;
  IdUDPServer1.Bindings.Add.Port := FPort;
  IdUDPServer1.OnUDPRead := @UDPServerRead;
  //IdUDPServer1.BroadcastEnabled := False;
  IdUDPServer1.Active := True;

  //FMyID := GetMyID;
  FMyName := GetEnvironmentVariable('COMPUTERNAME');

  with TOnLineNotify.Create(FMyIP, FMyID) do
  begin
    Name := FMyName;
    Broadcast(ToString);
  end;

  PingTimer.Enabled := True;
end;

procedure TForm1.PingTimerTimer(Sender: TObject);
begin
  TTimer(Sender).Enabled := False;
  try
    with TActivePing.Create(FMyIP, FMyID) do
    begin
      Broadcast(ToString, RIP);
    end;
  finally
    TTimer(Sender).Enabled := True;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin

  with TMessage.Create(FMyIP, FMyID) do
  begin
    Name := FMyName;
    MessageID := 'GUID';
    Message := Edit1.Text;
    Broadcast(ToString, '');
    Memo1.Append(ToString);
  end;

end;

function TForm1.GetMyID: string;
begin
  Result := '123456789';
end;

function TForm1.GetEnvironmentVariable(const key: string): string;
begin
  Result := SysUtils.GetEnvironmentVariable(key);
end;

procedure TForm1.HandleDocument(const Document: TDocument);
begin
  if Document.ClassName = TOnLineNotify.ClassName then
  begin
    with TOnLineNotifyResponse.Create(FMyIP, FMyID) do
    begin
      IP := IdIPWatch1.LocalIP;
      Name := FMyName;
      Broadcast(ToString, Document.IP);
    end;
  end else

  if Document.ClassName = TOnLineNotifyResponse.ClassName then
  begin
    Memo1.Append(Document.IP);
    Memo1.Append(TOnLineNotifyResponse(Document).Name);
  end else

  if Document.ClassName = TActivePing.ClassName then
  begin
    with TActivePingResponse.Create(FMyIP, FMyID) do
    begin
      Broadcast(ToString, Document.IP);
    end;
  end else

  if Document.ClassName = TActivePingResponse.ClassName then
  begin
    // 更新本地状态
    Memo1.Append(DateTimeToStr(Now) + ' 收到存活应答: ' + Document.ID);
  end else

  if Document.ClassName = TMessage.ClassName then
  begin
    Memo1.Append(TMessage(Document).Message);

    with TMessageResponse.Create(FMyIP, FMyID) do
    begin
      MessageID := TMessage(Document).MessageID;
      Broadcast(ToString, Document.IP);
    end;
  end else

  if Document.ClassName = TMessageResponse.ClassName then
  begin
    Memo1.Append('消息已发送');
  end;

end;

procedure TForm1.Broadcast(S: string; const IP: string);
var
  bytes: TIdBytes;
begin
  bytes := StrToBytes(S);
  IdUDPServer1.Broadcast(bytes, FPort, IP);
end;

procedure TForm1.UDPServerRead(AThread: TIdUDPListenerThread; const AData: TIdBytes;
  ABinding: TIdSocketHandle);
var
  Document: TDocument;
begin
  if Length(AData) = 0 then
    Exit;

  Document := TDocument.Create(AData);
  try
    if not Document.IsMySelf(FMyID) then
    begin
      Memo1.Append('######################################################');
      Memo1.Append(DateTimeToStr(Now) + ' Receive: ' + Document.DocType);
      Memo1.Append(BytesToString(AData));
      HandleDocument(Document.GetDocument);
    end;
  finally
    Document.Free;
  end;

end;

end.
