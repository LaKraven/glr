unit uRenderable;

interface

uses
  Classes,
  uMaterial,
  glr, glrMath, uBaseInterfaceObject;

type
  TglrRenderable = class(TglrInterfacedObject, IglrRenderable)
  private
  protected
    FMaterial: IglrMaterial;
    function GetMaterial(): IglrMaterial;
    procedure SetMaterial(const aMat: IglrMaterial);
  public
    constructor Create(); virtual;
    destructor Destroy(); override;

    procedure DoRender; virtual;

    property Material: IglrMaterial read GetMaterial write SetMaterial;
  end;

  Tglr2DRenderable = class(TglrRenderable, Iglr2DRenderable)
  private
    function GetChildIndex(aChild: Iglr2DRenderable): Integer;
  protected
    FParentScene: Iglr2DScene;
    FParent: Iglr2DRenderable;
    FChilds: TInterfaceList; //TList;
    FZ: Integer;
    FInternalZ: Single;
    FVisible: Boolean;
    FAbsolutePosition: Boolean;
    FWidth, FHeight: Single;
    FPos, FScale: TdfVec2f;
    FRot: Single;
    FPivot: Tglr2DPivotPoint;
    FCustomPivot: TdfVec2f;
    FCoords, FTexCoords: array[0..3] of TdfVec2f;
    procedure RecalcCoords(); virtual;

    function GetWidth(): Single; virtual;
    procedure SetWidth(const aWidth: Single); virtual;
    function GetHeight(): Single; virtual;
    procedure SetHeight(const aHeight: Single); virtual;
    function GetPos(): TdfVec2f; virtual;
    procedure SetPos(const aPos: TdfVec2f); virtual;
    function GetPPos(): PdfVec2f; virtual;
    procedure SetPPos(const aPos: PdfVec2f); virtual;
    function GetScale(): TdfVec2f; virtual;
    procedure SetScale(const aScale: TdfVec2f); virtual;
    function GetRot(): Single; virtual;
    procedure SetRot(const aRot: Single); virtual;
    function GetPRot(): PSingle; virtual;
    procedure SetPRot(const aRot: PSingle); virtual;
    function GetPivot(): Tglr2DPivotPoint; virtual;
    procedure SetPivot(const aPivot: Tglr2DPivotPoint); virtual;
    function GetCoord(aIndex: Integer): TdfVec2f; virtual;
    procedure SetCoord(aIndex: Integer; aCoord: TdfVec2f); virtual;
    function GetTexCoord(aIndex: Integer): TdfVec2f; virtual;
    procedure SetTexCoord(aIndex: Integer; aCoord: TdfVec2f); virtual;
    function GetAbsPosition: Boolean; virtual;
    procedure SetAbsPosition(const Value: Boolean); virtual;
    function GetVis(): Boolean;
    procedure SetVis(aVis: Boolean); virtual;
    function GetZ(): Integer;
    function GetInternalZ(): Single; // -1.0 .. 1.0
    procedure SetZ(const aValue: Integer); virtual;

    function GetChild(Index: Integer): Iglr2DRenderable;
    procedure SetChild(Index: Integer; aChild: Iglr2DRenderable);
    function GetParent(): Iglr2DRenderable;
    procedure SetParent(aParent: Iglr2DRenderable);
    function GetChildsCount(): Integer;

    procedure RenderChilds(); virtual;

    function GetBB: TdfBB;

    function GetParentScene(): Iglr2DScene;
    procedure SetParentScene(const aScene: Iglr2DScene);
  public
    constructor Create(); override;
    destructor Destroy(); override;

    property Width: Single read GetWidth write SetWidth;
    property Height: Single read GetHeight write SetHeight;

    property Position: TdfVec2f read GetPos write SetPos;
    property PPosition: PdfVec2f read GetPPos write SetPPos;
    property Scale: TdfVec2f read GetScale write SetScale;
    procedure ScaleMult(const aScale: TdfVec2f); overload; virtual;
    procedure ScaleMult(const aScale: Single); overload; virtual;
    property Rotation: Single read GetRot write SetRot;
    property PRotation: PSingle read GetPRot write SetPRot;
    property PivotPoint: Tglr2DPivotPoint read GetPivot write SetPivot;
    procedure SetCustomPivotPoint(pX, pY: Single); virtual;
    property Coords[Index: Integer]: TdfVec2f read GetCoord write SetCoord;
    property TexCoords[Index: Integer]: TdfVec2f read GetTexCoord write SetTexCoord;

    //Debug. ���������� ��������, ����� ����������/����������� ��������
    procedure UpdateTexCoords();

    property AbsolutePosition: Boolean read GetAbsPosition write SetAbsPosition;

    procedure SetSizeToTextureSize();

    property Parent: Iglr2DRenderable read GetParent write SetParent;
    property Childs[Index: Integer]: Iglr2DRenderable read GetChild write SetChild;
    property ChildsCount: Integer read GetChildsCount;

    function AddChild(aChild: Iglr2DRenderable): Integer;
    function AddNewChild(): Iglr2DRenderable;
    procedure RemoveChild(Index: Integer); overload;
    procedure RemoveChild(aChild: Iglr2DRenderable); overload;
    procedure FreeChild(Index: Integer);

    property BoundingBox: TdfBB read GetBB;

    procedure Render();
  end;

