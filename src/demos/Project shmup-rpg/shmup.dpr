{
  �������� Shoot 'em up.

  ����� ����������: 17 ������� 2013.
  ��������� ����������: ---

+ BUG #1: ������� �������� � visible false
+ BUG #2: ������������ ������� ��������� � ����������
+ BUG #3: AV ��� ������ ���� �� ������� ������ ��� TpdAccum
+ BUG #4: �� �������� ������
+ BUG #5: �������� ������ ������������ ���� ��� ����� �� ���������
+ BUG #6: ��� ��������, ����� ������ ������ � ������
+ BUG #7: ������� �� ����������������� ����� ��������
+ BUG #8: "����" �������� ��� ������������
+ BUG #9: ����� �� ��������������, ���� ��� ����������� WASD �� ������� ����
  BUG #10: ����� ���������� ��������, ���� ��������� ����� � ����� ��, ���� ���� ���� ���� ������
+ BUG #11: ����� ��������� � �������������� �������
  BUG #12: ������� ����� ������ ������
+ BUG #13: �� ���� ����� ��� ������� "����������" - ���������� ����� ����
+ BUG #14: �� ���� ����� � �������� ���� - �������� ����������� � �������������� ���� ����
  BUG #15: �������� ��������� � ������� ������
 !BUG #16: EInvalidOp �����. �����, ��� ���� � �������� LinerVelocity.Length
           �� ����, ��� � ���
  BUG #17: ������ �������� � ���� �����
+ BUG #18: ������ �� ��������������������

  TODO �� ����������:
+   �������� 1: �� ������������ �� WASD, �������������� �� �����, "��������"
+   �������� 2: ������������ �� ����� ����� ������ � ��, ������� ����� ���� �����
+   �������� 3: ����, �������� � ������
+   �������� 4: ���(���) ������, ����������� ���������,
+   �������� 5: �������� � ������ ��, �������, ������ ��� ��������
+   �������� 6: ������ � ������� �� ������, ����������� ����������� ��������
    �������� 7: ����������� ����, ������������ �������, ������� ��������,
    �������� �: �������� ������ ��������

  TODO:
+   ��������� ����������� ��������� - ���� ��� ��� ��� :)
+   player.Hit, ����� ������� ������������ � ��
+   ������� �������
+   �������� ����������� �����������
+   ����������� Z-index ��� �������� � glRenderer
+   ���������� �������
+   ���������
+   ���������� ��� gameover?
+   ��������� ����
+   ������ ���� ��� ��������
+   ������� ������ (+ ������ ������� �� ������, �����)
+   �������� ������ �������� ��� ������ � ������������ �� ���������
+   �������� ������
+   ����������� ����� ��� ������ ��� ����� ����������� ����������
    ��������������� ������?
    HUD - ������, ������� � ����
+-  ������� �������� ����� ����
+-  �������� ������
    ���� �� ����� �� �����
    ���� �������
    ���� ��������
    ���� ��������
    ��������� ������
    ������� ������
    ������ � �����������
    �������� ������� � ������� .atlas. ������� ��������� �������

    ������� ������ �������, ����� ������� ��������� ��������� �������������
      (��������� ������ ���� ��� ��������, ����� ��������) ���?


  �����

  2013-02-17 - ����� �������� �1. ��������� ��� #1
  2013-02-18 - ��� #1 ��������� � glRenderer (�������� visible � scene2d)
               ����� �������� �2.
  2013-02-19 - ����� �������� �3, ��������� ��� � ������.
  2013-02-20 - ����� ��������� ����� �� ������.
  2013-02-21 - ����� ����� �������� �4. �������� �������� ������ ���� ���
               ������� ������
               ���������� �� ������
  2013-02-23 - ���������� ����� ����: ��, ��� ���� ������, ������ ��� ����
  2013-02-24 - ������� ��������� ��������� ��� ������� ���� ������. ��������
               �������� :)
  2013-02-28 - � �������� ������� ����� �������� ����
  2013-03-01 - ������ ������,
               ��������� ���������� �������
               �������� ������
               ������� ����� �� �������
  2013-03-03 - �������� � ������ ��, �������
               �������� �5 �����
  2013-03-04 - ����������� ����������� �����.
               ������������ dropItems, bullets, enemies ���������� �� TpdAccum
               ��������� ��� #3
               ��������� ��� #4
               ��������� ����������� �������: ���� �� ��������, �������
               ������ ������� �������� ��������
  2013-03-05 - �������� ���������
               ��������� ���������� - �������� ��������
               ��������� �������� ������
               ��������������� ��������� ������ - ���� ��� ����, ������ �� �����
               ��������� ���������� �������
               ----
               ����� �������� �6
               �������� ��������� ����
  2013-03-07 - ��������� ������ ������� �� ��� ������� ������
               �������� ���������� ��������, ��������� ������ ����� ������
               ���� � ����������� �� ������
               ���������� ���� 6,7,8.
               ��� #6 ��������� �������� ����������� Length ����� postion � mousePos
               ��������� ��� #9
  2013-03-15 - ������ ������ ����� ��� �� ��������. ������ ������� ������� ���
               �������� ����
               Z_--- ��������� ��� Z-�������� ������ �������� (�����, �����, ������)
               ������� ������ ������� ��� ������. ���� �������� � ��������
               �����, �������� ������������ ������, ����������. ������� ������
               "�������������", ��� ��� ����������� ���������� �� ������
  2013-03-16 - ����� ��� #11
  2013-03-18 - ����� �������� ������. ���� ������ �������� � ������������ �����
               ��������, �������� ���������� ��������
  2013-03-21 - ����� ���������, ���� ��������� � ���������. ��� � ���� ��������
  2013-03-25 - #15 ��������� - wrap ��������� � clamp


}

