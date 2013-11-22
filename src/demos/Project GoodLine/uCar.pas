unit uCar;

interface

uses
  glr, glrMath,
  uCarSaveLoad,
  uPhysics2D;

const
  INITIAL_X = 100;
  INITIAL_Y = 300;

  MIN_MOTOR_SPEED = 5;

  //�������� ��� ������� ����� ������������� � ������ �� ������ � ��������
  CHANGE_GEAR_MOTORFORCE_THRESHOLD = 10;//4;

type
  TpdMoveDirection = (mNoMove, mLeft, mRight);

  TpdCar = class
  private
    procedure InitSprites(const aCarInfo: TpdCarInfo);
    procedure InitBodies(const aCarInfo: TpdCarInfo);
    procedure InitJoints(const aCarInfo: TpdCarInfo);

    procedure AutomaticTransmissionUpdate(const dt: Double);
    procedure DefineCarDynamicParams(const dt: Double);
    procedure AddAccel(const dt: Double);
    procedure ReduceAccel(const dt: Double);
    procedure Brake(UseBrake: Boolean);
  public
    WheelRear, WheelFront, Body, SuspRear, SuspFront: IglrSprite;
    b2WheelRear, b2WheelFront, b2Body, b2SuspRear, b2SuspFront: Tb2Body;
    b2WheelJointRear, b2WheelJointFront: Tb2RevoluteJoint;
    b2SuspJointRear, b2SuspJointFront: Tb2PrismaticJoint;

    CurrentMotorSpeed, MaxMotorSpeed, Acceleration: Single;
    Gear: Integer;
    Gears: array[-1..2] of Single;

    MoveDirection: TpdMoveDirection;
    BodySpeed: Single;
    //CurrentWheelSpeed: Single;

    constructor Create(const aCarInfo: TpdCarInfo);
    destructor Destroy(); override;

    procedure Update(const dt: Double);
  end;

implementation

uses
  Windows,
  uGlobal, uBox2DImport, uPhysics2DTypes;

{ TpdCar }

procedure TpdCar.AddAccel(const dt: Double);
begin
  CurrentMotorSpeed := Clamp(CurrentMotorSpeed + dt * Acceleration, 0, MaxMotorSpeed);
end;

procedure TpdCar.AutomaticTransmissionUpdate(const dt: Double);
begin
  if Abs(CurrentMotorSpeed - MaxMotorSpeed) <= cEPS then
  begin
    if (Gear <> -1) and (Gear < High(Gears)) then
    begin
      Inc(Gear); //�������� ��������
      CurrentMotorSpeed := CurrentMotorSpeed * (Gears[Gear - 1] / Gears[Gear]) * 0.7;
    end;
  end
  else if CurrentMotorSpeed < MIN_MOTOR_SPEED then
  begin
    if Gear > 0 then
    begin
      Dec(Gear);
      CurrentMotorSpeed := CurrentMotorSpeed * (Gears[Gear + 1] / Gears[Gear]) * 0.7;
    end;
  end;
end;

procedure TpdCar.Brake(UseBrake: Boolean);
begin
  b2WheelJointFront.SetMotorSpeed(0);
  b2WheelJointFront.EnableMotor(UseBrake);
end;

constructor TpdCar.Create(const aCarInfo: TpdCarInfo);
begin
  inherited Create();
  InitSprites(aCarInfo);
  InitBodies(aCarInfo);
  InitJoints(aCarInfo);

  MaxMotorSpeed := aCarInfo.MaxMotorSpeed;
  Acceleration := aCarInfo.Acceleration;
  Gear := 0;
  Gears[-1] := aCarInfo.GearR;
  Gears[0] := aCarInfo.Gear0;
  Gears[1] := aCarInfo.Gear1;
  Gears[2] := aCarInfo.Gear2;
end;

procedure TpdCar.DefineCarDynamicParams(const dt: Double);

const
  SPEED_THRESHOLD = 2.0 / C_COEF;

begin
  BodySpeed := b2Body.GetLinearVelocity.x / C_COEF;
  if BodySpeed > SPEED_THRESHOLD then
    MoveDirection := mRight
  else if BodySpeed < -SPEED_THRESHOLD then
    MoveDirection := mLeft
  else
    MoveDirection := mNoMove;
end;

