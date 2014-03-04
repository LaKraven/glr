unit uCamera;

interface

uses
  glrMath, ogl, glr, uNode;

type
  TglrCameraTargetMode = (mPoint, mTarget, mFree);

  TglrCamera = class (TglrNode, IglrCamera)
  protected
    FProjMode: TglrCameraProjectionMode;
    FProjMatrix: TdfMat4f;
    FMode: TglrCameraTargetMode;
    FTargetPoint: TdfVec3f;
    FTarget: IglrNode;
    FFOV, FZNear, FZFar: Single;
    FX, FY, FW, FH: Integer;
    function GetProjMode(): TglrCameraProjectionMode;
    procedure SetProjMode(aMode: TglrCameraProjectionMode);
    procedure SetPerspective();
    procedure SetOrtho();
    //procedure UpdateDirUpRight(NewDir, NewUp, NewRight: TdfVec3f); override;
  public
    procedure Viewport(x, y, w, h: Integer; FOV, ZNear, ZFar: Single);
    procedure ViewportOnly(x, y, w, h: Integer);

    procedure Translate(alongUpVector, alongRightVector: Single);
    procedure Scale(aScale: Single);
    procedure Rotate(delta: Single; Axis: TdfVec3f);

    function GetViewport(): TglrViewportParams;

    procedure Update;

    procedure SetCamera(aPos, aTargetPos, aUp: TdfVec3f);
//    procedure SetTarget(aPoint: TdfVec3f); overload;
//    procedure SetTarget(aTarget: IglrNode); overload;

    property ProjectionMode: TglrCameraProjectionMode read GetProjMode write SetProjMode;
  end;

implementation

//uses
  //Windows;

procedure TglrCamera.Viewport(x, y, w, h: Integer; FOV, ZNear, ZFar: Single);
begin
  FFOV := FOV;
  FZNear := ZNear;
  FZFar := ZFar;
  FX := x;
  FY := y;
  if w > 0 then
    FW := w
  else
    FW := 1;
  if h > 0 then
    FH := h
  else
    FH := 1;

  ProjectionMode := FProjMode; //���������
end;

procedure TglrCamera.ViewportOnly(x, y, w, h: Integer);
begin
  FX := x;
  FY := y;
  if w > 0 then
    FW := w
  else
    FW := 1;
  if h > 0 then
    FH := h
  else
    FH := 1;
  ProjectionMode := FProjMode; //���������
end;

function TglrCamera.GetProjMode: TglrCameraProjectionMode;
begin
  Result := FProjMode;
end;

function TglrCamera.GetViewport: TglrViewportParams;
begin
  with Result do
  begin
    X := FX;
    Y := FY;
    W := FW;
    H := FH;
    FOV := FFOV;
    ZNear := FZNear;
    ZFar := FZFar;
  end;
end;

procedure TglrCamera.Translate(alongUpVector, alongRightVector: Single);
var
  v: TdfVec3f;
begin
  v := Up * alongUpVector;
  v := v + (Right * alongRightVector);
  FModelMatrix.Translate(v);
end;

procedure TglrCamera.Scale(aScale: Single);
begin
  FModelMatrix.Scale(dfVec3f(aScale, aScale, aScale));
end;

procedure TglrCamera.Update();
begin
//  gl.MatrixMode(GL_PROJECTION);
//  gl.LoadMatrixf(FProjMatrix);
  gl.MatrixMode(GL_MODELVIEW);
  gl.LoadMatrixf(FModelMatrix);
end;

procedure TglrCamera.Rotate(delta: Single; Axis: TdfVec3f);
begin
  FModelMatrix.Rotate(Delta, Axis);
end;
{
function CreateLookAtMatrix(const eye, center, normUp: TVector): TMatrix;
var
  XAxis, YAxis, ZAxis, negEye: TVector;
begin
  ZAxis := VectorSubtract(center, eye);
  NormalizeVector(ZAxis);
  XAxis := VectorCrossProduct(ZAxis, normUp);
  NormalizeVector(XAxis);
  YAxis := VectorCrossProduct(XAxis, ZAxis);
  Result.V[0] := XAxis;
  Result.V[1] := YAxis;
  Result.V[2] := ZAxis;
  NegateVector(Result.V[2]);
  Result.V[3] := NullHmgPoint;
  TransposeMatrix(Result);
  negEye := eye;
  NegateVector(negEye);
  negEye.V[3] := 1;
  negEye := VectorTransform(negEye, Result);
  Result.V[3] := negEye;
end;                 }

