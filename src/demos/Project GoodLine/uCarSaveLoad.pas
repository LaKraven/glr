unit uCarSaveLoad;

interface

uses
  glrMath;

type
  TpdCarInfo = record
    BodyR, BodyD, BodyF,
    WheelRearR, WheelRearD, WheelRearF,
    WheelFrontR, WheelFrontD, WheelFrontF: Single;

    WheelRearOffset, WheelFrontOfsset,
    SuspRearOffset, SuspFrontOffset,
    BodyMassCenterOffset: TdfVec2f;

    WheelRearSize, WheelFrontSize: Single;

    SuspRearLimit, SuspFrontLimit: TdfVec2f;

    SuspRearMotorSpeed, SuspRearMaxMotorForce,
    SuspFrontMotorSpeed, SuspFrontMaxMotorForce: Single;

    MaxMotorSpeed, Acceleration: Single;
    GearCount: Integer;
    Gears: array of Single;
  end;


  TpdCarInfoSaveLoad = class
  public
    class function LoadFromFile(const aFileName: String): TpdCarInfo;
    class procedure SaveToFile(const aFileName: String; aCarInfo: TpdCarInfo);
  end;

implementation

uses
  SysUtils;

{ TpdCarInfoSaveLoad }

class function TpdCarInfoSaveLoad.LoadFromFile(
  const aFileName: String): TpdCarInfo;
var
  f: TextFile;
  i: Integer;

  function GetFloat(): Single;
  var
    tmpStr: String;
  begin
    Readln(f, tmpStr);
    tmpStr := Copy(tmpStr, 0, Pos(';', tmpStr) - 1);
    Result := StrToFloat(tmpStr);
  end;

  function GetInt(): Integer;
  var
    tmpStr: String;
  begin
    Readln(f, tmpStr);
    tmpStr := Copy(tmpStr, 0, Pos(';', tmpStr) - 1);
    Result := StrToInt(tmpStr);
  end;

  function GetVec(): TdfVec2f;
  var
    tmpStr: String;
  begin
    Readln(f, tmpStr);
    tmpStr := Copy(tmpStr, 0, Pos(';', tmpStr) - 1);
    Result.x := StrToFloat(Copy(tmpStr, 0, Pos(' ', tmpStr) - 1));
    Result.y := StrToFloat(Copy(tmpStr, Pos(' ', tmpStr) + 1, Length(tmpStr) - Pos(' ', tmpStr)));
  end;

begin
  with Result do
  begin
    AssignFile(f, aFileName);
    Reset(f);

    BodyR := GetFloat();
    BodyD := GetFloat();
    BodyF := GetFloat();
    WheelRearR := GetFloat();
    WheelRearD := GetFloat();
    WheelRearF := GetFloat();
    WheelFrontR := GetFloat();
    WheelFrontD := GetFloat();
    WheelFrontF := GetFloat();

    WheelRearSize := GetFloat();
    WheelFrontSize := GetFloat();

    WheelRearOffset := GetVec();
    WheelFrontOfsset := GetVec();
    SuspRearOffset := GetVec();
    SuspFrontOffset := GetVec();
    BodyMassCenterOffset := GetVec();

    SuspRearLimit := GetVec();
    SuspFrontLimit := GetVec();

    SuspRearMotorSpeed := GetFloat();
    SuspRearMaxMotorForce := GetFloat();
    SuspFrontMotorSpeed := GetFloat();
    SuspFrontMaxMotorForce := GetFloat();

    MaxMotorSpeed := GetFloat();
    Acceleration := GetFloat();
    GearCount := GetInt();

    SetLength(Gears, GearCount);
    for i := 0 to GearCount - 1 do
      Gears[i] := GetFloat();

    CloseFile(f);
  end;
end;

class procedure TpdCarInfoSaveLoad.SaveToFile(const aFileName: String;
  aCarInfo: TpdCarInfo);
var
  f: TextFile;
  i: Integer;
begin
  AssignFile(f, aFileName);
  Rewrite(f);
  with aCarInfo do
  begin
    WriteLn(f, FloatToStr(BodyR) + ';'#9#9'BodyR');
    WriteLn(f, FloatToStr(BodyD) + ';'#9#9'BodyD');
    WriteLn(f, FloatToStr(BodyF) + ';'#9#9'BodyF');
    WriteLn(f, FloatToStr(WheelRearR) + ';'#9#9'WheelRearR');
    WriteLn(f, FloatToStr(WheelRearD) + ';'#9#9'WheelRearD');
    WriteLn(f, FloatToStr(WheelRearF) + ';'#9#9'WheelRearF');
    WriteLn(f, FloatToStr(WheelFrontR) + ';'#9#9'WheelFrontR');
    WriteLn(f, FloatToStr(WheelFrontD) + ';'#9#9'WheelFrontD');
    WriteLn(f, FloatToStr(WheelFrontF) + ';'#9#9'WheelFrontF');

    WriteLn(f, FloatToStr(WheelRearSize) + ';'#9#9'WheelRearSize');
    WriteLn(f, FloatToStr(WheelFrontSize) + ';'#9#9'WheelFrontSize');

    WriteLn(f, FloatToStr(WheelRearOffset.x) + ' ' + FloatToStr(WheelRearOffset.y) + ';'#9#9'WheelRearOffset');
    WriteLn(f, FloatToStr(WheelFrontOfsset.x) + ' ' + FloatToStr(WheelFrontOfsset.y) + ';'#9#9'WheelFrontOfsset');
    WriteLn(f, FloatToStr(SuspRearOffset.x) + ' ' + FloatToStr(SuspRearOffset.y) + ';'#9#9'SuspRearOffset');
    WriteLn(f, FloatToStr(SuspFrontOffset.x) + ' ' + FloatToStr(SuspFrontOffset.y) + ';'#9#9'SuspFrontOffset');

    WriteLn(f, FloatToStr(BodyMassCenterOffset.x) + ' ' + FloatToStr(BodyMassCenterOffset.y) + ';'#9#9'BodyMassCenterOffset');

    WriteLn(f, FloatToStr(SuspRearLimit.x) + ' ' + FloatToStr(SuspRearLimit.y) + ';'#9#9'SuspRearLimit');
    WriteLn(f, FloatToStr(SuspFrontLimit.x) + ' ' + FloatToStr(SuspFrontLimit.y) + ';'#9#9'SuspFrontLimit');

    WriteLn(f, FloatToStr(SuspRearMotorSpeed) + ';'#9#9'SuspRearMotorSpeed');
    WriteLn(f, FloatToStr(SuspRearMaxMotorForce) + ';'#9#9'SuspRearMaxMotorForce');
    WriteLn(f, FloatToStr(SuspFrontMotorSpeed) + ';'#9#9'SuspFrontMotorSpeed');
    WriteLn(f, FloatToStr(SuspFrontMaxMotorForce) + ';'#9#9'SuspFrontMaxMotorForce');

    WriteLn(f, FloatToStr(MaxMotorSpeed) + ';'#9#9'MaxMotorSpeed');
    WriteLn(f, FloatToStr(Acceleration) + ';'#9#9'Acceleration');
    WriteLn(f, FloatToStr(GearCount) + ';'#9#9'GearCount');
    for i := 0 to GearCount - 1 do
      WriteLn(f, FloatToStr(Gears[i]) + ';'#9#9'Gear' + IntToStr(i));
  end;
  CloseFile(f);
end;

end.
