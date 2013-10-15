unit uGlobal;

interface

uses
  glr, glrMath, glrUtils, uSound;

const
  GAMEVERSION = '0.02';

  RES_FOLDER = 'tetris-res\';

  Z_BLOCKS = 0;
  Z_BACKGROUND = -100;
  Z_MAINMENU = 25;
  Z_HUD = 50;
  Z_INGAMEMENU = 75;


  MUSIC_INGAME = RES_FOLDER + 'BoxCat Games - Battle.ogg';
  MUSIC_MENU = RES_FOLDER   + 'BoxCat Games - Inspiration.ogg';

  SOUND_CLICK   = RES_FOLDER + 'click.ogg';


  FILE_MAIN_TEXTURE_ATLAS = RES_FOLDER + 'atlas.atlas';

  BTN_NORMAL_TEXTURE  = 'btn_normal.png';
  BTN_OVER_TEXTURE    = 'btn_over.png';
  BTN_CLICK_TEXTURE   = 'btn_click.png';

  SLIDER_BACK = 'slider_back.png';
  SLIDER_OVER = 'slider_over.png';
  SLIDER_BTN  = 'slider_btn.png';

  CB_ON_TEXTURE       = 'cb_on.png';
  CB_OFF_TEXTURE      = 'cb_off.png';
  CB_ON_OVER_TEXTURE  = 'cb_on_over.png';
  CB_OFF_OVER_TEXTURE = 'cb_off_over.png';

  PARTICLE_TEXTURE  = 'particle.png';
  PARTICLE_TEXTURE2 = 'particle2.png';

  BLOCK_TEXTURE = 'block.png';

var
  //Renderer and scenes
  R: IglrRenderer;
  Factory: IglrObjectFactory;
  mainScene, hudScene{, globalScene}: Iglr2DScene;

  //Game objects


  //Game systems
  sound: TpdSoundSystem;

  //Sound & music
  sClick: LongWord;
  musicIngame, musicMenu: LongWord;

  //Resources
  atlasMain: TglrAtlas;
  fontSouvenir: IglrFont;

  //Colors
  colorRed: TdfVec4f    = (x: 188/255; y: 71/255;  z: 0.0; w: 1.0);
  colorGreen: TdfVec4f  = (x: 55/255; y: 160/255; z: 0.0; w: 1.0);
  colorWhite: TdfVec4f  = (x: 1.0; y: 1.0;  z: 1.0; w: 1.0);
  colorYellow: TdfVec4f = (x: 0.9; y: 0.93; z: 0.1; w: 1.0);
  colorGray2: TdfVec4f  = (x: 0.2; y: 0.2;  z: 0.2; w: 1.0);
  colorGray4: TdfVec4f  = (x: 0.4; y: 0.4;  z: 0.4; w: 1.0);
  colorOrange: TdfVec4f   = (x: 255/255; y: 125/255;  z: 8/255; w: 1.0);

  colorUnused: TdfVec4f = (x: 1.0; y: 1.0; z: 1.0; w: 0.3);
  colorUsed: array[1..4] of TdfVec4f =
  ((x: 255/255; y: 30/255;   z: 0.0;   w: 1.0), //red
   (x: 55/255;  y: 160/255;  z: 0.0;   w: 1.0), //green
   (x: 255/255; y: 125/255;  z: 8/255; w: 1.0), //orange
   (x: 0.9;     y: 0.93;     z: 0.1;   w: 1.0)); //yellow

procedure InitializeGlobal();
procedure FinalizeGlobal();

implementation

procedure InitializeGlobal();
begin
  atlasMain := TglrAtlas.InitCheetahAtlas(FILE_MAIN_TEXTURE_ATLAS);

  //--Font

  fontSouvenir := Factory.NewFont();
  with fontSouvenir do
  begin
    AddSymbols(FONT_USUAL_CHARS);
    FontSize := 18;
    GenerateFromTTF(RES_FOLDER + 'Souvenir Regular.ttf', 'Souvenir');
  end;

  //--Sound
  sound := TpdSoundSystem.Create(R.WindowHandle);

  musicIngame := sound.LoadMusic(MUSIC_INGAME);
  musicMenu := sound.LoadMusic(MUSIC_MENU);
  sClick := sound.LoadSample(SOUND_CLICK);
end;

procedure FinalizeGlobal();
begin
  sound.Free();
  atlasMain.Free();
end;

end.
