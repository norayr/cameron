uses Classes, SysUtils, html;
const timecards='myTimecards.do.htm';
type col = array [0..8] of string;

function gettime(): extended;
begin
repeat
   gettime := Random;
until gettime <= 0.5
end;//gettime

function fmt(a : extended) : string;
begin
fmt := sysutils.formatfloat('0.#',a);
end;

procedure column(var day : col);
var h, j, k : integer;
o, p : extended;
begin
// 0, 1, 2  -> 1 hour
// 4, 8 ->     1 hour
// 3, 5, 6, 7 -> 6 hours
o := gettime();
p := gettime();
day[0] := fmt(o); 
day[1] := fmt(p); 
day[2] := fmt(1 - strtofloat(day[0]) - strtofloat(day[1])  { - o - p});
h := Random(3);
j := Random(3);
k := Random(3);
day[3] := Sysutils.IntToStr(h);
day[5] := Sysutils.IntToStr(j);
day[6] := Sysutils.IntToStr(k);
day[7] := Sysutils.IntToStr(6 - h - j - k);
p := gettime();
day[4] := fmt(p);

day[8] := fmt(1 - strtofloat(day[4]){- p});
end;//column

procedure a;
var ids : TStringList;
sts : TStringList;
s : string; 
i : integer;
mon, tue, wed, thr, fri : col;
begin
//Category='Other Work' Name='Email (Read/Write)'
//Category='IT Service' Name='Engineering - Compute Farms - SGE Administration'
//Category='IT Service' Name='Engineering - Linux Admin - Linux OS Evaluations'
//Category='IT Service' Name='Engineering - Generic - R&D Consulting/Analysis'
//Category='IT Service' Name='Engineering - Storage - Storage Admin'
//Category='IT Service' Name='Support - General - On Call Support'
//Category='IT Service' Name='Support - General - CCT Customer Support'
//Category='IT Service' Name='Support - General - ESS Engineering Support'
//Category=;IT Service' Name='Core - Directory Services - NIS'

s := 'go ("http://itmdbapp.company.com:8080/itm/timecarding/timecard.do?action=saveSubmit&id=';
   ids := html.GetIdsFromFile(timecards{'timecard.do.html'});
   sts := TStringList.Create;
   for i := 0 to ids.Count - 2 do begin
      column(mon);
      column(tue);
      column(wed);
      column(thr);
      column(fri);
      sts.Add(s);
      sts[i] := sts[i] + ids[i];
      sts[i] := sts[i] + '&worker=Chilingaryan%2C+Norayr&startDate=4%2F17%2F10&endDate=4%2F23%2F10&workWeek=40&minWeek=40&maxWeek=168&projectWeek=40&enforceMinWeek=false&enforceMaxWeek=false&returnForward=&wasEditedByOther=false&approvalStatus=Open&approvalComments=';
      sts[i] := sts[i] + '&category=402&activityId=7&projectId=&projectResourceTaskId=&itServiceId=&itServiceResourceTaskId=&appInstanceId=&appInstanceResourceTaskId=&assetId=&assetResourceTaskId=';
      sts[i] := sts[i] + '&hours0=&hours1=&hours2='+mon[0]+'&hours3='+tue[0]+'&hours4='+wed[0]+'&hours5='+thr[0]+'&hours6='+fri[0];
      sts[i] := sts[i] + '&percentCompleteNumberString=100&comments=';
      sts[i] := sts[i] + '&category=399&activityId=2&projectId=&projectResourceTaskId=';
      sts[i] := sts[i] + '&itServiceId=55';
      sts[i] := sts[i] + '&itServiceResourceTaskId=&appInstanceId=&appInstanceResourceTaskId=&assetId=&assetResourceTaskId=';
      sts[i] := sts[i] + '&hours0=&hours1=&hours2='+mon[1]+'&hours3='+tue[1]+'&hours4='+wed[1]+'&hours5='+thr[1]+'&hours6='+fri[1];
      sts[i] := sts[i] + '&percentCompleteNumberString=100&comments=';
      sts[i] := sts[i] + '&category=399&activityId=2&projectId=&projectResourceTaskId=';
      sts[i] := sts[i] + '&itServiceId=69';
      sts[i] := sts[i] + '&itServiceResourceTaskId=&appInstanceId=&appInstanceResourceTaskId=&assetId=&assetResourceTaskId=';
      sts[i] := sts[i] + '&hours0=&hours1=&hours2='+mon[2]+'&hours3='+tue[2]+'&hours4='+wed[2]+'&hours5='+thr[2]+'&hours6='+fri[2];
      sts[i] := sts[i] + '&percentCompleteNumberString=100&comments=';
      sts[i] := sts[i] + '&category=399&activityId=2&projectId=&projectResourceTaskId=';
      sts[i] := sts[i] + '&itServiceId=67';
      sts[i] := sts[i] + '&itServiceResourceTaskId=&appInstanceId=&appInstanceResourceTaskId=&assetId=&assetResourceTaskId=';
      sts[i] := sts[i] + '&hours0=&hours1=&hours2='+mon[3]+'&hours3='+tue[3]+'&hours4='+wed[3]+'&hours5='+thr[3]+'&hours6='+fri[3];
      sts[i] := sts[i] + '&percentCompleteNumberString=100&comments=';
      sts[i] := sts[i] + '&category=399&activityId=2&projectId=&projectResourceTaskId=';
      sts[i] := sts[i] + '&itServiceId=71';
      sts[i] := sts[i] + '&itServiceResourceTaskId=&appInstanceId=&appInstanceResourceTaskId=&assetId=&assetResourceTaskId=';
      sts[i] := sts[i] + '&hours0=&hours1=&hours2='+mon[4]+'&hours3='+tue[4]+'&hours4='+wed[4]+'&hours5='+thr[4]+'&hours6='+fri[4];
