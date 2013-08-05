unit uEarthTools;

interface

uses
  dfHRenderer, dfMath;

type
  TtzEarthMode = (emNewPoints, emSelectPoints);

  TtzEarthNode = record
    position: TdfVec2f;
    pointSprite: IglrSprite;
  end;

  TtzEarthTools = class
  private
    FMode: TtzEarthMode;

    FSelected: Integer;

    FUserRenderer: IglrUserRenderable;
    procedure SetMode(const Value: TtzEarthMode);
  public
    Path: array of TtzEarthNode;

    constructor Create(aRootNode: IglrNode); virtual;
    destructor Destroy(); override;

    procedure AddNewPointToEarthPath(X, Y: Integer; AtIndex: Integer);
    procedure TrySelectPoint(X, Y: Integer);

    property Mode: TtzEarthMode read FMode write SetMode;
  end;

var
  EarthTools: TtzEarthTools;

  procedure glrOnEarthRender(); stdcall;

implementation

uses
  uMain,
  dfHGL, dfHUtility;

var
  vp: TglrViewportParams;

procedure glrOnEarthRender();
var
  i: Integer;
begin
  gl.MatrixMode(GL_PROJECTION);
  gl.PushMatrix();
  gl.LoadIdentity();
  vp := FRenderer.Camera.GetViewport();
  gl.Ortho(vp.X, vp.W, vp.H, vp.Y, -1, 1);
  gl.MatrixMode(GL_MODELVIEW);
  gl.LoadIdentity();
  gl.Disable(GL_DEPTH_TEST);
  gl.Disable(GL_LIGHTING);

  gl.Beginp(GL_LINE_STRIP);
    for i := Low(EarthTools.Path) to High(EarthTools.Path) do
      gl.Vertex2fv(EarthTools.Path[i].position);
  gl.Endp;

  gl.Enable(GL_LIGHTING);
  gl.Enable(GL_DEPTH_TEST);
  gl.MatrixMode(GL_PROJECTION);
  gl.PopMatrix();
  gl.MatrixMode(GL_MODELVIEW);
end;

{ TtzEarthTools }

procedure TtzEarthTools.AddNewPointToEarthPath(X, Y, AtIndex: Integer);

  procedure SlideArray(StartIndex: Integer);
  var
    i: Integer;
  begin
    for i := High(Path) - 1 downto StartIndex do
      Path[i + 1] := Path[i];
  end;

var
  ind: Integer;
begin
  //��������� ����� �����
  ind := Length(Path);
  SetLength(Path, ind + 1);
  //���� -1 - ������ � �����
  if AtIndex < 0 then
       AtIndex := ind
  //���� ���������� �������� �� ������������ �������, �� �������� ������
  else if AtIndex < ind then
    SlideArray(atIndex);


  with Path[atIndex] do
  begin
    position := dfVec2f(X, Y);
    pointSprite := dfNewSpriteWithNode(FRenderer.RootNode);
    pointSprite.Position := position;
    pointSprite.Width := C_POINTSPRTE_SIZE;
    pointSprite.Height := C_POINTSPRTE_SIZE;
    pointSprite.PivotPoint := ppCenter;
    pointSprite.Material.MaterialOptions.Diffuse := C_NORMAL_COLOR;
  end;
end;

constructor TtzEarthTools.Create(aRootNode: IdfNode);
begin
  inherited Create();
  FUserRenderer := dfCreateUserRender();

  with dfCreateNode(aRootNode) do
    Renderable := FUserRenderer;

  FUserRenderer.OnRender := glrOnEarthRender;
end;

destructor TtzEarthTools.Destroy;
begin
  FUserRenderer := nil;
  inherited;
end;

procedure TtzEarthTools.SetMode(const Value: TtzEarthMode);
begin
  FMode := Value;
  //*
end;

procedure TtzEarthTools.TrySelectPoint(X, Y: Integer);
var
  i: Integer;
begin
  //������ �����
  FSelected := -1;
  for i := Low(Path) to High(Path) do
    if Path[i].position.Dist(dfVec2f(X, Y)) < C_SELECT_RADIUS then
    begin
      if FSelected <> -1 then
      begin
        if Path[i].position.Dist(dfVec2f(X, Y))
          < Path[FSelected].position.Dist(dfVec2f(X, Y)) then
        begin
          Path[FSelected].pointSprite.Material.MaterialOptions.Diffuse := C_NORMAL_COLOR;
          FSelected := i;
          Path[i].pointSprite.Material.MaterialOptions.Diffuse := C_SELECT_COLOR;
        end;
      end
      else
      begin
        FSelected := i;
        Path[i].pointSprite.Material.MaterialOptions.Diffuse := C_SELECT_COLOR;
      end;
    end
    else
      Path[i].pointSprite.Material.MaterialOptions.Diffuse := C_NORMAL_COLOR;
end;

end.
