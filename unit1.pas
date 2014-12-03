unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, strutils, httpsend, Unit2;

const
  MINCOUNT = 5;
  MAXCOUNT = 15;
  // category=399
  ITCatArray: array [0..50, 0..1] of ShortString = (
  ('6', 'Core - Directory Services - Active Directory'),
  ('9', 'Core - Directory Services - NIS'),
  ('169', 'Core - Doc & Comm - Instant Messaging'),
  ('170', 'Core - Doc & Comm - Synopsys Alert System'),
  ('15', 'Core - Email Maintenance - MS Exchange'),
  ('17', 'Core - Email Maintenance - Sympa'),
  ('18', 'Core - Misc. Services - Console System'),
  ('19', 'Core - Misc. Services - DHCP Server Admin'),
  ('198', 'Core - Misc. Services - Samba File Server Administration'),
  ('199', 'Core - Misc. Services - Time Synchronization'),
  ('22', 'Core - Monitoring - Nagios System Admin'),
  ('23', 'Core - Printing - UNIX'),
  ('24', 'Core - Printing - Windows'),
  ('50', 'Data Center - DCO Support - Physical Install'),
  ('52', 'Data Center - DCO Support - Server Moves'),
  ('55', 'Engineering - Compute Farms - SGE Administration'),
  ('57', 'Engineering - Depot/Lic/Tool - EDA Tools'),
  ('59', 'Engineering - Depot/Lic/Tool - License Key Updates'),
  ('62', 'Engineering - DPS Ops - Connected'),
  ('63', 'Engineering - DPS Ops - Disk-Based'),
  ('68', 'Engineering - Linux Admin - Linux HW Evaluations'),
  ('69', 'Engineering - Linux Admin - Linux OS Evaluations'),
  ('71', 'Engineering - Storage - Storage Admin'),
  ('81', 'Engineering - Windows Admin - Virtual Machines'),
  ('90', 'Network - LAN/WAN - Video Conference'),
  ('91', 'Network - LAN/WAN - WAN/LAN'),
  ('92', 'Network - LAN/WAN - Wireless'),
  ('290', 'Networking - Audio/Video - Troubleshooting/Set-up'),
  ('93', 'Security - Security Requests - Access Requirements'),
  ('171', 'Security - Security Requests - Investigations'),
  ('96', 'Security - Security Requests - Password Mgmt'),
  ('176', 'Security - Support - Network Support'),
  ('244', 'Security-Security Requests-Encryption Management'),
  ('99', 'Support - Application - Blackberry'),
  ('102', 'Support - Application - CCT'),
  ('108', 'Support - Application - Office Applications'),
  ('115', 'Support - Application - Web Applications'),
  ('131', 'Support - General - CCT Customer Support'),
  ('282', 'Support - General - ESS Engineering Support'),
  ('135', 'Support - General - Hp/Sun/AIX Support'),
  ('136', 'Support - General - Machine Deploy/Tech Refresh'),
  ('286', 'Support - General - Mobile Computing'),
  ('139', 'Support - General - Software Development'),
  ('283', 'Support - General - Storage & Data Protection'),
  ('143', 'Support - General - Technology Evaluation'),
  ('142', 'Support - General - Technical Documentation'),
  ('281', 'Support - General - Windows Support'),
  ('145', 'Support - Monitoring & Web - BRM'),
  ('146', 'Support - Monitoring & Web - CSMON/DSMON'),
  ('148', 'Support - Monitoring & Web - FSMON'),
  ('151', 'Support - Monitoring & Web - VigilGuard')
  );

  // category=402
  WorkCatArray: array [0..2, 0..1] of ShortString = (
  ('7', 'Email (Read/Write)'),
  ('21', 'Employee Management)'),
  ('6', 'Meetings & Presentations')
  );


type

  TPrioRecord = record
    cat_: ShortString;
    prio_: integer;
  end;

  TCategoryRecord = record
    id_: ShortString;
    days_: array [0..4] of ShortString;
  end;

  { TForm1 }
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    LabeledEdit1: TLabeledEdit;
    LabeledEdit2: TLabeledEdit;
    Memo1: TMemo;
    Panel1: TPanel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
    HTTP: THTTPSend;
    Cookies: TStrings;
    ids: TStrings;
    cats: Array of TPrioRecord;
    SelectedCats: Array of TCategoryRecord;
    sts : TStrings;
    function GenerateLoginContent: String;
    function ReadSection(AStrings: TStrings; ASection: String): String;
    procedure SendRequest(ALocation: String);
    procedure SendLoginPassword(ALocation: String);
    procedure DoMoved;
    procedure LoadIds;
    procedure LoadCats;
    procedure SortCats;
    procedure CalcTimes(Count: integer);
    procedure GenerateRequests;
    procedure SendTimecards(ALocation: String);
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

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