program shmup;

uses
  Windows,
  SysUtils,
  dfHEngine in '..\..\common\dfHEngine.pas',
  dfHGL in '..\..\common\dfHGL.pas',
  dfMath in '..\..\common\dfMath.pas',
  dfHRenderer in '..\..\headers\dfHRenderer.pas',
  dfHUtility in '..\..\headers\dfHUtility.pas',
  uWeapons in 'uWeapons.pas',
  uGlobal in 'uGlobal.pas',
  uPlayer in 'uPlayer.pas',
  uEnemies in 'uEnemies.pas',
  uDrop in 'uDrop.pas',
  uAccum in 'uAccum.pas',
  uPopup in 'uPopup.pas',
  uButtonsInfo in 'gamescreens\uButtonsInfo.pas',
  uGameScreen.Authors in 'gamescreens\uGameScreen.Authors.pas',
  uGameScreen.MainMenu in 'gamescreens\uGameScreen.MainMenu.pas',
  uGameScreen.ArenaGame in 'gamescreens\uGameScreen.ArenaGame.pas',
  uGameScreen in 'gamescreens\uGameScreen.pas',
  uGameScreenManager in 'gamescreens\uGameScreenManager.pas',
  uBox2DImport in '..\..\headers\box2d\uBox2DImport.pas',
  UPhysics2D in '..\..\headers\box2d\UPhysics2D.pas',
  UPhysics2DTypes in '..\..\headers\box2d\UPhysics2DTypes.pas',
  uStaticObjects in 'uStaticObjects.pas',
  uGameScreen.PauseMenu in 'gamescreens\uGameScreen.PauseMenu.pas',
  uGameScreen.Settings in 'gamescreens\uGameScreen.Settings.pas';

const
  VERSION = '0.10';
  BACK_TEXTURE = RES_FOLDER + 'map.tga';

var
  gsManager: TpdGSManager;

  procedure OnUpdate(const dt: Double);
  begin
    if GSManager.IsQuitMessageReceived then
      R.Stop();
    gsManager.Update(dt);
  end;

  procedure OnMouseMove(X, Y: Integer; Shift: TglrMouseShiftState);
  begin
    if Assigned(gsManager.Current) then
      gsManager.Current.OnMouseMove(X, Y, Shift);
    mousePos.X := X;
    mousePos.Y := Y;
  end;

  procedure OnMouseDown(X, Y: Integer; MouseButton: TglrMouseButton;
    Shift: TglrMouseShiftState);
  begin
    if Assigned(gsManager.Current) then
      gsManager.Current.OnMouseDown(X, Y, MouseButton, Shift);
    mousePos.X := X;
    mousePos.Y := Y;
  end;

  procedure OnMouseUp(X, Y: Integer; MouseButton: TglrMouseButton;
    Shift: TglrMouseShiftState);
  begin
    if Assigned(gsManager.Current) then
      gsManager.Current.OnMouseUp(X, Y, MouseButton, Shift);
    mousePos.X := X;
    mousePos.Y := Y;
  end;

begin
  LoadRendererLib();
  R := glrCreateRenderer();
  R.Init('settings_shmup.txt');
  Factory := glrGetObjectFactory();

  gl.Init();
  R.OnUpdate := OnUpdate;
  R.OnMouseMove := OnMouseMove;
  R.OnMouseDown := OnMouseDown;
  R.OnMouseUp := OnMouseUp;
  R.Camera.ProjectionMode := pmOrtho;
  R.WindowCaption := PWideChar('Shoot ''em up. ��������. ������ '
    + VERSION + ' [glRenderer ' + R.VersionText + ']');

  mainMenu := TpdMainMenu.Create();
  arenaGame := TpdArenaGame.Create();
//  authors := TpdAuthors.Create();
  pauseMenu := TpdPauseMenu.Create();

  mainMenu.SetGameScreenLinks({authors} nil, arenaGame);
//  authors.SetGameScreenLinks(mainMenu, 'http://perfect-daemon.blogspot.ru/');
  arenaGame.SetGameScreenLinks(pauseMenu);
  pauseMenu.SetGameScreenLinks(mainMenu, arenaGame);

  gsManager := TpdGSManager.Create();
  gsManager.Add(mainMenu);
//  gsManager.Add(authors);
  gsManager.Add(arenaGame);
  gsManager.Add(pauseMenu);

//  gsManager.Notify(mainMenu, naSwitchTo);
  gsManager.Notify(arenaGame, naSwitchTo);

  R.Start();

  gsManager.Free();
  R.DeInit();
  UnLoadRendererLib();
end.
