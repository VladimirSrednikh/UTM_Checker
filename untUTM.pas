unit untUTM;

interface

uses
  System.SysUtils, System.StrUtils, System.Classes,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, IdURI;

procedure Init;

procedure GetUtmDates(AUrl: string; var ARSADate: TDate; var AGOSTDate: TDate);


implementation

procedure Init;
begin
//  MessageText := GetParamVal('/MessageText=');
//  MessageText := ReplaceText(MessageText, '\n', sLineBreak);
//  FreeSpace := StrToInt64Def(GetParamVal('/FreeSpace='), 500);
//  DriveMinSize := StrToInt64Def(GetParamVal('/DriveMinSize='), 0);
end;

function RfcTimeToDateTime(const dt_str: string): TDateTime;
const
  Months: array[0..11] of string = ('jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec');
var
  dateArr: TArray<string>;
  dd, mm, yy: Word;
  tm: TTime;
begin
  if dt_str = '' then
    raise Exception.Create('Ошибка при конвертировании: нет данных');

  dateArr := dt_str.Split([' ']);
  mm := IndexText(dateArr[1], Months) + 1;
  dd := StrToInt(dateArr[2]);
  yy := StrToInt(dateArr[5]);
  tm := StrToTime(dateArr[3]);
  Result := EncodeDate(yy, mm, dd) + tm;
end;

function GetCertValiditySubstr(const APage: string): string;
var
  StartPos, EndPos: Integer;
  res: string;
begin
  StartPos := Pos('Validity:', APage);
  EndPos := PosEx(']', APage, StartPos);
  if (StartPos > 0) and (EndPos > 0) then
  begin
    StartPos := PosEx('[', APage, StartPos);
    if StartPos = 0 then
      Exit('');
    res := Copy(APage, StartPos + 1, EndPos - StartPos - 1);
    StartPos := PosEx('To:', res);
    if StartPos = 0 then
      Exit('');
    Result := Trim(Copy(res, StartPos + Length('To:'), Length(res)));
  end;
end;

procedure GetUtmDates(AUrl: string; var ARSADate: TDate; var AGOSTDate: TDate);
var
  url: TIdURI;
  str: string;
  idhtp1: TIdHTTP;
  Resp: TStringStream;
begin
  url := nil;
  Resp := nil;
  idhtp1 := nil;
  try
    if not StartsText('http', AUrl) then
      AUrl := 'http://' + AUrl;

    url := TIdURI.Create(AUrl);

    idhtp1 := TIdHTTP.Create(nil);

    url.Path := '/info/certificate/RSA';
    Resp := TStringStream.Create;
    idhtp1.Get(url.GetFullURI(), Resp);
    str := GetCertValiditySubstr(Resp.DataString);
    ARSADate := RfcTimeToDateTime(str);

    url.Path := '/info/certificate/GOST';
    Resp := TStringStream.Create;
    idhtp1.Get(url.GetFullURI(), Resp);
    str := GetCertValiditySubstr(Resp.DataString);
    AGOSTDate := RfcTimeToDateTime(str);

  finally
    url.Free;
    Resp.Free;
    idhtp1.Free;
  end;
end;

end.