{ TForm1 }

function TForm1.GenerateLoginContent: String;
begin
  Result:= 'timeZone=+4:00&j_username=' + HTTPEncode(Trim(LabeledEdit1.Text)) +
           '&j_password=' + HTTPEncode(Trim(LabeledEdit2.Text)) +
           '&wsdk-button__logon_=Login';
end;

function TForm1.ReadSection(AStrings: TStrings; ASection: String): String;
var
  i: integer;
  p: integer;
begin
  Result:= EmptyStr;
  for i:= 0 to AStrings.Count - 1 do
  begin
    p:= Pos(ASection, UpperCase(AStrings[i]));
    if p > 0 then
    begin
      Result:= Trim(Copy(AStrings[i], p + Length(ASection), Length(AStrings[i]) - p - Length(ASection) + 1));
      Break;
    end;
  end;
end;

procedure TForm1.SendRequest(ALocation: String);
begin
  Memo1.Lines.Add('GET ' + ALocation);
  Form1.Update;
  HTTP.Clear;
  HTTP.Cookies.Assign(Cookies);
  HTTP.HTTPMethod('GET', ALocation);
  Cookies.Assign(HTTP.Cookies);
  Memo1.Lines.Add(IntToStr(HTTP.ResultCode) + ' : ' + HTTP.ResultString);
end;

procedure TForm1.SendTimecards(ALocation: String);
begin
  Memo1.Lines.Add('GET ' + ALocation);
  Form1.Update;
  HTTP.Clear;
  HTTP.Cookies.Assign(Cookies);
  HTTP.HTTPMethod('GET', ALocation);
  Cookies.Assign(HTTP.Cookies);
  Memo1.Lines.Add(IntToStr(HTTP.ResultCode) + ' : ' + HTTP.ResultString);
end;

procedure TForm1.SendLoginPassword(ALocation: String);
var
  S: TStringStream;
begin
  Memo1.Lines.Add('POST ' + ALocation);
  Form1.Update;
  HTTP.Clear;
  HTTP.MimeType:= 'application/x-www-form-urlencoded';
  HTTP.Cookies.Assign(Cookies);
  S:= TStringStream.Create(GenerateLoginContent);
  try
    try
      HTTP.Document.LoadFromStream(S);
    except
      raise;
    end;
  finally
    S.Free;
  end;
  HTTP.HTTPMethod('POST', ALocation);
  Cookies.Assign(HTTP.Cookies);
  Memo1.Lines.Add(IntToStr(HTTP.ResultCode) + ' : ' + HTTP.ResultString);
end;

procedure TForm1.DoMoved;
var
  NextLocation: String;
begin
  NextLocation:= ReadSection(HTTP.Headers, 'LOCATION:');
  if (NextLocation <> EmptyStr) then
  begin
    Memo1.Lines.Add('GET ' + NextLocation);
    Form1.Update;
    HTTP.Clear;
    HTTP.MimeType:= 'text/html';
    HTTP.Cookies.Assign(Cookies);
    HTTP.HTTPMethod('GET', NextLocation);
    Cookies.Assign(HTTP.Cookies);
    Memo1.Lines.Add(IntToStr(HTTP.ResultCode) + ' : ' + HTTP.ResultString);
  end;
end;

procedure TForm1.LoadIds;
var
  i : integer;
  s, beg : ansistring;
  t : TStringList;
begin
  t := TStringList.Create;
  try
    try
      t.LoadFromStream(HTTP.Document);
      beg := '      <span class="actions"><a href="/itm/timecarding/timecard.do?action=edit&amp;id=';
      for i := 0 to t.Count - 2 do
        if strutils.LeftStr(t[i], length(beg)) = beg then
        begin
          s:= strutils.ExtractWord (8, t[i], [' ', '=', '"']);
          ids.Add(s);
        end;
    except
      raise;
    end;
  finally
    t.Free;
  end;
end;

procedure TForm1.LoadCats;
var
  i: integer;
  F: TextFile;
  s: string;
