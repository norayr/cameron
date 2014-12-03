unit Unit2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls;

type
  { TForm2 }

  TForm2 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Panel1: TPanel;
    ScrollBox1: TScrollBox;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    Categories: array of TLabel;
    Priorities: array of TComboBox;
    { public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.lfm}

uses
  Unit1;
{ TForm2 }

procedure TForm2.FormShow(Sender: TObject);
var
  i: integer;
  F: TextFile;
  s: string;
begin
  if FileExists('./' + Trim(Form1.LabeledEdit1.Text)) then
  begin
    AssignFile(F, './' + Trim(Form1.LabeledEdit1.Text));
    Reset(F);
    try
      i:= 0;
      while not Eof(F) do
      begin
        ReadLn(F, s);
        Priorities[i].ItemIndex:= StrToInt(s);
        inc(i);
      end;
    finally
      CloseFile(F);
    end;
  end else
    for i:= 0 to Length(ITCatArray) - 1 do
      Priorities[i].ItemIndex:= 0;
end;

procedure TForm2.Button1Click(Sender: TObject);
var
  i: integer;
  F: TextFile;
begin
  AssignFile(F, './' + Trim(Form1.LabeledEdit1.Text));
  Rewrite(F);
  try
    for i:= 0 to Length(Priorities) - 1 do
      Writeln(F, IntToStr(Priorities[i].ItemIndex));
  finally
    CloseFile(F);
  end;
  Close;
end;

procedure TForm2.Button2Click(Sender: TObject);
begin
  Close;
end;

procedure TForm2.FormCreate(Sender: TObject);
var
  i: integer;
begin
  SetLength(Categories, Length(ITCatArray));
  SetLength(Priorities, Length(ITCatArray));
  for i:= 0 to Length(ITCatArray) - 1 do
  begin
    Categories[i]:= TLabel.Create(Self);
    with Categories[i] do
    begin
      Left:= 10;
      Top:= i*25;
      Width:= 350;
      AutoSize:= False;
      Caption:= ITCatArray[i, 1];
      Parent:= ScrollBox1;
    end;
    Priorities[i]:= TComboBox.Create(Self);
    with Priorities[i] do
    begin
      Left:= 370;
      Top:= i*25;
      Width:= 40;
      Style:= csDropDownList;
      Items.Add('0');
      Items.Add('1');
      Items.Add('2');
      Items.Add('3');
      Items.Add('4');
      Items.Add('5');
      Items.Add('6');
      Items.Add('7');
      Items.Add('8');
      Items.Add('9');
      Items.Add('10');
      ItemIndex:= 0;
      Parent:= ScrollBox1;
    end;
  end;
end;

end.

