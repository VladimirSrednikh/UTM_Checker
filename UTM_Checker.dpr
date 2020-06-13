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
      raise Exception.Create('Не задан адрес УТМ!');

    GetUtmDates(Url, RSADate, GOSTDate);
    Msg := '';
    if ((Now + DateDiff) > RSADate) then
      Msg := Msg + 'Срок RSA-сертификата для УТМ подходит к концу: ' + DateTimeToStr(RSADate) + sLineBreak + sLineBreak;
    if ((Now + DateDiff) > GOSTDate) then
      Msg := Msg + 'Срок GOST-сертификата для УТМ подходит к концу: ' + DateTimeToStr(RSADate);

    ShowCorrectMessageBox(Msg, 'Внимание!', MB_OK + MB_ICONEXCLAMATION);
  except
    on E: Exception do
      ShowCorrectMessageBox('Ошибка работы с УТМ ' + Url + sLineBreak + sLineBreak + E.Message, 'Ошибка работы с УТМ!', MB_OK + MB_ICONEXCLAMATION);
  end;
  Halt(1);
end.