procedure TglrCamera.SetCamera(aPos, aTargetPos, aUp: TdfVec3f);
var
  vDir, vUp, vLeft: TdfVec3f;
begin
  FModelMatrix.Identity;
  vUp := aUp;
  vUp.Normalize;
  vDir := aTargetPos - aPos;
  vDir.Normalize;
  vLeft := vDir.Cross(vUp);
  vLeft.Normalize;
  vUp := vLeft.Cross(vDir);
  vUp.Normalize;

  FPos := aPos;
  FRight := vLeft;
  FUp   := vUp;
  FDir  := vDir;

  vDir.Negate;

  with FModelMatrix do
  begin
    e00 := vLeft.x;  e10 := vLeft.y;  e20 := vLeft.z;  e30 := 0;
    e01 := vUp.x;    e11 := vUp.y;    e21 := vUp.z;    e31 := 0;
    e02 := vDir.x;   e12 := vDir.y;   e22 := vDir.z;   e32 := 0;
    e03 := 0;        e13 := 0;        e23 := 0;        e33 := 1;
  end;

  FModelMatrix := FModelMatrix.Transpose();
  aPos.Negate;
  aPos := FModelMatrix * aPos;
  with FModelMatrix do
  begin
    e03 := aPos.x;        e13 := aPos.y;        e23 := aPos.z;        e33 := 1;
  end;

  //FPos := FModelMatrix.Pos;

  //Position := aPos;
  //UpdateDirUpRight(vDir, vUp, vLeft);

  FTargetPoint := aTargetPos;
  FMode := mPoint;
end;

procedure TglrCamera.SetOrtho;
begin
  gl.Viewport(FX, FY, FW, FH);
  FProjMatrix.Identity;
  FProjMatrix.Ortho(FX, FW, FH, FY, FZNear, FZFar);
  gl.MatrixMode(GL_PROJECTION);
  gl.LoadMatrixf(FProjMatrix);
end;

procedure TglrCamera.SetPerspective;
begin
  gl.Viewport(FX, FY, FW, FH);
  FProjMatrix.Identity;
  FProjMatrix.Perspective(FFOV, FW / FH, FZNear, FZFar);
  gl.MatrixMode(GL_PROJECTION);
  gl.LoadMatrixf(FProjMatrix);
end;

procedure TglrCamera.SetProjMode(aMode: TglrCameraProjectionMode);
begin
  case aMode of
    pmPerpective: SetPerspective();
    pmOrtho: SetOrtho();
  end;
  FProjMode := aMode;
end;

//procedure TglrCamera.SetTarget(aPoint: TdfVec3f);
//var
//  vDir, vUp, vLeft: TdfVec3f;
//begin
//  FTargetPoint := aPoint;
//  with FModelMatrix do
//  begin
//    vDir := Position - aPoint;
//    vDir.Normalize;
//    vUp := Up;
//    vLeft := vDir.Cross(vUp);
//    vLeft.Normalize;
//    vUp :=vLeft.Cross(vDir);
//    vUp.Normalize;
//    vLeft.Negate;
//    UpdateDirUpRight(vDir, vUp, vLeft);
//  end;
//  FMode := mPoint;
//end;
//
//procedure TglrCamera.SetTarget(aTarget: IglrNode);
//begin
//  FTarget := aTarget;
//  SetTarget(aTarget.Position);
//  FMode := mTarget;
//end;

{
procedure TglrCamera.UpdateDirUpRight(NewDir, NewUp, NewRight: TdfVec3f);
begin
  with FModelMatrix do
  begin
    e00 :=  NewRight.x; e01 :=  NewRight.y; e02 :=  NewRight.z; e03 := -FPos.Dot(NewRight);
    e10 :=  NewUp.x;    e11 :=  NewUp.y;    e12 :=  NewUp.z;    e13 := -FPos.Dot(NewUp);
    e20 :=  NewDir.x;   e21 :=  NewDir.y;   e22 :=  NewDir.z;   e23 := -FPos.Dot(NewDir);
    e30 := 0;     e31 := 0;     e32 := 0;  e33 :=  1;
  end;
  FRight := NewRight;
  FUp   := NewUp;
  FDir  := NewDir;
  FPos := FModelMatrix.Pos;
end;    }

end.
