unit documents;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpjson, IdGlobal;

type

  { TDocument }

  TDocument = class(TObject)
  private
    FID: string;
    FDocType: string;
    FDocument: TJSONObject;
    FIP: string;
    procedure SetID(AValue: string);
    procedure SetDocType(AValue: string);
    procedure SetIP(AValue: string);
    procedure WriteProperty(const key: string; const Value: string);
  protected
    procedure WriteProperties; virtual;
    procedure ReadProperties(const Document: TDocument); virtual;
  public
    constructor Create(const IP: string; const ID: string); overload;
    constructor Create(const Data: TIdBytes); overload;
    destructor Destroy; override;

    function IsMySelf(const ID: string): boolean;
    function GetDocProperty(const key: string): variant;
    function GetDocument: TDocument;
    function ToString: string; override;

    property IP: string read FIP write SetIP;
    property ID: string read FID write SetID;
    property DocType: string read FDocType write SetDocType;
  end;

  { TOnLineNotify }

  TOnLineNotify = class(TDocument)
  private
    FName: string;
    procedure SetName(AValue: string);
  protected
    procedure WriteProperties; override;
    procedure ReadProperties(const Document: TDocument); override;
  public
    property Name: string read FName write SetName;
  end;

  { TOnLineNotifyResponse }

  TOnLineNotifyResponse = class(TDocument)
  private
    FName: string;
    procedure SetName(AValue: string);
  protected
    procedure WriteProperties; override;
    procedure ReadProperties(const Document: TDocument); override;
  public
    property Name: string read FName write SetName;
  end;

  { TActivePing }

  TActivePing = class(TDocument)
  protected
    procedure WriteProperties; override;
    procedure ReadProperties(const Document: TDocument); override;
  end;

  { TActivePingResponse }

  TActivePingResponse = class(TDocument)
  private
    FName: string;
    procedure SetName(AValue: string);
  protected
    procedure WriteProperties; override;
    procedure ReadProperties(const Document: TDocument); override;
  public
    property Name: string read FName write SetName;
  end;

  { TMessage }

  TMessage = class(TDocument)
  private
    FMessage: string;
    FMessageID: string;
    FName: string;
    procedure SetMessage(AValue: string);
    procedure SetMessageID(AValue: string);
    procedure SetName(AValue: string);
  protected
    procedure WriteProperties; override;
    procedure ReadProperties(const Document: TDocument); override;
  public
    property MessageID: string read FMessageID write SetMessageID;
    property Name: string read FName write SetName;
    property Message: string read FMessage write SetMessage;
  end;

  { TMessageResponse }

  TMessageResponse = class(TDocument)
  private
    FMessageID: string;
    procedure SetMessageID(AValue: string);
  protected
    procedure WriteProperties; override;
    procedure ReadProperties(const Document: TDocument); override;
  public
    property MessageID: string read FMessageID write SetMessageID;
  end;

function StrToBytes(const S: string): TIdBytes;
function BytesToStr(const B: TIdBytes): string;

implementation

//编码转换，FPC String的编码是IndyTextEncoding_UTF8
function StrToBytes(const S: string): TIdBytes;
begin
  Result := ToBytes(S, IndyTextEncoding_UTF8 {$IFDEF FPC}, IndyTextEncoding_UTF8{$ENDIF});
end;

//编码转换，FPC String的编码是IndyTextEncoding_UTF8
function BytesToStr(const B: TIdBytes): string;
begin
  Result := BytesToString(B, IndyTextEncoding_UTF8 {$IFDEF FPC}, IndyTextEncoding_UTF8{$ENDIF});
end;

{ TMessageResponse }

procedure TMessageResponse.SetMessageID(AValue: string);
begin
  if FMessageID = AValue then
    Exit;
  FMessageID := AValue;
end;

procedure TMessageResponse.WriteProperties;
begin
  inherited WriteProperties;
  WriteProperty('MessageID', FMessageID);
end;

procedure TMessageResponse.ReadProperties(const Document: TDocument);
begin
  inherited ReadProperties(Document);
  FMessageID := Document.GetDocProperty('MessageID');
end;

{ TMessage }

procedure TMessage.SetName(AValue: string);
begin
  if FName = AValue then
    Exit;
  FName := AValue;
end;

procedure TMessage.SetMessageID(AValue: string);
begin
  if FMessageID = AValue then
    Exit;
  FMessageID := AValue;
end;

procedure TMessage.SetMessage(AValue: string);
begin
  if FMessage = AValue then
    Exit;
  FMessage := AValue;
end;

procedure TMessage.WriteProperties;
begin
  inherited WriteProperties;

  WriteProperty('Name', FName);
  WriteProperty('MessageID', FMessageID);
  WriteProperty('Message', Message);
end;

