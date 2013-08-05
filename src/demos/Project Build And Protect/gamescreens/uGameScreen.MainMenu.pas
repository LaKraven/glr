unit uGameScreen.MainMenu;

interface

uses
  dfHRenderer, uSettings_SaveLoad,
  uGameScreen;

const
  SETTINGS_FILE = 'rds.txt';

  //����� ����� ������/�������
  TIME_FADEIN  = 0.65;
  TIME_FADEOUT = 0.7;

  //����� � ����� ��� ��������� ��������� ��� �����
  TIME_NG = 2.3; TIME_NG_PAUSE = 0.6;
  TIME_SN = 2.3; TIME_SN_PAUSE = 0.8;
  TIME_EX = 2.3; TIME_EX_PAUSE = 0.9;

  TIME_ABOUTTEXT = 1.7; TIME_ABOUTTEXT_PAUSE = 1.2;

  ABOUT_OFFSET_Y = -75;
type
  TpdMainMenu = class (TpdGameScreen)
  private
    FGUIManager: IglrGUIManager;
    FScene: Iglr2DScene;
    FScrGame: TpdGameScreen;

    //������
    FBtnNewGame, FBtnSettings, FBtnExit: IglrGUIButton;
    FFakeBackground: IglrSprite;

    FAboutText: IglrText;

    FSettingsShowed: Boolean;
    Ft: Single; //����� ��� ��������

    //--settings menu
    FMusicText, FSoundText: IglrText;
    FSoundVol, FMusicVol: IglrGUISlider;

    FBtnBack: IglrGUIButton;

    //--settings file
    FSettingsFile: TpdSettingsFile;

    procedure LoadBackground();
    procedure LoadButtons();
    procedure LoadText();

    procedure LoadSettingsMenu();

    procedure ShowSettings();
    procedure HideSettings();
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

    procedure SetGameScreenLinks(aGame: TpdGameScreen);

    procedure UpdateSettings();
  end;

var
  mainMenu: TpdMainMenu;

implementation

uses
  Windows,
  dfMath, dfHGL, dfTweener,
  uGlobal;

const
  //New game
  PLAY_X      = 512;
  PLAY_Y      = 250;

  //About
  SETTINGS_X  = PLAY_X - 150;
  SETTINGS_Y  = PLAY_Y + 140;

  //Exit
  EXIT_X      = PLAY_X + 150;
  EXIT_Y      = SETTINGS_Y;

  //Settings offset
  TEXT_MUSIC_X = 200;
  TEXT_MUSIC_Y = 200;

  TEXT_SOUND_X = TEXT_MUSIC_X;
  TEXT_SOUND_Y = TEXT_MUSIC_Y + 50;

  TEXT_ONLINE_X = TEXT_MUSIC_X;
  TEXT_ONLINE_Y = TEXT_SOUND_Y + 50;

  TEXT_CONTROL_X = TEXT_MUSIC_X;
  TEXT_CONTROL_Y = TEXT_ONLINE_Y + 50;

  SLIDER_SOUND_X = 450;
  SLIDER_SOUND_Y = TEXT_SOUND_Y + 10;

  SLIDER_MUSIC_X = SLIDER_SOUND_X;
  SLIDER_MUSIC_Y = TEXT_MUSIC_Y + 10;

  CB_ONLINE_X    = SLIDER_SOUND_X + 100;
  CB_ONLINE_Y    = TEXT_ONLINE_Y - 5;

  CB_CONTROL_X    = CB_ONLINE_X;
  CB_CONTROL_Y    = TEXT_CONTROL_Y - 5;

  HINT_ONLINE_X         = TEXT_MUSIC_X;
  HINT_ONLINE_OFFSET_Y  = -60; //Offset, ��� ��� ������������� �����
  HINT_CONTROL_X        = TEXT_MUSIC_X;
  HINT_CONTROL_OFFSET_Y = -60; //Offset, ��� ��� ������������� �����

  BTN_BACK_X = 900;
  BTN_BACK_Y = 350;

procedure OnMouseClick(Sender: IglrGUIElement; X, Y: Integer; mb: TglrMouseButton;
  Shift: TglrMouseShiftState);
begin
  sound.PlaySample(sClick);
  with mainMenu do
    if Sender = (FBtnNewGame as IglrGUIElement) then
    begin
      OnNotify(FScrGame, naSwitchTo);
    end

    else if Sender = (FBtnSettings as IglrGUIElement) then
    begin
      ShowSettings();
    end

    else if Sender = (FBtnBack as IglrGUIElement) then
    begin
      HideSettings();
      UpdateSettings();
      FSettingsFile.SaveToFile(SETTINGS_FILE);
    end

    else if Sender = (FBtnExit as IglrGUIElement) then
    begin
      OnNotify(nil, naQuitGame);
    end;
