unit myhttp;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, httpsend;

type
  TMethod = (mGet, mPost, mHead);
  TProtocol = (pHttp, pHttps, pUndef);

  THTTPResponseEvent = procedure(ResponseCode: integer; ResponseContent: String) of object;

  THTTP = class;

  THTTPThread = class(TThread)
  private
    FResponse: THTTPResponseEvent;
    HTTPSend: THTTPSend;
    FMethod: string;
    FURL: string;
    procedure DoResponse;
  protected
    procedure Execute; override;
  public
    constructor Create(AHTTP: THTTP);
  end;

  THTTP = class
  private
    HTTPThread: THTTPThread;
    FMethod: TMethod;
    FURL: String;
    FProto: TProtocol;
    FPort: integer;
    FHost: String;
    FPath: String;
    FContents: String;
    FUserAgent: String;
    FMimeType: String;
    FOnResponse: THTTPResponseEvent;
    function ProtoToStr(AProto: TProtocol): String;
    procedure SetURL(AURL: string);
    function GetURL: String;
    procedure SetContents(AContents: string);
    function GetContents: String;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SendRequest;
    property Method: TMethod read FMethod write FMethod default mGet;
    property URL: String read GetURL write SetURL;
    property Contents: String read GetContents write SetContents;
    property UserAgent: String read FUserAgent write FUserAgent;
    property MimeType: String read FMimeType write FMimeType;
    property OnResponse: THTTPResponseEvent read FOnResponse write FOnResponse;
  end;


implementation

function HTTPEncode(const AStr: String): String;
const
  HTTPAllowed = ['A'..'Z','a'..'z',
                 '*','@','.','_','-',
                 '0'..'9',
                 '$','!','''','(',')'];

var
  SS, S, R: PChar;
  H: String[2];
  L: Integer;
begin
  L:= Length(AStr);
  SetLength(Result, L*3); // Worst case scenario
  if (L = 0) then
    exit;
  R:= PChar(Result);
  S:= PChar(AStr);
  SS:= S; // Avoid #0 limit !!
  while ((S - SS) < L) do
  begin
    if S^ in HTTPAllowed then
      R^:=S^
    else if (S^=' ') then
      R^:='+'
    else begin
      R^:= '%';
      H:= HexStr(Ord(S^), 2);
      Inc(R);
      R^:= H[1];
      Inc(R);
      R^:= H[2];
    end;
    Inc(R);
    Inc(S);
  end;
  SetLength(Result, R - PChar(Result));
end;

function HTTPDecode(const AStr: String): String;
var
  S, SS, R: PChar;
  H: String[3];
  L, C: Integer;
begin
  L:= Length(AStr);
  SetLength(Result, L);
  if (L = 0) then
    exit;
  S:= PChar(AStr);
  SS:= S;
  R:= PChar(Result);
  while (S - SS) < L do
  begin
    case S^ of
      '+': R^:= ' ';
      '%':
        begin
          Inc(S);
          if ((S - SS) < L) then
          begin
            if (S^ = '%') then
              R^:= '%'
            else begin
              H:= '$00';
              H[2]:= S^;
              Inc(S);
              if (S - SS) < L then
              begin
                H[3]:= S^;
                Val(H, PByte(R)^, C);
                if (C <> 0) then
                  R^:= ' ';
              end;
            end;
          end;
        end;
    else
      R^:= S^;
    end;
    Inc(R);
    Inc(S);
  end;
  SetLength(Result, R - PChar(Result));
end;

constructor THTTPThread.Create(AHTTP: THTTP);
begin
  inherited Create(true);
  FreeOnTerminate:= true;
  HTTPSend:= THTTPSend.Create;
  HTTPSend.UserAgent:= AHTTP.UserAgent;
  HTTPSend.MimeType:= AHTTP.MimeType;
  case AHTTP.Method of
    mGet: FMethod:= 'GET';
    mPost: FMethod:= 'POST';
    mHead: FMethod:= 'HEAD';
  end;
  FURL:= AHTTP.URL;
  FResponse:= AHTTP.OnResponse;
end;

procedure THTTPThread.DoResponse;
var
  SS: TStringList;
  S: String;
begin
  if Assigned(FResponse) then
  begin
    SS:= TStringList.Create;
    try
      SS.LoadFromStream(HTTPSend.Document);
      S:= SS.Text;
    finally
      SS.Free;
    end;
    FResponse(HTTPSend.ResultCode, S);
  end;
end;

procedure THTTPThread.Execute;
var
 S: string;
begin
  try
    HTTPSend.HTTPMethod(FMethod, FURL);
    Synchronize(@DoResponse);
  finally
    HTTPSend.Free;
  end;
end;

function THTTP.ProtoToStr(AProto: TProtocol): String;
begin
  Result:= EmptyStr;
  if AProto = pHttp then Result:= 'http';
  if AProto = pHttps then Result:= 'https';
end;

procedure THTTP.SetContents(AContents: string);
begin
  FContents:= HTTPEncode(AContents);
end;

function THTTP.GetContents: String;
begin
  Result:= HTTPDecode(FContents);
end;

function THTTP.GetURL: String;
begin
  Result:= ProtoToStr(FProto) + '://' + FHost;
  if (FPort >= 0) then Result:= Result + ':' + IntToStr(FPort);
  if (FPath <> EmptyStr) then Result:= Result + '/' + FPath;
end;

procedure THTTP.SetURL(AURL: string);
var
  i: integer;
  prot, host, port: String;
begin
  prot:= EmptyStr;
  host:= EmptyStr;
  port:= EmptyStr;
  // Find protocol part
  i:= Pos('://', AURL);
  if i > 0 then
  begin
    prot:= Copy(AURL, 1, i - 1);
    Delete(AURL, 1, i);
  end;
  // trim trailing slashes
  while (Length(AURL) > 0) and (AURL[1] = '/') do Delete(AURL, 1, 1);
  // find host part
  i:= Pos('/', AURL);
  if i > 0 then
  begin
    host:= Copy(AURL, 1, i - 1);
    Delete(AURL, 1, i);
  end else
  begin
    host:= AURL;
    AURL:= EmptyStr;
  end;
  // find port part
  i:= Pos(':', host);
  if i > 0 then
  begin
    port:= Copy(host, i + 1, Length(host) - i + 1);
    host:= Copy(host, 1, i - 1);
  end;
  // trim trailing slashes
  while (Length(AURL) > 0) and (AURL[1] = '/') do Delete(AURL, 1, 1);
  // trim double slashes
  i:= 1;
  while i < Length(AURL) do
  begin
    if (AURL[i] = '/') and (AURL[i + 1] = '/')
      then Delete(AURL, i, 1)
      else inc(i);
  end;
  FProto:= pUndef;
  if SameText(prot, 'http') then FProto:= pHttp;
  if SameText(prot, 'https') then FProto:= pHttps;
  FPort:= -1;
  if port <> EmptyStr then FPort:= StrToInt(port);
  FHost:= host;
  FPath:= AURL;
end;

procedure THTTP.SendRequest;
begin
  HTTPThread:= THTTPThread.Create(Self);
  try
    HTTPThread.Resume;
  except
    raise;
  end;
end;

constructor THTTP.Create;
begin
  inherited Create;
  FMethod := mGet;
  FProto := pUndef;
  FHost:= EmptyStr;
  FPath:= EmptyStr;
  FContents:= EmptyStr;
  FPort:= -1;
end;

destructor THTTP.Destroy;
begin
  inherited Destroy;
end;

end.