begin
  if FileExists('./' + Trim(Form1.LabeledEdit1.Text)) then
  begin
    AssignFile(F, './' + Trim(Form1.LabeledEdit1.Text));
    Reset(F);
    i:= 0;
    while not Eof(F) do
    begin
      Readln(F, s);
      cats[i].prio_:= StrToInt(s);
      cats[i].cat_:= ITCatArray[i, 0];
      inc(i);
    end;
    CloseFile(F);
  end else
    for i:= 0 to Length(ITCatArray) - 1 do
    begin
      cats[i].prio_:= 0;
      cats[i].cat_:= ITCatArray[i, 0];
    end;
end;

procedure TForm1.SortCats;
var
  b: boolean;
  i, j: integer;
  newarr: array of TPrioRecord;
  max_, max_ind: integer;
begin
  b:= True;
  SetLength(newarr, Length(cats));
  j:= 0;
  while b do
  begin
    max_:= -1;
    max_ind:= -1;
    for i:= 0 to Length(cats) - 1 do
      if cats[i].prio_ > max_ then
      begin
        max_:= cats[i].prio_;
        max_ind:= i;
      end;
    if max_ = -1
      then b:= false
      else begin
        newarr[j].prio_:= cats[max_ind].prio_;
        newarr[j].cat_:= cats[max_ind].cat_;
        cats[max_ind].prio_:= -1;
      end;
    inc(j);
  end;
  cats:= newarr;
  SetLength(newarr, 0);
end;

procedure TForm1.CalcTimes(Count: integer);

  function GetMax(var a: array of integer): integer;
  var
    i: integer;
    m, c: integer;
  begin
    m:= a[0];
    c:= 0;
    for i:= 1 to Length(a) - 1 do
      if a[i] > m then
      begin
        m:= a[i];
        c:= i;
      end;
    a[c]:= 0;
    Result:= m;
  end;

  function GetZero(var a: array of integer): integer;
  var
    i: integer;
    c1, c2: integer;
  begin
    Result:= 0;
    c1:= -1;
    c2:= -1;
    for i:= 0 to Length(a) - 1 do
      if a[i] > 0 then
      begin
        c1:= i;
        break;
      end;
    for i:= 0 to Length(a) - 1 do
      if (a[i] > 0) and (i <> c1) then
      begin
        c2:= i;
        break;
      end;
    if (c1 >= 0) and (c2 >= 0) then
    begin
      a[c2]:= a[c1] + a[c2];
      a[c1]:= 0;
    end else
      Result:= GetMax(a);
  end;

var
  i, j, rd, rest, f : integer;
  d: array of integer;
begin
  SetLength(SelectedCats, Count);
  SetLength(d, Count);
  for i:= 0 to Count - 1 do
  begin
    SelectedCats[i].id_:= cats[i].cat_;
    for j:= 0 to 4 do
      SelectedCats[i].days_[j]:= EmptyStr;
  end;
  for i:= 0 to 4 do
  begin
    rest:= 70;
    rd:= rest div count;
    for j:= 0 to Count - 2 do
    begin
      d[j]:= Random(rd);
      if d[j] <= rd div 2 then d[j]:= d[j] + rd;
      if d[j] > rest then d[j]:= rest;
      rest:= rest - d[j];
    end;
    d[Count - 1]:= rest;
    for j:= 0 to Count - 1 do
    begin
      f:= Random(100);
      if f < 90
        then SelectedCats[j].days_[i]:= FormatFloat('0.0', GetMax(d) / 10)
        else SelectedCats[j].days_[i]:= FormatFloat('0.0', GetZero(d) / 10);
    end;
  end;
end;

procedure TForm1.GenerateRequests;
var
  s : string;
  i, j : integer;
  delta, Count_: integer;
