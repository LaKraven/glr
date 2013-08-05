{
  ���������������� �������� Node-������� � HUD-��������
}

program Checker2;

{$APPTYPE CONSOLE}

uses
  Windows,
  SysUtils,
  dfHRenderer in '..\..\headers\dfHRenderer.pas',
  dfHEngine in '..\..\common\dfHEngine.pas',
  dfMath in '..\..\common\dfMath.pas',
  dfHGL in '..\..\common\dfHGL.pas';

var
  R: IglrRenderer;
  Factory: IglrObjectFactory;
  Scene2d: Iglr2DScene;
  spr, pp: IglrSprite;

  deltaRot: Single;

  procedure OnMouseDown(X, Y: Integer; MouseButton: TglrMouseButton; Shift: TglrMouseShiftState);
  begin
    case spr.PivotPoint of
      ppTopLeft:
      begin
        spr.PivotPoint := ppTopRight;
        R.WindowCaption := 'TopRight';
      end;
      ppTopRight:
      begin
        spr.PivotPoint := ppBottomLeft;
        R.WindowCaption := 'BottomLeft';
      end;
      ppBottomLeft:
      begin
        spr.PivotPoint := ppBottomRight;
        R.WindowCaption := 'BottomRight';
      end;
      ppBottomRight:
      begin
        spr.PivotPoint := ppCenter;
        R.WindowCaption := 'Center';
      end;
      ppCenter:
      begin
        spr.PivotPoint := ppTopCenter;
        R.WindowCaption := 'TopCenter';
      end;
      ppTopCenter:
      begin
        spr.PivotPoint := ppBottomCenter;
        R.WindowCaption := 'BottomCenter';
      end;
      ppBottomCenter:
      begin
        spr.SetCustomPivotPoint(0.2, 0.7);
        spr.PivotPoint := ppCustom;
        R.WindowCaption := 'Custom';
      end;
      ppCustom:
      begin
        spr.PivotPoint := ppTopLeft;
        R.WindowCaption := 'TopLeft';
      end;
    end;
  end;

  procedure OnUpdate(const dt: Double);
  begin
    if R.Input.IsKeyDown(VK_ESCAPE) then
      R.Stop();
    spr.Rotation := spr.Rotation + deltaRot * dt;
    if spr.Rotation > 30 then
      deltaRot := -10
    else if spr.Rotation < -30 then
      deltaRot := 10;
  end;

begin
  WriteLn(' ========= Demonstration 2 ======== ');
  WriteLn(' ====== Press ESCAPE to EXIT ====== ');

  LoadRendererLib();

  R := glrCreateRenderer();
  Factory := glrGetObjectFactory();
  R.Init('settings.txt');
  R.OnMouseDown := OnMouseDown;
  R.OnUpdate := OnUpdate;
  Scene2d := Factory.New2DScene();
  R.RegisterScene(Scene2d);

  spr := Factory.NewHudSprite();
  pp := Factory.NewHudSprite();
  with spr do
  begin
    Width := 200;
    Height := 100;
    PivotPoint := ppTopLeft;
    Position := dfVec2f(300, 300);
    Material.Texture := Factory.NewTexture();
    Material.Texture.Load2D('data\tile.bmp');
    Material.MaterialOptions.Diffuse := dfVec4f(1, 1, 1, 1);
  end;
  Scene2d.RegisterElement(spr);

  with pp do
  begin
    Width := 200;
    Height := 100;
    PivotPoint := ppCenter;
    Position := dfVec2f(300, 300);
    Material.MaterialOptions.Diffuse := dfVec4f(1, 1, 1, 1);
    Width := 5;
    Height := 5;
    Z := 1;
  end;
  Scene2d.RegisterElement(pp);

  deltaRot := 10;

  R.Start();

  Scene2d.UnregisterElements();
  R.DeInit();
  R := nil;

  UnLoadRendererLib();
end.