end;

procedure OnVolumeChanged(Sender: IglrGUIElement; aNewValue: Integer);
begin
  with mainMenu do
    if Sender = FSoundVol as IglrGUIElement then
      sound.SoundVolume := aNewValue / 100
    else if Sender = FMusicVol as IglrGUIElement then
      sound.MusicVolume := aNewValue / 100;
end;

procedure TweenSceneOrigin(aObject: TdfTweenObject; aValue: Single);
begin
  with aObject as TpdMainMenu do
    FScene.Origin := dfVec2f(aValue, 0);
end;

{ TpdMainMenu }

constructor TpdMainMenu.Create;
begin
  inherited;
  FGUIManager := R.GUIManager;
  FScene := Factory.New2DScene();

  LoadBackground();
  LoadButtons();
  LoadText();
  LoadSettingsMenu();

  //��������� ��� fade in/out
  FFakeBackground := Factory.NewHudSprite();
  FFakeBackground.Position := dfVec2f(0, 0);
  FFakeBackground.Z := 100;
  FFakeBackground.Material.MaterialOptions.Diffuse := dfVec4f(1, 1, 1, 1);
  FFakeBackground.Material.Texture.BlendingMode := tbmTransparency;
  FFakeBackground.Width := R.WindowWidth;
  FFakeBackground.Height := R.WindowHeight;
  FScene.RegisterElement(FFakeBackground);

  FSettingsFile := TpdSettingsFile.Initialize(SETTINGS_FILE);
end;

destructor TpdMainMenu.Destroy;
begin
  FScene.UnregisterElements();
  UpdateSettings();
  FSettingsFile.SaveToFile(SETTINGS_FILE);
  FSettingsFile.Free();
  inherited;
end;

procedure TpdMainMenu.FadeIn(deltaTime: Double);
begin
  if Ft <= 0 then
    inherited
  else
  begin
    Ft := Ft - deltaTime;
    FFakeBackground.Material.MaterialOptions.PDiffuse.w := Ft / TIME_FADEIN;
  end;
end;

procedure TpdMainMenu.FadeInComplete;
begin
  Status := gssReady;

  FGUIManager.RegisterElement(FBtnNewGame);
  FGUIManager.RegisterElement(FBtnSettings);
  FGUIManager.RegisterElement(FBtnExit);
end;

procedure TpdMainMenu.FadeOut(deltaTime: Double);
begin
  if Ft <= 0 then
    inherited
  else
  begin
    Ft := Ft - deltaTime;
    FFakeBackground.Material.MaterialOptions.PDiffuse.w := 1 - Ft / TIME_FADEOUT;
  end;
end;

procedure TpdMainMenu.FadeOutComplete;
begin
  Status := gssNone;
end;

procedure TpdMainMenu.HideSettings;
begin
  if not FSettingsShowed then
    Exit();

  FGUIManager.UnregisterElement(FSoundVol);
  FGUIManager.UnregisterElement(FMusicVol);
  FGUIManager.UnregisterElement(FBtnBack);
  Tweener.AddTweenSingle(Self, @TweenSceneOrigin, tsExpoEaseIn, FScene.Origin.x, 0, 2.0, 0.0);
  FSettingsShowed := False;
end;

procedure TpdMainMenu.LoadButtons();
begin
  FBtnNewGame  := Factory.NewGUIButton();
  FBtnSettings := Factory.NewGUIButton();
  FBtnExit     := Factory.NewGUIButton();

  with FBtnNewGame do
  begin
    PivotPoint := ppCenter;
    Position := dfVec2f(PLAY_X, PLAY_Y);
    Z := Z_MAINMENU;
//    TextureNormal := atlasMain.LoadTexture(PLAY_NORMAL_TEXTURE);
//    TextureOver := atlasMain.LoadTexture(PLAY_OVER_TEXTURE);
//    TextureClick := atlasMain.LoadTexture(PLAY_CLICK_TEXTURE);

    UpdateTexCoords();
    SetSizeToTextureSize();
  end;

  with FBtnSettings do
  begin
    PivotPoint := ppCenter;
    Position := dfVec2f(SETTINGS_X, SETTINGS_Y);
    Z := Z_MAINMENU;