implementation

{ TdfRenderable }

uses
  Windows, uRenderer, ogl,
  {debug}
  ExportFunc;

constructor TglrRenderable.Create;
begin
  inherited;
  {debug}
  FMaterial := GetObjectFactory().NewMaterial();
end;

destructor TglrRenderable.Destroy;
begin
  FMaterial := nil;
  inherited;
end;

procedure TglrRenderable.DoRender;
begin
  //*
end;

function TglrRenderable.GetMaterial: IglrMaterial;
begin
  Result := FMaterial;
end;

procedure TglrRenderable.SetMaterial(const aMat: IglrMaterial);
begin
  FMaterial := aMat;
end;

{ Tdf2DRenderable }

function Tglr2DRenderable.AddChild(aChild: Iglr2DRenderable): Integer;
var
  Index: Integer;
begin
  Index := GetChildIndex(aChild);
  if Index <> -1 then //����� ������� ��� ����
    Exit(Index)  //���������� ��� ������
  else
  begin
    aChild.Parent := Self;
    Result := FChilds.Add(aChild);
  end;
end;

function Tglr2DRenderable.AddNewChild: Iglr2DRenderable;
begin
  Result := Tglr2DRenderable.Create;
  Result.Parent := Self;
  Self._Release();
  FChilds.Add(Result);
end;

constructor Tglr2DRenderable.Create;
begin
  inherited;
  FTexCoords[0] := dfVec2f(1, 1);
  FTexCoords[1] := dfVec2f(1, 0);
  FTexCoords[2] := dfVec2f(0, 0);
  FTexCoords[3] := dfVec2f(0, 1);

  FAbsolutePosition := True;
  FVisible := True;
  FZ := 0;
  FInternalZ := 0;

  FCustomPivot := dfVec2f(0, 0);

  FChilds := TInterfaceList.Create();
end;

destructor Tglr2DRenderable.Destroy;
begin
  FParentScene := nil;
  FParent := nil;
  FChilds.Free();
  inherited;
end;

procedure Tglr2DRenderable.FreeChild(Index: Integer);
begin
  if (Index >= 0) and (Index < FChilds.Count) then
    if Assigned(FChilds[Index]) then
    begin
//      RemoveChild(Index);
      //��� �������� ������ � �����. ������, ������ ������ ������������,
      //���� �� ���� ��� ������ ������
      FChilds.Delete(Index);
    end;
end;

function Tglr2DRenderable.GetAbsPosition: Boolean;
begin
  Result := FAbsolutePosition;
