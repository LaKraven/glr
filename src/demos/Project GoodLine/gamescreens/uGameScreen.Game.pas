unit uGameScreen.Game;

interface

uses
  Contnrs,
  glr, glrUtils, glrMath,
  uGameScreen, uGlobal;

const
  TIME_FADEIN  = 1.5;
  TIME_FADEOUT = 0.2;

  PAUSE_TEXT_X = 500;
  PAUSE_TEXT_Y = 10;

  BTN_MENU_X = PAUSE_TEXT_X + 130;
  BTN_MENU_Y = PAUSE_TEXT_Y + 70;

  BTN_CONTINUE_X = PAUSE_TEXT_X - 130;
  BTN_CONTINUE_Y = BTN_MENU_Y;

type
  TpdGame = class (TpdGameScreen)
  private
    FMainScene, FHUDScene: Iglr2DScene;
    FScrGameOver, FScrMenu: TpdGameScreen;

    FPause: Boolean;
    FPauseText: IglrText;
    FBtnMenu, FBtnContinue: IglrGUITextButton;

    {$IFDEF DEBUG}
    FFPSCounter: TglrFPSCounter;
    FDebug: TglrDebugInfo;
    {$ENDIF}

    Ft: Single; //����� ��� ������� �������� fadein/fadeout
    FFakeBackground: IglrSprite;

    procedure LoadHUD();
    procedure FreeHUD();

    procedure DoUpdate(const dt: Double);
  protected
    procedure FadeIn(deltaTime: Double); override;
    procedure FadeOut(deltaTime: Double); override;

    procedure SetStatus(const aStatus: TpdGameScreenStatus); override;
    procedure FadeInComplete();
    procedure FadeOutComplete();
  public
    constructor Create(); override;
    destructor Destroy; override;

    procedure Load(); override;
    procedure Unload(); override;

    procedure Update(deltaTime: Double); override;

    procedure SetGameScreenLinks(aGameOver: TpdGameScreen; aMenu: TpdGameScreen);

    procedure OnMouseMove(X, Y: Integer; Shift: TglrMouseShiftState); override;
    procedure OnMouseDown(X, Y: Integer; MouseButton: TglrMouseButton; Shift: TglrMouseShiftState); override;
    procedure OnMouseUp(X, Y: Integer; MouseButton: TglrMouseButton; Shift: TglrMouseShiftState); override;
    procedure OnGameOver();
    procedure PauseOrContinue();
  end;

var
  game: TpdGame;

implementation

uses
  uGameScreen.GameOver,
  Windows, SysUtils,
  dfTweener, ogl;


procedure MouseClick(Sender: IglrGUIElement; X, Y: Integer; mb: TglrMouseButton;
  Shift: TglrMouseShiftState);
begin
  sound.PlaySample(sClick);
  with game do
    if Sender = (FBtnMenu as IglrGUIElement) then
      OnNotify(FScrMenu, naSwitchTo)
    else if Sender = (FBtnContinue as IglrGUIElement) then
      PauseOrContinue();
end;

{ TpdGame }

constructor TpdGame.Create;
begin
  inherited;

  FMainScene := Factory.New2DScene();
  FHUDScene := Factory.New2DScene();

  uGlobal.mainScene := FMainScene;
  uGlobal.hudScene := FHUDScene;
end;

destructor TpdGame.Destroy;
begin
  Unload();

  FMainScene := nil;
  FHUDscene := nil;
  uGlobal.mainScene := nil;
  uGlobal.hudScene := nil;
  inherited;
end;

procedure TpdGame.DoUpdate(const dt: Double);
begin
  {$IFDEF DEBUG}
  if R.Input.IsKeyPressed(VK_I) then
  begin
    FDebug.FText.Visible := not FDebug.FText.Visible;
    FFPSCounter.TextObject.Visible := not FFPSCounter.TextObject.Visible;
  end;
  FFpsCounter.Update(dt);
  {$ENDIF}

  if R.Input.IsKeyPressed(VK_ESCAPE) then
    PauseOrContinue();

  if FPause then
    Exit();

  //code here