//    TextureNormal := atlasMain.LoadTexture(SETTINGS_NORMAL_TEXTURE);
//    TextureOver := atlasMain.LoadTexture(SETTINGS_OVER_TEXTURE);
//    TextureClick := atlasMain.LoadTexture(SETTINGS_CLICK_TEXTURE);

    UpdateTexCoords();
    SetSizeToTextureSize();
  end;

  with FBtnExit do
  begin
    PivotPoint := ppCenter;
    Position := dfVec2f(EXIT_X, EXIT_Y);
    Z := Z_MAINMENU;
//    TextureNormal := atlasMain.LoadTexture(EXIT_NORMAL_TEXTURE);
//    TextureOver := atlasMain.LoadTexture(EXIT_OVER_TEXTURE);
//    TextureClick := atlasMain.LoadTexture(EXIT_CLICK_TEXTURE);

    UpdateTexCoords();
    SetSizeToTextureSize();
  end;

  FBtnNewGame.OnMouseClick := OnMouseClick;
  FBtnSettings.OnMouseClick := OnMouseClick;
  FBtnExit.OnMouseClick := OnMouseClick;

  FScene.RegisterElement(FBtnNewGame);
  FScene.RegisterElement(FBtnSettings);
  FScene.RegisterElement(FBtnExit);
end;

procedure TpdMainMenu.LoadSettingsMenu;
begin
  FMusicText := Factory.NewText();
  FSoundText := Factory.NewText();

  FSoundVol  := Factory.NewGUISlider();
  FMusicVol  := Factory.NewGUISlider();

  FBtnBack := Factory.NewGUIButton();

  with FMusicText do
  begin
    Font := fontCooper;
    Text := '������';
    Z := Z_MAINMENU;
    PivotPoint := ppTopLeft;
    Position := dfVec2f(TEXT_MUSIC_X - R.WindowWidth, TEXT_MUSIC_Y);
    Material.MaterialOptions.Diffuse := dfVec4f(131 / 255, 217 / 255, 16 / 255, 1.0);
  end;

  with FSoundText do
  begin
    Font := fontCooper;
    Text := '����';
    Z := Z_MAINMENU;
    PivotPoint := ppTopLeft;
    Position := dfVec2f(TEXT_SOUND_X - R.WindowWidth, TEXT_SOUND_Y);
    Material.MaterialOptions.Diffuse := dfVec4f(131 / 255, 217 / 255, 16 / 255, 1.0);
  end;

  //Sliders
  with FSoundVol do
  begin
    Material.Texture := atlasMain.LoadTexture(SLIDER_BACK);
    UpdateTexCoords();
    SetSizeToTextureSize();
    with SliderButton do
    begin
      Material.Texture := atlasMain.LoadTexture(SLIDER_BTN);
      UpdateTexCoords();
      SetSizeToTextureSize();
    end;

    with SliderOver do
    begin
      Material.Texture := atlasMain.LoadTexture(SLIDER_OVER);
      UpdateTexCoords();
      SetSizeToTextureSize();
    end;
    Z := Z_MAINMENU;
    Position := dfVec2f(SLIDER_SOUND_X - R.WindowWidth, SLIDER_SOUND_Y);
    OnValueChanged := OnVolumeChanged;
  end;

  with FMusicVol do
  begin
    Material.Texture := atlasMain.LoadTexture(SLIDER_BACK);
    UpdateTexCoords();
    SetSizeToTextureSize();
    with SliderButton do
    begin
      Material.Texture := atlasMain.LoadTexture(SLIDER_BTN);
      UpdateTexCoords();
      SetSizeToTextureSize();
    end;

    with SliderOver do
    begin
      Material.Texture := atlasMain.LoadTexture(SLIDER_OVER);
      UpdateTexCoords();
      SetSizeToTextureSize();
    end;
    Z := Z_MAINMENU;
    Position := dfVec2f(SLIDER_MUSIC_X - R.WindowWidth, SLIDER_MUSIC_Y);
    OnValueChanged := OnVolumeChanged;
  end;

  with FBtnBack do
  begin
    PivotPoint := ppCenter;
    Position := dfVec2f(BTN_BACK_X - R.WindowWidth, BTN_BACK_Y);
    Z := Z_MAINMENU;
//    TextureNormal := atlasMain.LoadTexture(BACK_NORMAL_TEXTURE);
//    TextureOver := atlasMain.LoadTexture(BACK_OVER_TEXTURE);
//    TextureClick := atlasMain.LoadTexture(BACK_CLICK_TEXTURE);

    UpdateTexCoords();
    SetSizeToTextureSize();
  end;
  FBtnBack.OnMouseClick := OnMouseClick;

  FScene.RegisterElement(FMusicText);
  FScene.RegisterElement(FSoundText);

  FScene.RegisterElement(FSoundVol);
  FScene.RegisterElement(FMusicVol);
  FScene.RegisterElement(FBtnBack);
