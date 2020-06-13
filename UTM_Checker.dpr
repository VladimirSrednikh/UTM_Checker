program UTM_Checker;

uses
  System.SysUtils,
  System.StrUtils,
  WinAPI.Windows,
  Vcl.Forms,
  untUTM in 'untUTM.pas',
  untMessageBox in '..\CommonModules\untMessageBox.pas',
  ProjectFuncs in '..\CommonModules\ProjectFuncs.pas';

{$R *.res}

var
  Url, Msg: string;
  DateDiff: Integer;
  RSADate, GOSTDate: TDate;
begin

  Application.Initialize;
  try
    Url := GetParamVal('/url=');
    DateDiff := StrToInt64Def(GetParamVal('/DateDiff='), 7);
    if Url = '' then
      raise Exception.Create('�� ����� ����� ���!');

    GetUtmDates(Url, RSADate, GOSTDate);
    Msg := '';
    if ((Now + DateDiff) > RSADate) then
      Msg := Msg + '���� RSA-����������� ��� ��� �������� � �����: ' + DateTimeToStr(RSADate) + sLineBreak + sLineBreak;
    if ((Now + DateDiff) > GOSTDate) then
      Msg := Msg + '���� GOST-����������� ��� ��� �������� � �����: ' + DateTimeToStr(RSADate);

    ShowCorrectMessageBox(Msg, '��������!', MB_OK + MB_ICONEXCLAMATION);
  except
    on E: Exception do
      ShowCorrectMessageBox('������ ������ � ��� ' + Url + sLineBreak + sLineBreak + E.Message, '������ ������ � ���!', MB_OK + MB_ICONEXCLAMATION);
  end;
  Halt(1);
end.