end;

function Tglr2DRenderable.GetBB: TdfBB;
var
  i: Integer;
begin
  Result.Left := 1/0;
  for i := 0 to 3 do
    if (FCoords[i].x + FPos.x) < Result.Left then
      Result.Left := FPos.x + FCoords[i].x;
  Result.Right := - 1/0;
  for i := 0 to 3 do
    if (FCoords[i].x + FPos.x) > Result.Right then
      Result.Right := FPos.x + FCoords[i].x;
  Result.Top :=  1/0;
  for i := 0 to 3 do
    if (FCoords[i].y + FPos.y) < Result.Top then
      Result.Top := FPos.y + FCoords[i].y;
  Result.Bottom := - 1/0;
  for i := 0 to 3 do
    if (FCoords[i].y + FPos.y) > Result.Bottom then
      Result.Bottom := FPos.y + FCoords[i].y;
end;

function Tglr2DRenderable.GetChild(Index: Integer): Iglr2DRenderable;
begin
  if (Index >= 0) and (Index < FChilds.Count) then
    if Assigned(FChilds[Index]) then
      Result := Iglr2DRenderable(FChilds[Index]);
end;

function Tglr2DRenderable.GetChildIndex(aChild: Iglr2DRenderable): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to FChilds.Count - 1 do
    if FChilds[i] = (aChild as IInterface)then
      Exit(i);
end;

function Tglr2DRenderable.GetChildsCount: Integer;
begin
  Result := FChilds.Count;
end;

function Tglr2DRenderable.GetCoord(aIndex: Integer): TdfVec2f;
begin
  if aIndex in [0..3] then
    Result := FCoords[aIndex];
end;

function Tglr2DRenderable.GetHeight: Single;
begin
  Result := FHeight;
end;

function Tglr2DRenderable.GetInternalZ: Single;
begin
  Result := FInternalZ;
end;

function Tglr2DRenderable.GetParent: Iglr2DRenderable;
begin

end;

function Tglr2DRenderable.GetParentScene: Iglr2DScene;
begin
  Result := FParentScene;
end;

function Tglr2DRenderable.GetPivot: Tglr2DPivotPoint;
begin
  Result := FPivot;
end;

function Tglr2DRenderable.GetPos: TdfVec2f;
begin
  Result := FPos;
end;

function Tglr2DRenderable.GetPPos: PdfVec2f;
begin
  Result := @FPos;
end;

function Tglr2DRenderable.GetPRot: System.PSingle;
begin
  Result := @FRot;
end;

function Tglr2DRenderable.GetRot: Single;
begin
  Result := FRot;
end;

function Tglr2DRenderable.GetScale: TdfVec2f;
begin
  Result := FScale;
end;

function Tglr2DRenderable.GetTexCoord(aIndex: Integer): TdfVec2f;
begin
  if aIndex in [0..3] then
    Result := FTexCoords[aIndex];
end;

function Tglr2DRenderable.GetVis: Boolean;
begin
  Result := FVisible;
end;

function Tglr2DRenderable.GetWidth: Single;
begin
  Result := FWidth;
end;

function Tglr2DRenderable.GetZ: Integer;
begin
  Result := FZ;
end;