procedure TMessage.ReadProperties(const Document: TDocument);
begin
  inherited ReadProperties(Document);

  FName := Document.GetDocProperty('Name');
  FMessageID := Document.GetDocProperty('MessageID');
  FMessage := Document.GetDocProperty('Message');
end;

{ TActivePingResponse }

procedure TActivePingResponse.SetName(AValue: string);
begin
  if FName = AValue then
    Exit;
  FName := AValue;
end;

procedure TActivePingResponse.WriteProperties;
begin
  inherited WriteProperties;
end;

procedure TActivePingResponse.ReadProperties(const Document: TDocument);
begin
  inherited ReadProperties(Document);
end;

{ TActivePing }

procedure TActivePing.WriteProperties;
begin
  inherited WriteProperties;
end;

procedure TActivePing.ReadProperties(const Document: TDocument);
begin
  inherited ReadProperties(Document);
end;

{ TOnLineNotifyResponse }

procedure TOnLineNotifyResponse.SetName(AValue: string);
begin
  if FName = AValue then
    Exit;
  FName := AValue;
end;

procedure TOnLineNotifyResponse.WriteProperties;
begin
  inherited WriteProperties;
  WriteProperty('Name', FName);
end;

procedure TOnLineNotifyResponse.ReadProperties(const Document: TDocument);
begin
  inherited ReadProperties(Document);
  FName := Document.GetDocProperty('Name');
end;

{ TOnLineNotify }

procedure TOnLineNotify.SetName(AValue: string);
begin
  if FName = AValue then
    Exit;
  FName := AValue;
end;

procedure TOnLineNotify.WriteProperties;
begin
  inherited WriteProperties;
  WriteProperty('Name', FName);
end;

procedure TOnLineNotify.ReadProperties(const Document: TDocument);
begin
  inherited ReadProperties(Document);
  FName := Document.GetDocProperty('Name');
end;

{ TDocument }

procedure TDocument.SetDocType(AValue: string);
begin
  if FDocType = AValue then
    Exit;
  FDocType := AValue;
end;

procedure TDocument.SetIP(AValue: string);
begin
  if FIP = AValue then
    Exit;
  FIP := AValue;
end;

procedure TDocument.SetID(AValue: string);
begin
  if FID = AValue then
    Exit;
  FID := AValue;
end;

procedure TDocument.WriteProperty(const key: string; const Value: string);
begin
  if FDocument.IndexOfName(key) < 0 then
  begin
    FDocument.Add(key, Value);
  end else
  begin
    FDocument.Elements[key].Value := Value;
  end;
end;

procedure TDocument.WriteProperties;
begin
  WriteProperty('IP', FIP);
  WriteProperty('ID', FID);
  WriteProperty('DocType', FDocType);
end;

procedure TDocument.ReadProperties(const Document: TDocument);
begin
  FIP := Document.GetDocProperty('IP');
  FID := Document.GetDocProperty('ID');
  FDocType := Document.GetDocProperty('DocType');
end;

constructor TDocument.Create(const IP: string; const ID: string);
begin
  FDocument := TJSONObject.Create;
  FIP := IP;
  FID := ID;
  FDocType := ClassName;
end;

constructor TDocument.Create(const Data: TIdBytes);
var
  S: string;
  JSONData: TJSONData;
begin
  S := BytesToStr(Data);
  try
    JSONData := GetJSON(S);
    FDocument := TJSONObject(JSONData);
    FIP := FDocument.Elements['IP'].Value;
    FID := FDocument.Elements['ID'].Value;
    FDocType := FDocument.Elements['DocType'].Value;
  except
    FDocument := TJSONObject.Create;
    FDocType := '';
  end;
end;

destructor TDocument.Destroy;
begin
  if FDocument <> nil then
    FreeAndNil(FDocument);

  inherited Destroy;
end;

function TDocument.ToString: string;
begin
  WriteProperties;
  Result := FDocument.AsJSON;
end;

function TDocument.IsMySelf(const ID: string): boolean;
begin
  Result := CompareText(FID, ID) = 0;
end;

function TDocument.GetDocProperty(const key: string): variant;
begin
  Result := FDocument.Elements[key].Value;
end;

function TDocument.GetDocument: TDocument;
begin
  try
    case FDocType of
      'TOnLineNotify': Result := TOnLineNotify.Create(FIP, FID);
      'TOnLineNotifyResponse': Result := TOnLineNotifyResponse.Create(FIP, FID);
      'TActivePing': Result := TActivePing.Create(FIP, FID);
      'TActivePingResponse': Result := TActivePingResponse.Create(FIP, FID);
      'TMessage': Result := TMessage.Create(FIP, FID);
      'TMessageResponse': Result := TMessageResponse.Create(FIP, FID);
      '': Result := nil;
    end;

    if Result <> nil then
    begin
      Result.ReadProperties(Self);
    end;
  except
    if Result <> nil then
    begin
      Result.Free;
    end;
    Result := nil;
  end;
end;


end.
