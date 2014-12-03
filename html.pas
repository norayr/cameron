Unit html;
interface
uses strutils, Classes;

function GetIdsFromFile(name : string) : TStringList;

implementation


function GenerateIdList (const html : TStringList) : TStringList;
var i : integer;
s, beg : ansistring;
t : TStringList;
begin
t := TStringList.Create;
//beg := '      <span class="actions"><a href="/itm/timecarding/timecard.do?action=edit&amp;id='; 
beg := '      <span class="actions"><a href="http://itmdbapp.company.com:8080/itm/timecarding/timecard.do?action=edit&amp;id=';
for i := 0 to html.Count - 2 do begin
     if strutils.LeftStr(html[i], length(beg)) = beg then begin
         //writeln (html[i]);
        s:= strutils.ExtractWord (8, html[i], [' ', '=', '"']);
         //writeln(s);
	t.Add(s); //writeln (t[t.Count - 1]);
     end;
 end;

GenerateIdList := t;
end; //a

function GetIdsFromFile(name : string) : TStringList;

var s : TStringList;
begin

s := TStringList.Create;
//s.LoadFromFile('timecard.do.html');
s.LoadFromFile(name);
GetIdsFromFile := GenerateIdList(s);

//for i := 0 to s1.Count - 2 do begin writeln (s1[i]) end;

end;

begin
//b



end.