end;

procedure TpdMainMenu.Load;
var
  int, ecode: Integer;
begin
  inherited;
  sound.PlayMusic(musicMenu);

  with FSettingsFile do
  begin
    Val(Settings[stMusicVolume], int, ecode);  FMusicVol.Value := int;
    Val(Settings[stSoundVolume], int, ecode);  FSoundVol.Value := int;
  end;

  R.RegisterScene(FScene);
end;

procedure TpdMainMenu.LoadBackground();
begin

end;

procedure TpdMainMenu.LoadText;
begin
  FAboutText := Factory.NewText();
  with FAboutText do
  begin
    Font := fontCooper;
    Text := 'Build & Protect! igdc #95 only!'#13#10'       by perfect.daemon';
    PivotPoint := ppBottomCenter;
    Position := dfVec2f(R.WindowWidth div 2, R.WindowHeight + ABOUT_OFFSET_Y);
    Z := Z_MAINMENU;
    Material.MaterialOptions.Diffuse := colorMain;
  end;

  FScene.RegisterElement(FAboutText);
end;

procedure TpdMainMenu.SetGameScreenLinks(aGame: TpdGameScreen);
begin
  FScrGame := aGame;
end;

procedure TpdMainMenu.SetStatus(const aStatus: TpdGameScreenStatus);
begin
  inherited;
  case aStatus of
    gssNone: Exit;

    gssReady: Exit;

    gssFadeIn:
    begin
      sound.PlayMusic(musicMenu);
      FFakeBackground.Visible := True;
      Ft := TIME_FADEIN;

      Tweener.AddTweenPSingle(@FBtnNewGame.PPosition.y, tsExpoEaseIn, -70, PLAY_Y, TIME_NG, TIME_NG_PAUSE);
      Tweener.AddTweenPSingle(@FBtnSettings.PPosition.x, tsExpoEaseIn, R.WindowWidth + 250, SETTINGS_X, TIME_SN, TIME_SN_PAUSE);
      Tweener.AddTweenPSingle(@FBtnExit.PPosition.y, tsExpoEaseIn, R.WindowHeight + 70, EXIT_Y, TIME_EX, TIME_EX_PAUSE);

      Tweener.AddTweenPSingle(@FAboutText.PPosition.y, tsExpoEaseIn,
        R.WindowHeight + 70, R.WindowHeight + ABOUT_OFFSET_Y, TIME_ABOUTTEXT, TIME_ABOUTTEXT_PAUSE);
    end;

    gssFadeInComplete: FadeInComplete();

    gssFadeOut:
    begin
      FFakeBackground.Visible := True;
      Ft := TIME_FADEOUT;
      FGUIManager.UnRegisterElement(FBtnNewGame);
      FGUIManager.UnregisterElement(FBtnSettings);
      FGUIManager.UnRegisterElement(FBtnExit);
      sound.SetMusicFade(musicMenu, 3000);
    end;

    gssFadeOutComplete: FadeOutComplete();
  end;
end;

procedure TpdMainMenu.ShowSettings;
begin
  if FSettingsShowed then
    Exit();

  FGUIManager.RegisterElement(FSoundVol);
  FGUIManager.RegisterElement(FMusicVol);
  FGUIManager.RegisterElement(FBtnBack);
  Tweener.AddTweenSingle(Self, @TweenSceneOrigin, tsExpoEaseIn, FScene.Origin.x, R.WindowWidth, 2.0, 0.0);

  FSettingsShowed := True;
end;

procedure TpdMainMenu.Unload;
begin
  inherited;

  R.UnregisterScene(FScene);
end;

procedure TpdMainMenu.Update(deltaTime: Double);
begin
  inherited;
  case FStatus of
    gssNone           : Exit;
    gssFadeIn         : FadeIn(deltaTime);
    gssFadeInComplete : Exit;
    gssFadeOut        : FadeOut(deltaTime);
    gssFadeOutComplete: Exit;

    gssReady:
    begin
      if (R.Input.IsKeyDown(VK_ESCAPE)) then
        if FSettingsShowed then
          HideSettings();
    end;
  end;
end;

procedure TpdMainMenu.UpdateSettings;
var
  tmpStr: String;
begin
  with FSettingsFile do
  begin
    Str(FSoundVol.Value, tmpStr);   Settings[stSoundVolume] := tmpStr;
    Str(FMusicVol.Value, tmpStr);   Settings[stMusicVolume] := tmpStr;
  end;
end;

end.