destructor TpdCar.Destroy;
begin
  mainScene.RootNode.RemoveChild(Body);
  mainScene.RootNode.RemoveChild(WheelRear);
  mainScene.RootNode.RemoveChild(WheelFront);
  mainScene.RootNode.RemoveChild(SuspRear);
  mainScene.RootNode.RemoveChild(SuspFront);
  inherited;
end;

procedure TpdCar.InitBodies(const aCarInfo: TpdCarInfo);
begin
  with aCarInfo do
  begin
    b2Body := dfb2InitBox(b2world, Body, BodyD, BodyF, BodyR, $FFFF, $000F, -2);
    b2WheelRear := dfb2InitCircle(b2world, WheelRear, WheelRearD, WheelRearF, WheelRearR, $FFFF, $000F, -2);
    b2WheelFront := dfb2InitCircle(b2world, WheelFront, WheelFrontD, WheelFrontF, WheelFrontR, $FFFF, $000F, -2);
    b2SuspRear := dfb2InitBox(b2world, SuspRear, 2.0, 0, 0, $FFFF, $0000, -2);
    b2SuspFront := dfb2InitBox(b2world, SuspFront, 2.0, 0, 0, $FFFF, $0000, -2);
  end;
end;

procedure TpdCar.InitJoints(const aCarInfo: TpdCarInfo);
var
  suspAxis: TVector2;
  PriDef: Tb2PrismaticJointDef;
  RevDef: Tb2RevoluteJointDef;
begin
  suspAxis := ConvertGLToB2((aCarInfo.WheelRearOffset - aCarInfo.SuspRearOffset).Normal);
  PriDef := Tb2PrismaticJointDef.Create;
  PriDef.Initialize(b2Body, b2SuspRear, b2SuspRear.GetPosition, suspAxis);
  PriDef.enableLimit := True;
  PriDef.enableMotor := True;
  b2SuspJointRear := Tb2PrismaticJoint(b2World.CreateJoint(PriDef));
  with b2SuspJointRear, aCarInfo do
  begin
    SetLimits(SuspRearLimit.x * C_COEF, SuspRearLimit.y * C_COEF);
    SetMotorSpeed(SuspRearMotorSpeed);
    SetMaxMotorForce(SuspRearMaxMotorForce);
  end;

  suspAxis := ConvertGLToB2((aCarInfo.WheelFrontOfsset - aCarInfo.SuspFrontOffset).Normal);
  PriDef := Tb2PrismaticJointDef.Create;
  PriDef.Initialize(b2Body, b2SuspFront, b2SuspFront.GetPosition, suspAxis);
  PriDef.enableLimit := True;
  PriDef.enableMotor := True;
  b2SuspJointFront := Tb2PrismaticJoint(b2World.CreateJoint(PriDef));
  with b2SuspJointFront, aCarInfo do
  begin
    SetLimits(SuspFrontLimit.x * C_COEF, SuspFrontLimit.y * C_COEF);
    SetMotorSpeed(SuspFrontMotorSpeed);
    SetMaxMotorForce(SuspFrontMaxMotorForce);
  end;

  RevDef := Tb2RevoluteJointDef.Create;
  RevDef.enableMotor := True;
  RevDef.Initialize(b2WheelRear, b2SuspRear, b2WheelRear.GetPosition);
  b2WheelJointRear := Tb2RevoluteJoint(b2World.CreateJoint(RevDef));
  b2WheelJointRear.SetMaxMotorTorque(100);

  RevDef := Tb2RevoluteJointDef.Create;
  RevDef.enableMotor := False;
  RevDef.Initialize(b2WheelFront, b2SuspFront, b2WheelFront.GetPosition);
  b2WheelJointFront := Tb2RevoluteJoint(b2World.CreateJoint(RevDef));
  b2WheelJointFront.SetMaxMotorTorque(200);
end;