begin
  sts.Clear;

  for i := 0 to ids.Count - 2 do begin
    delta:= Random(MAXCOUNT - MINCOUNT + 1);
    Count_:= MINCOUNT + delta;
    CalcTimes(Count_);
    s := 'http://itmdbapp.company.com:8080/itm/timecarding/timecard.do?action=saveSubmit&id=' +
         ids[i] + '&worker=Chilingaryan%2C+Norayr&startDate=4%2F17%2F10&endDate=4%2F23%2F10&workWeek=40&minWeek=40&maxWeek=168&projectWeek=40&enforceMinWeek=false&enforceMaxWeek=false&returnForward=&wasEditedByOther=false&approvalStatus=Open&approvalComments=';
    // Reading Email 0.5 Hours
    s := s + '&category=402&activityId=7&projectId=&projectResourceTaskId=&itServiceId=&itServiceResourceTaskId=&appInstanceId=&appInstanceResourceTaskId=&assetId=&assetResourceTaskId=' +
             '&hours0=&hours1=&hours2=0.5&hours3=0.5&hours4=0.5&hours5=0.5&hours6=0.5&percentCompleteNumberString=100&comments=';
    // On Call Support 0.5 Hours
    s := s + '&category=399&activityId=2&projectId=&projectResourceTaskId=&itServiceId=138&itServiceResourceTaskId=&appInstanceId=&appInstanceResourceTaskId=&assetId=&assetResourceTaskId=' +
             '&hours0=&hours1=&hours2=0.5&hours3=0.5&hours4=0.5&hours5=0.5&hours6=0.5&percentCompleteNumberString=100&comments=';
    for j:= 0 to Length(SelectedCats) - 1 do
    begin
      s := s + '&category=399&activityId=2&projectId=&projectResourceTaskId=&itServiceId=' +
               SelectedCats[j].id_ + '&itServiceResourceTaskId=&appInstanceId=&appInstanceResourceTaskId=&assetId=&assetResourceTaskId=' +
               '&hours0=&hours1=&hours2=' + SelectedCats[j].days_[0] +
               '&hours3=' + SelectedCats[j].days_[1] +
               '&hours4=' + SelectedCats[j].days_[2] +
               '&hours5=' + SelectedCats[j].days_[3] +
               '&hours6=' + SelectedCats[j].days_[4] + '&percentCompleteNumberString=100&comments=';
    end;
    sts.Add(s);
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  Location: String;
  i, ind: integer;
  F: File of Integer;
begin
  if Trim(LabeledEdit1.Text) = EmptyStr then
  begin
    ShowMessage('Username is empty');
    Exit;
  end;
  if FileExists('./' + Trim(Form1.LabeledEdit1.Text)) then
  begin
    AssignFile(F, './' + Trim(Form1.LabeledEdit1.Text));
    Reset(F);
    i:= 0;
    while not Eof(F) do
    begin
      Read(F, ind);
      Form2.Priorities[i].ItemIndex:= ind;
      inc(i);
    end;
    CloseFile(F);
  end else
  begin
    ShowMessage('Configuration is empty');
    Exit;
  end;
  Memo1.Lines.Clear;
  HTTP:= THTTPSend.Create;
  HTTP.UserAgent:= 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:14.0) Gecko/20100101 Firefox/14.0.1';
  Cookies:= TStringList.Create;
  ids:= TStringList.Create;
  sts:= TStringList.Create;
  SetLength(cats, Length(ITCatArray));
  try
    try
      Memo1.Lines.Add('Get Login Screen...');
      Location:= 'http://itm.company.com';
      SendRequest(Location);
      while (HTTP.ResultCode = 301) or (HTTP.ResultCode = 302) do
        DoMoved;
      Memo1.Lines.Add('Send Login and Password...');
      Location:= 'http://itmdbapp.company.com:8080/itm/j_security_check';
      SendLoginPassword(Location);
      while (HTTP.ResultCode = 301) or (HTTP.ResultCode = 302) do
        DoMoved;
      Memo1.Lines.Add('Get Timecards...');
      Location:= 'http://itmdbapp.company.com:8080/itm/timecarding/myTimecards.do?action=view';
      SendRequest(Location);
      Randomize;
      LoadIds;
      LoadCats;
      SortCats;
      GenerateRequests;
      for i:= 0 to sts.Count - 3 do
        SendTimecards(sts[i]);
      ShowMessage('Done');
    except
      on E: Exception do
        ShowMessage(E.Message);
    end;
  finally
    ids.Free;
    sts.Free;
    Cookies.Free;
    SetLength(cats, 0);
    SetLength(SelectedCats, 0);
    HTTP.Free;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  if Trim(LabeledEdit1.Text) = EmptyStr
    then ShowMessage('Username is empty')
    else Form2.ShowModal;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  Memo1.Lines.Clear;
  LabeledEdit1.Text:= EmptyStr;
  LabeledEdit2.Text:= EmptyStr;
end;

end.