end;

procedure TpdGame.FadeIn(deltaTime: Double);
begin
  if Ft <= 0 then
    inherited
  else
  begin
    Ft := Ft - deltaTime;
    FFakeBackground.Material.PDiffuse.w := Ft / TIME_FADEIN;
  end;
end;

procedure TpdGame.FadeInComplete;
begin
  FFakeBackground.Visible := False;
  Status := gssReady;
end;

procedure TpdGame.FadeOut(deltaTime: Double);
begin
  if Ft <= 0 then
    inherited
  else
  begin
    Ft := Ft - deltaTime;
    FFakeBackground.Material.PDiffuse.w := 1 - Ft / TIME_FADEOUT;
  end;
end;

procedure TpdGame.FadeOutComplete;
begin
  Status := gssNone;
  Unload();
end;

procedure TpdGame.FreeHUD;
begin
  {$IFDEF DEBUG}
  if Assigned(FDebug) then
    FreeAndNil(FDebug);
  if Assigned(FFPSCounter) then
    FreeAndNil(FFPSCounter);
  {$ENDIF}
  //*
end;


procedure TpdGame.Load;
begin
  inherited;
  if FLoaded then
    Exit();

  sound.PlayMusic(musicIngame);

  FPause := False;

  gl.ClearColor(0, 30 / 255, 60 / 250, 1.0);
  FMainScene.RootNode.RemoveAllChilds();
  FMainScene.RootNode.Position := dfVec3f(0, 0, 0);
  FHudScene.RootNode.RemoveAllChilds();

  LoadHUD();
  //Load here

  FFakeBackground := Factory.NewHudSprite();
  with FFakeBackground do
  begin
    Position := dfVec3f(0, 0, 100);
    Material.Diffuse := dfVec4f(1, 1, 1, 1);
    Material.Texture.BlendingMode := tbmTransparency;
    Width := R.WindowWidth;
    Height := R.WindowHeight;
  end;
  FHUDScene.RootNode.AddChild(FFakeBackground);

  R.RegisterScene(FMainScene);
  R.RegisterScene(FHUDScene);

  FLoaded := True;
end;

procedure TpdGame.LoadHUD;
begin
  {$IFDEF DEBUG}
  FFPSCounter := TglrFPSCounter.Create(FHUDScene, 'FPS:', 1, nil);
  FFPSCounter.TextObject.Material.Diffuse := dfVec4f(0, 0, 0, 1);
  FFPSCounter.TextObject.Visible := False;

  FDebug := TglrDebugInfo.Create(FHUDScene.RootNode);
  FDebug.FText.Material.Diffuse := dfVec4f(0, 0, 0, 1);
  FDebug.FText.Visible := False;
  FDebug.FText.PPosition.y := 20;
  {$ENDIF}

  FBtnMenu := Factory.NewGUITextButton();
  with FBtnMenu do
  begin
    PivotPoint := ppCenter;
    Position := dfVec3f(BTN_MENU_X, BTN_MENU_Y, Z_HUD);

    with TextObject do
    begin
      Font := fontSouvenir;
      Text := '��������� � ����';
      PivotPoint := ppTopLeft;
      Position2D := dfVec2f(BTN_TEXT_OFFSET_X, BTN_TEXT_OFFSET_Y);
      Material.Diffuse := colorWhite;
    end;
    TextureNormal := atlasMain.LoadTexture(BTN_NORMAL_TEXTURE);
    TextureOver := atlasMain.LoadTexture(BTN_OVER_TEXTURE);
    TextureClick := atlasMain.LoadTexture(BTN_CLICK_TEXTURE);

    UpdateTexCoords();
    SetSizeToTextureSize();

    Visible := False;
    OnMouseClick := MouseClick;
  end;
  FHUDScene.RootNode.AddChild(FBtnMenu);

  FBtnContinue := Factory.NewGUITextButton();
  with FBtnContinue do
  begin
    PivotPoint := ppCenter;
    Position := dfVec3f(BTN_CONTINUE_X, BTN_CONTINUE_Y, Z_HUD);

    with TextObject do
    begin
      Font := fontSouvenir;
      Text := '����������';
      PivotPoint := ppTopLeft;
      Position2D := dfVec2f(BTN_TEXT_OFFSET_X, BTN_TEXT_OFFSET_Y);
      Material.Diffuse := colorWhite;
    end;
    TextureNormal := atlasMain.LoadTexture(BTN_NORMAL_TEXTURE);
    TextureOver := atlasMain.LoadTexture(BTN_OVER_TEXTURE);
    TextureClick := atlasMain.LoadTexture(BTN_CLICK_TEXTURE);

    UpdateTexCoords();
    SetSizeToTextureSize();

    Visible := False;
    OnMouseClick := MouseClick;
  end;
  FHUDScene.RootNode.AddChild(FBtnContinue);

  FPauseText := Factory.NewText();
  with FPauseText do
  begin
    Font := fontSouvenir;
    Text := '�����';
    PivotPoint := ppCenter;
    Position := dfVec3f(PAUSE_TEXT_X, PAUSE_TEXT_Y, Z_HUD);
    Material.Diffuse := colorWhite;
    Visible := False;
  end;
  FHUDScene.RootNode.AddChild(FPauseText);