//      sts[i] := sts[i] + '&hours0=&hours1=&hours2=0.5&hours3=0.5&hours4=0.5&hours5=0.5&hours6=0.5';
      sts[i] := sts[i] + '&percentCompleteNumberString=100&comments=';
      sts[i] := sts[i] + '&category=399&activityId=2&projectId=&projectResourceTaskId=';
      sts[i] := sts[i] + '&itServiceId=138';
      sts[i] := sts[i] + '&itServiceResourceTaskId=&appInstanceId=&appInstanceResourceTaskId=&assetId=&assetResourceTaskId=';
      sts[i] := sts[i] + '&hours0=&hours1=&hours2='+mon[5]+'&hours3='+tue[5]+'&hours4='+wed[5]+'&hours5='+thr[5]+'&hours6='+fri[5];
//      sts[i] := sts[i] + '&hours0=&hours1=&hours2=1&hours3=2&hours4=1&hours5=1&hours6=2';
      sts[i] := sts[i] + '&percentCompleteNumberString=100&comments=';
      sts[i] := sts[i] + '&category=399&activityId=2&projectId=&projectResourceTaskId=';
      sts[i] := sts[i] + '&itServiceId=131';
      sts[i] := sts[i] + '&itServiceResourceTaskId=&appInstanceId=&appInstanceResourceTaskId=&assetId=&assetResourceTaskId=';
      sts[i] := sts[i] + '&hours0=&hours1=&hours2='+mon[6]+'&hours3='+tue[6]+'&hours4='+wed[6]+'&hours5='+thr[6]+'&hours6='+fri[6];
//      sts[i] := sts[i] + '&hours0=&hours1=&hours2=2&hours3=1&hours4=2&hours5=2&hours6=1';
      sts[i] := sts[i] + '&percentCompleteNumberString=100&comments=';
      sts[i] := sts[i] + '&category=399&activityId=2&projectId=&projectResourceTaskId=';
      sts[i] := sts[i] + '&itServiceId=282';
      sts[i] := sts[i] + '&itServiceResourceTaskId=&appInstanceId=&appInstanceResourceTaskId=&assetId=&assetResourceTaskId=';
      sts[i] := sts[i] + '&hours0=&hours1=&hours2='+mon[7]+'&hours3='+tue[7]+'&hours4='+wed[7]+'&hours5='+thr[7]+'&hours6='+fri[7];      
//      sts[i] := sts[i] + '&hours0=&hours1=&hours2=1&hours3=2&hours4=2&hours5=1&hours6=1';
      sts[i] := sts[i] + '&percentCompleteNumberString=100&comments=';
      sts[i] := sts[i] + '&category=399&activityId=2&projectId=&projectResourceTaskId=';
      sts[i] := sts[i] + '&itServiceId=9';
      sts[i] := sts[i] + '&itServiceResourceTaskId=&appInstanceId=&appInstanceResourceTaskId=&assetId=&assetResourceTaskId=';
      sts[i] := sts[i] + '&hours0=&hours1=&hours2='+mon[8]+'&hours3='+tue[8]+'&hours4='+wed[8]+'&hours5='+thr[8]+'&hours6='+fri[8];
//      sts[i] := sts[i] + '&hours0=&hours1=&hours2=0.5&hours3=0.5&hours4=0.5&hours5=0.5&hours6=0.5';
      sts[i] := sts[i] + '&percentCompleteNumberString=100&comments=';
      sts[i] := sts[i] + '&category=&activityId=&projectId=&projectResourceTaskId=';
      sts[i] := sts[i] + '&itServiceId=';
      sts[i] := sts[i] + '&itServiceResourceTaskId=&appInstanceId=&appInstanceResourceTaskId=&assetId=&assetResourceTaskId=';
      sts[i] := sts[i] + '&hours0=&hours1=&hours2=&hours3=&hours4=&hours5=&hours6=';
      sts[i] := sts[i] + '&percentCompleteNumberString=&comments=';
      sts[i] := sts[i] + '&category=&activityId=&projectId=&projectResourceTaskId=';
      sts[i] := sts[i] + '&itServiceId=';
      sts[i] := sts[i] + '&itServiceResourceTaskId=&appInstanceId=&appInstanceResourceTaskId=&assetId=&assetResourceTaskId=';
      sts[i] := sts[i] + '&hours0=&hours1=&hours2=&hours3=&hours4=&hours5=&hours6=';
      sts[i] := sts[i] + '&percentCompleteNumberString=&comments=&timecardComments=';
      sts[i] := sts[i] + '")';
      
      writeln (sts[i]);
      //sts.Add ('sleep (5)');
      writeln ('sleep (7)');
   end;
end;



begin
Randomize;
a;




end.