procedure TpdCar.InitSprites(const aCarInfo: TpdCarInfo);
begin
  Body := Factory.NewSprite();
  with Body do
  begin
    Material.Texture := atlasMain.LoadTexture(BLOCK_TEXTURE);
    SetSizeToTextureSize();
    Material.Diffuse := colorOrange;

    UpdateTexCoords();
    PivotPoint := ppCenter;
    Position := dfVec3f(INITIAL_X, INITIAL_Y, Z_PLAYER);
  end;
  mainScene.RootNode.AddChild(Body);

  SuspRear := Factory.NewSprite();
  with SuspRear do
  begin
    Width := 5;
    Height := 20;
    Material.Diffuse := colorRed;
    PivotPoint := ppCenter;
    Position := Body.Position + dfVec3f(aCarInfo.SuspRearOffset, 1);
    Rotation := (aCarInfo.WheelRearOffset - aCarInfo.SuspRearOffset).Normal.GetRotationAngle();
  end;
  mainScene.RootNode.AddChild(SuspRear);

  SuspFront := Factory.NewSprite();
  with SuspFront do
  begin
    Width := 5;
    Height := 20;
    Material.Diffuse := colorRed;
    PivotPoint := ppCenter;
    Position := Body.Position + dfVec3f(aCarInfo.SuspFrontOffset, 1);
    Rotation := (aCarInfo.WheelFrontOfsset - aCarInfo.SuspFrontOffset).Normal.GetRotationAngle();
  end;
  mainScene.RootNode.AddChild(SuspFront);

  WheelRear := Factory.NewSprite();
  with WheelRear do
  begin
    Material.Texture := atlasMain.LoadTexture(CIRCLE_TEXTURE);
    Material.Diffuse := colorOrange;
    //SetSizeToTextureSize();
    Width := aCarInfo.WheelRearSize;
    Height := aCarInfo.WheelRearSize;
    UpdateTexCoords();
    PivotPoint := ppCenter;
    Position := Body.Position + dfVec3f(aCarInfo.WheelRearOffset, 2);
  end;
  mainScene.RootNode.AddChild(WheelRear);

  WheelFront := Factory.NewSprite();
  with WheelFront do
  begin
    Material.Texture := atlasMain.LoadTexture(CIRCLE_TEXTURE);
    Material.Diffuse := colorOrange;
    //SetSizeToTextureSize();
    Width := aCarInfo.WheelFrontSize;
    Height := aCarInfo.WheelFrontSize;
    UpdateTexCoords();
    PivotPoint := ppCenter;
    Position := Body.Position + dfVec3f(aCarInfo.WheelFrontOfsset, 2);
  end;
  mainScene.RootNode.AddChild(WheelFront);
end;


procedure TpdCar.ReduceAccel(const dt: Double);
begin
  CurrentMotorSpeed := Clamp(CurrentMotorSpeed - dt * Acceleration, 0, MaxMotorSpeed);
end;

procedure TpdCar.Update(const dt: Double);
begin
  Brake(False);

  if R.Input.IsKeyDown(VK_UP) then
  begin
    b2WheelJointRear.EnableMotor(True);
    //���� �������� ������ ��������
    if Gear = -1 then
    begin
      if BodySpeed < CHANGE_GEAR_MOTORFORCE_THRESHOLD then
      begin
        //����� ������������� �� ������
        Gear := 0;
        CurrentMotorSpeed := 0;
      end
      else
      begin
        //������ ������� ��������
        ReduceAccel(2 * dt);
        Brake(True);
      end;
    end
    else
    begin
      AddAccel(dt);
    end;
  end

  else if R.Input.IsKeyDown(VK_DOWN) then
  begin
    b2WheelJointRear.EnableMotor(True);
    if Gear >= 0 then
    begin
      if BodySpeed < CHANGE_GEAR_MOTORFORCE_THRESHOLD then
      begin
        //����� ������������� �� ������
        Gear := -1;
        CurrentMotorSpeed := 0;
      end
      else
      begin
        //����� ������� ��������
        ReduceAccel(2 * dt);
        Brake(True);
      end;

    end
    else
    begin
      AddAccel(dt);
    end;
  end

  //�� ������ �� ������, �� �����
  else
  begin
    b2WheelJointRear.EnableMotor(False);
    ReduceAccel(0.5 * dt);
    //b2WheelJointRear.EnableMotor(True);
    //b2WheelJointRear.SetMaxMotorTorque(100);
  end;
  if b2WheelJointRear.IsMotorEnabled then
    b2WheelJointRear.SetMotorSpeed(-CurrentMotorSpeed * Gears[Gear]);

  //AutomaticTransmissionUpdate(dt);
  DefineCarDynamicParams(dt);

  SyncObjects(b2Body, Body);
  SyncObjects(b2SuspRear, SuspRear);
  SyncObjects(b2SuspFront, SuspFront);
  SyncObjects(b2WheelRear, WheelRear);
  SyncObjects(b2WheelFront, WheelFront);
end;

end.