{TODO: �������� ��������������, �� ������� ��� �����������}
procedure Tglr2DRenderable.RecalcCoords;
begin
  case FPivot of
    ppTopLeft:
    begin
      FCoords[0] := dfVec2f(FWidth * FScale.x, FHeight * FScale.y);
      FCoords[1] := dfVec2f(FWidth * FScale.x, 0);
      FCoords[2] := dfVec2f(0, 0);
      FCoords[3] := dfVec2f(0, FHeight * FScale.y);
    end;
    ppTopRight:
    begin
      FCoords[0] := dfVec2f(0, FHeight * FScale.y);
      FCoords[1] := dfVec2f(0, 0);
      FCoords[2] := dfVec2f(-FWidth * FScale.x, 0);
      FCoords[3] := dfVec2f(-FWidth * FScale.x, FHeight * FScale.y);
    end;
    ppBottomLeft:
    begin
      FCoords[0] := dfVec2f(FWidth * FScale.x, 0);
      FCoords[1] := dfVec2f(FWidth * FScale.x, -FHeight * FScale.y);
      FCoords[2] := dfVec2f(0, -FHeight * FScale.y);
      FCoords[3] := dfVec2f(0, 0);
    end;
    ppBottomRight:
    begin
      FCoords[0] := dfVec2f(0, 0);
      FCoords[1] := dfVec2f(0, -FHeight * FScale.y);
      FCoords[2] := dfVec2f(-FWidth * FScale.x, -FHeight * FScale.y);
      FCoords[3] := dfVec2f(-FWidth * FScale.x, 0);
    end;
    ppCenter:
    begin
      FCoords[0] := dfVec2f(FWidth * FScale.x, FHeight * FScale.y) * 0.5;
      FCoords[1] := dfVec2f(FWidth * FScale.x, -FHeight * FScale.y) * 0.5;
      FCoords[2] := dfVec2f(-FWidth * FScale.x, -FHeight * FScale.y) * 0.5;
      FCoords[3] := dfVec2f(-FWidth * FScale.x, FHeight * FScale.y) * 0.5;
    end;
    ppTopCenter:
    begin
      FCoords[0] := dfVec2f(FWidth * FScale.x  * 0.5, FHeight * FScale.y);
      FCoords[1] := dfVec2f(FWidth * FScale.x * 0.5, 0);
      FCoords[2] := dfVec2f(-FWidth * FScale.x * 0.5, 0);
      FCoords[3] := dfVec2f(-FWidth * FScale.x * 0.5, FHeight * FScale.y);
    end;
    ppBottomCenter:
    begin
      FCoords[0] := dfVec2f(FWidth * FScale.x  * 0.5, 0);
      FCoords[1] := dfVec2f(FWidth * FScale.x * 0.5, -FHeight * FScale.y);
      FCoords[2] := dfVec2f(-FWidth * FScale.x * 0.5, -FHeight * FScale.y);
      FCoords[3] := dfVec2f(-FWidth * FScale.x * 0.5, 0);
    end;
    ppCustom:
    begin
      FCoords[0] := (dfVec2f(1, 1) - FCustomPivot) * dfVec2f(FWidth * FScale.x, FHeight * FScale.y);
      FCoords[1] := (dfVec2f(1, 0) - FCustomPivot) * dfVec2f(FWidth * FScale.x, FHeight * FScale.y);
      FCoords[2] := (FCustomPivot.NegateVector) * dfVec2f(FWidth * FScale.x, FHeight * FScale.y);;
      FCoords[3] := (dfVec2f(0, 1) - FCustomPivot) * dfVec2f(FWidth * FScale.x, FHeight * FScale.y);
    end;
  end;
end;

procedure Tglr2DRenderable.RemoveChild(Index: Integer);
begin
  //���������� FreeChild, ��� ��� ������� ������ �������� � ������������ �������
  // ������, AFAIK
  if (Index >= 0) and (Index < FChilds.Count) then
    if Assigned(FChilds[Index]) then
      FChilds.Delete(Index);
end;

procedure Tglr2DRenderable.RemoveChild(aChild: Iglr2DRenderable);
begin
  FChilds.Remove(aChild);
end;

procedure Tglr2DRenderable.Render;
begin
  if not FVisible then
    Exit();
  gl.PushMatrix();
    Material.Apply();
    DoRender();
    Material.Unapply();
    RenderChilds();
  gl.PopMatrix();
end;

procedure Tglr2DRenderable.RenderChilds;
var
  i: Integer;
begin
//  if not FVisible then
//    Exit();
  for i := 0 to FChilds.Count - 1 do
    Iglr2DRenderable(FChilds[i]).Render;