end;

procedure TpdGame.SetGameScreenLinks(aGameOver: TpdGameScreen; aMenu: TpdGameScreen);
begin
  FScrGameOver := aGameOver;
  FScrMenu := aMenu;
end;

procedure TpdGame.SetStatus(const aStatus: TpdGameScreenStatus);
begin
  inherited;
  case aStatus of
    gssNone: Exit;

    gssReady: Exit;

    gssFadeIn:
    begin
      FFakeBackground.Visible := True;
      Ft := TIME_FADEIN;
    end;

    gssFadeInComplete: FadeInComplete();

    gssFadeOut:
    begin
      FFakeBackground.Visible := True;
      Ft := TIME_FADEOUT;
    end;

    gssFadeOutComplete: FadeOutComplete();
  end;
end;

procedure TpdGame.Unload;
begin
  inherited;
  if not FLoaded then
    Exit();

  FreeHUD();

  R.GUIManager.UnregisterElement(FBtnMenu);

  R.UnregisterScene(FMainScene);
  R.UnregisterScene(FHUDScene);

  FLoaded := False;
end;

procedure TpdGame.Update(deltaTime: Double);
begin
  inherited;
  case FStatus of
    gssFadeIn  : FadeIn(deltaTime);
    gssFadeOut : FadeOut(deltaTime);
    gssReady   : DoUpdate(deltaTime);
  end;
end;

procedure TpdGame.OnMouseMove(X, Y: Integer; Shift: TglrMouseShiftState);
begin
  if status <> gssReady then
    Exit();
end;

procedure TpdGame.OnGameOver;
begin
  //todo - ���-�� ���������
  OnNotify(FScrGameOver, naShowModal);
end;

procedure TpdGame.OnMouseDown(X, Y: Integer; MouseButton: TglrMouseButton;
  Shift: TglrMouseShiftState);
begin
  if status <> gssReady then
    Exit();
end;

procedure TpdGame.OnMouseUp(X, Y: Integer; MouseButton: TglrMouseButton;
  Shift: TglrMouseShiftState);
begin
  if status <> gssReady then
    Exit();
end;

procedure TpdGame.PauseOrContinue;
begin
  FPause := not FPause;
  FPauseText.Visible := FPause;
  FBtnMenu.Visible := FPause;
  FBtnContinue.Visible := FPause;
  if FPause then
  begin
    R.GUIManager.RegisterElement(FBtnMenu);
    R.GUIManager.RegisterElement(FBtnContinue);
  end
  else
  begin
    R.GUIManager.UnregisterElement(FBtnMenu);
    R.GUIManager.UnregisterElement(FBtnContinue);
  end;
end;

end.