end;

procedure Tglr2DRenderable.ScaleMult(const aScale: TdfVec2f);
begin
  FScale := FScale * aScale;
  RecalcCoords();
end;

procedure Tglr2DRenderable.ScaleMult(const aScale: Single);
begin
  FScale := FScale * aScale;
  RecalcCoords();
end;

procedure Tglr2DRenderable.SetAbsPosition(const Value: Boolean);
begin
  FAbsolutePosition := Value;
end;

procedure Tglr2DRenderable.SetChild(Index: Integer; aChild: Iglr2DRenderable);
begin
  FChilds[Index] := aChild;
end;

procedure Tglr2DRenderable.SetCoord(aIndex: Integer; aCoord: TdfVec2f);
begin
  if aIndex in [0..3] then
    FCoords[aIndex] := aCoord;
end;

procedure Tglr2DRenderable.SetCustomPivotPoint(pX, pY: Single);
begin
  FCustomPivot := dfVec2f(pX, pY);
  PivotPoint := ppCustom;
end;

procedure Tglr2DRenderable.SetHeight(const aHeight: Single);
begin
  FHeight := aHeight;
  RecalcCoords();
end;

procedure Tglr2DRenderable.SetParent(aParent: Iglr2DRenderable);
begin
  if Assigned(Parent) and (Parent <> aParent) then
    FParent.RemoveChild(Self);
  FParent := aParent;
end;

procedure Tglr2DRenderable.SetParentScene(const aScene: Iglr2DScene);
begin
  FParentScene := aScene;
end;

procedure Tglr2DRenderable.SetPivot(const aPivot: Tglr2DPivotPoint);
begin
  if FPivot <> aPivot then
  begin
    FPivot := aPivot;
    RecalcCoords;
  end;
end;

procedure Tglr2DRenderable.SetPos(const aPos: TdfVec2f);
begin
  FPos := aPos;
//  RecalcCoords();
end;

procedure Tglr2DRenderable.SetPPos(const aPos: PdfVec2f);
begin
  FPos := aPos^;
end;

procedure Tglr2DRenderable.SetPRot(const aRot: System.PSingle);
begin
  FRot := aRot^;
end;

procedure Tglr2DRenderable.SetRot(const aRot: Single);
begin
  FRot := aRot;
//  RecalcCoords();
end;

procedure Tglr2DRenderable.SetScale(const aScale: TdfVec2f);
begin
  FScale := aScale;
  RecalcCoords();
end;

procedure Tglr2DRenderable.SetSizeToTextureSize;
begin
  Width := Material.Texture.GetTexDesc.RegionWidth;
  Height := Material.Texture.GetTexDesc.RegionHeight;
end;

procedure Tglr2DRenderable.SetTexCoord(aIndex: Integer; aCoord: TdfVec2f);
begin
  if aIndex in [0..3] then
    FTexCoords[aIndex] := aCoord;
end;

procedure Tglr2DRenderable.SetVis(aVis: Boolean);
begin
  FVisible := aVis;
end;

procedure Tglr2DRenderable.SetWidth(const aWidth: Single);
begin
  FWidth := aWidth;
  RecalcCoords();
end;

procedure Tglr2DRenderable.SetZ(const aValue: Integer);
begin
  FZ := Clamp(aValue, -100, 100);
  FInternalZ := FZ / 100;
end;

procedure Tglr2DRenderable.UpdateTexCoords;
begin
  with FMaterial.Texture.GetTexDesc() do
  begin
    FTexCoords[0] := dfVec2f((X + RegionWidth) / Width, (Y + RegionHeight) / Height);
    FTexCoords[1] := dfVec2f(FTexCoords[0].x, Y / Height);
    FTexCoords[2] := dfVec2f(X / Width,  Y / Height);
    FTexCoords[3] := dfVec2f(FTexCoords[2].x, FTexCoords[0].y);
  end;
end;

end.
