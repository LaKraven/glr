unit uInventory;

interface

uses
  glr, glrMath, uWorldObjects;

const
  //���� ������ �� ������� "�������� � ���������"
  INV_OK = 0;
  INV_NO_SLOTS = -1;
  INV_MAX_CAPACITY = -2;

  TIME_SHOW_HIDE = 0.8;
  COLUMNS = 3;
  COLUMN_WIDTH = 70;
  SLOT_COUNT = 3;

  SLOT_MAX_ITEM_COUNT = 9;

type
  TpdInvSlot = class
    backSprite: IglrSprite;
    item: TpdWorldObject;
    count: Integer;
    countText: IglrText;
    usualPos: TdfVec2f;

    function IsHit(aPos: TdfVec2f): Boolean;
    procedure UpdateCountText();

    procedure RemoveItemObject();

    function AddOneItem(): Integer;
    function RemoveOneItem(): Integer;

    constructor Create(); virtual;
    destructor Destroy(); override;
  end;

  TpdInventory = class
  private
    FCaptionText: IglrText;
    FCaptionTextUsualPos: TdfVec2f;
    FHintText: IglrText;
    FSlots: array of TpdInvSlot;
    FTexBack, FTexBackOver: IglrTexture;
    FVisible: Boolean;

    procedure Show();
    procedure Hide();
    procedure SetVisible(const Value: Boolean);
  public
    currentSlot: TpdInvSlot;
    //���������� ��� ������ �����-������
    onItemsChanged: procedure() of object;
    constructor Create(const aSlotCount: Integer); virtual;
    destructor Destroy(); override;

    procedure Update(const dt: Double);

    function GetSlotWithItem(aItemClass: TpdWorldObjectClass): TpdInvSlot;
    function GetFirstEmptySlot(): TpdInvSlot;

    property Visible: Boolean read FVisible write SetVisible;

    function AddObject(aObjectClass: TpdWorldObjectClass): Integer;
    procedure AddSlots(const aSlotCount: Integer);
  end;

procedure InitializeInventory();
procedure UpdateInventory(const dt: Double);
function InventoryOnMouseMove(X, Y: Integer; Shift: TglrMouseShiftState): Boolean;
function InventoryOnMouseDown(X, Y: Integer; MouseButton: TglrMouseButton;
  Shift: TglrMouseShiftState): Boolean;
function InventoryOnMouseUp(X, Y: Integer; MouseButton: TglrMouseButton;
  Shift: TglrMouseShiftState): Boolean;
procedure DeinitializeInventory();

var
  inventory: TpdInventory;
  dragObject: TpdInvSlot;
implementation

uses
  SysUtils,
  uGlobal, uPlayer, uWater, dfTweener;

const
  INVSLOT_TEXTURE = 'inventory_slot.png';
  INVSLOT_OVER_TEXTURE = 'inventory_slot_over.png';


{ TpdInvSlot }

function TpdInvSlot.AddOneItem: Integer;
begin
  if Assigned(item) then
    if count < SLOT_MAX_ITEM_COUNT then
    begin
      count := count + 1;
      UpdateCountText();
      Result := INV_OK;
    end
    else
      Result := INV_MAX_CAPACITY;
  if Assigned(inventory.onItemsChanged) then
    inventory.onItemsChanged();
end;

constructor TpdInvSlot.Create;
begin
  inherited;
  backSprite := Factory.NewHudSprite();
  backSprite.PPosition.z := Z_HUD;
  backSprite.PivotPoint := ppCenter;
  countText := Factory.NewText();
  countText.Font := fontCooper;
  countText.Material.Diffuse := dfVec4f(0, 0, 0, 1);
  countText.PPosition.z := Z_HUD + 2;
end;

destructor TpdInvSlot.Destroy;
begin
  if Assigned(item) then
    item.Free();
  inherited;
end;

function TpdInvSlot.IsHit(aPos: TdfVec2f): Boolean;
begin
  with backSprite do
    Result := (aPos.x > Position.x - Width / 2) and (aPos.x < Position.x + Width / 2)
          and (aPos.y > Position.y - Height / 2) and (aPos.y < Position.y + Height / 2);
end;

procedure TpdInvSlot.RemoveItemObject;
begin
  hudScene.RootNode.RemoveChild(item.sprite);
  item.Free();
  item := nil;
end;

function TpdInvSlot.RemoveOneItem: Integer;
begin
  if Assigned(item) then
  begin
    count := count - 1;
    if count = 0 then
      RemoveItemObject();
    UpdateCountText();
  end;
  if Assigned(inventory.onItemsChanged) then
    inventory.onItemsChanged();
end;

procedure TpdInvSlot.UpdateCountText;
begin
  if Assigned(item) then
    if count > 1 then
      countText.Text := IntToStr(count)
    else
      countText.Text := '';
end;

{ TpdInventory }

//--��� �����
procedure SetSingle(aObject: TdfTweenObject; aValue: Single);
begin
  with aObject as TpdInvSlot do
  begin
    backSprite.PPosition.x := aValue;
    if Assigned(item) then
      item.sprite.PPosition.x := aValue;
    countText.PPosition.x := aValue + 12;
  end;
end;

function TpdInventory.AddObject(aObjectClass: TpdWorldObjectClass): Integer;
var
  slot: TpdInvSlot;
begin
  slot := GetSlotWithItem(aObjectClass);
  if not Assigned(slot) then
  begin
    slot := GetFirstEmptySlot();
    if not Assigned(slot) then
      Exit(INV_NO_SLOTS);

    slot.item := aObjectClass.Initialize(hudScene);
    slot.item.status := sInventory;
    slot.item.sprite.Position := dfVec3f(slot.backSprite.Position2D, Z_HUD + 1);
    if aObjectClass = TpdTwig then
      slot.item.sprite.Rotation := 35;
    if aObjectClass = TpdKnife then
      slot.item.sprite.Rotation := 37;
  end;
  Result := slot.AddOneItem();
end;

procedure TpdInventory.AddSlots(const aSlotCount: Integer);
var
  i, aStart,
  rowNum, colNum: Integer;
  origin: TdfVec2f;
begin
  aStart := Length(FSlots);
  SetLength(FSlots, aStart + aSlotCount);

  rowNum := aStart div COLUMNS; //�������� �� ��������� ������
  colNum := 0;
  origin := dfVec2f(R.WindowWidth - 50, 250);
  for i := aStart to High(FSlots) do
  begin
    FSlots[i] := TpdInvSlot.Create();
    with FSlots[i] do
    begin
      usualPos := origin  + dfVec2f(- colNum * COLUMN_WIDTH, rowNum * COLUMN_WIDTH);
      backSprite.Position2D := dfVec2f(R.WindowWidth + 40, usualPos.y);
      backSprite.Material.Texture := FTexBack;
      backSprite.UpdateTexCoords();
      backSprite.SetSizeToTextureSize();
      hudScene.RootNode.AddChild(backSprite);
      count := 0;
      item := nil;
      countText.Position2D := backSprite.Position2D + dfVec2f(12, 4);
      hudScene.RootNode.AddChild(countText);
    end;
    colNum := colNum + 1;
    if colNum = COLUMNS then
    begin
      colNum := 0;
      rowNum := rowNum + 1;
    end;
  end;

  FHintText.Position2D := FSlots[High(FSlots)].usualPos + dfVec2f(-40, 40);
end;

constructor TpdInventory.Create(const aSlotCount: Integer);
begin
  inherited Create();
  currentSlot := nil;
  FVisible := False;

  FTexBack := atlasGame.LoadTexture(INVSLOT_TEXTURE);
  FTexBackOver := atlasGame.LoadTexture(INVSLOT_OVER_TEXTURE);

  FHintText := Factory.NewText();
  FHintText.Font := fontCooper;
  FHintText.Text := '';
  FHintText.ScaleMult(0.7);
  FHintText.PPosition.z := Z_HUD;
  hudScene.RootNode.AddChild(FHintText);

  AddSlots(aSlotCount);

  FCaptionTextUsualPos := dfVec2f(R.WindowWidth - 150, 180);

  FCaptionText := Factory.NewText();
  FCaptionText.Font := fontCooper;
  FCaptionText.Text := '���������';
  FCaptionText.Position := dfVec3f(R.WindowWidth + 20, FCaptionTextUsualPos.y, Z_HUD);
  hudScene.RootNode.AddChild(FCaptionText);
end;

destructor TpdInventory.Destroy;
var
  i: Integer;
begin
  for i := 0 to High(FSlots) do
    FSlots[i].Free();
  inherited;
end;

function TpdInventory.GetFirstEmptySlot: TpdInvSlot;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to High(FSlots) do
    if not Assigned(FSlots[i].item) then
      Exit(FSlots[i]);
end;

function TpdInventory.GetSlotWithItem(
  aItemClass: TpdWorldObjectClass): TpdInvSlot;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to High(FSlots) do
    if FSlots[i].item is aItemClass then
      Exit(FSlots[i]);
end;

procedure TpdInventory.Hide;
var
  i: Integer;
begin
  FVisible := False;
  Tweener.AddTweenPSingle(@FCaptionText.PPosition.x, tsElasticEaseIn,
    FCaptionText.Position.x, R.WindowWidth + 20, TIME_SHOW_HIDE + 0.5, 0.0);
  for i := 0 to High(FSlots) do
    Tweener.AddTweenSingle(FSlots[i], @SetSingle, tsExpoEaseIn,
      FSlots[i].backSprite.Position.x, R.WindowWidth + 40, TIME_SHOW_HIDE, 0.05 * i);
end;

procedure TpdInventory.SetVisible(const Value: Boolean);
begin
  if FVisible <> Value then
  begin
    FVisible := Value;
    if FVisible then
      Show()
    else
      Hide();
  end;
end;

procedure TpdInventory.Show;
var
  i: Integer;
begin
  FVisible := True;
  Tweener.AddTweenPSingle(@FCaptionText.PPosition.x, tsElasticEaseOut,
    FCaptionText.Position.x, FCaptionTextUsualPos.x, TIME_SHOW_HIDE + 0.5, 0.0);
  for i := 0 to High(FSlots) do
    Tweener.AddTweenSingle(FSlots[i], @SetSingle, tsExpoEaseIn,
      FSlots[i].backSprite.Position.x, FSlots[i].usualPos.x, TIME_SHOW_HIDE, 0.05 * i);
end;

procedure TpdInventory.Update(const dt: Double);
begin

end;

procedure InitializeInventory();
begin
  if Assigned(inventory) then
    inventory.Free();
  inventory := TpdInventory.Create(SLOT_COUNT);
end;

procedure UpdateInventory(const dt: Double);
begin
  inventory.Update(dt);
end;

function InventoryOnMouseMove(X, Y: Integer; Shift: TglrMouseShiftState): Boolean;
var
  i: Integer;
begin
  Result := False;
  inventory.FHintText.Visible := False;

  if Assigned(dragObject) then
    dragObject.item.sprite.Position2D := dfVec2f(X, Y);

  for i := 0 to High(inventory.FSlots) do
    with inventory do
    begin
      if FSlots[i].IsHit(dfVec2f(X, Y)) then
      begin
        if Assigned(currentSlot) and (currentSlot <> FSlots[i]) then
        begin
          //������� � ������ ������ over
          currentSlot.backSprite.Material.Texture := FTexBack;
          currentSlot.backSprite.UpdateTexCoords();
        end;
        //��������� ����� ������� ������
        currentSlot := FSlots[i];
        currentSlot.backSprite.Material.Texture := FTexBackOver;
        currentSlot.backSprite.UpdateTexCoords();

        //--debug
        cursorText.Text := '';
        if Assigned(currentSlot.item) then
        begin
          inventory.FHintText.Visible := True;
          inventory.FHintText.Text := currentSlot.item.HintText;
        end;
        Result := True;
      end
      else
        //���� ��� ��������� - ���������, ������� �� ��� ������.
        if FSlots[i] = currentSlot then
        begin
          //������� over, ��� ��� IsHit = false
          currentSlot.backSprite.Material.Texture := FTexBack;
          currentSlot.backSprite.UpdateTexCoords();
          currentSlot := nil;
        end;
    end;
end;

function InventoryOnMouseDown(X, Y: Integer; MouseButton: TglrMouseButton;
  Shift: TglrMouseShiftState): Boolean;
begin
  Result := False;
  if Assigned(inventory.currentSlot) then
    with inventory.currentSlot do
    begin
      Result := True;
      //Left - drag and drop
      if (MouseButton = mbLeft) and Assigned(inventory.currentSlot.item) then
      begin
        dragObject := inventory.currentSlot;
      end;
      //Right - ����������
      if MouseButton = mbRight then
      begin
        if Assigned(item) then
        begin
          item.OnUse();
          if item.removeOnUse then
            RemoveOneItem();
        end;
      end;
    end;
end;

procedure OnDragSuccess(aRemoveItem: Boolean = False);
begin
  if aRemoveItem then
    dragObject.RemoveOneItem();
  if (dragObject.count > 0) then
    dragObject.item.sprite.Position := dragObject.backSprite.Position;
  dragObject := nil;
end;

function CheckTwigAndGrass(): Boolean;
begin
  Result := False;
  //��������� �������!
  if (dragObject.item is TpdTwig) or (dragObject.item is TpdOldGrass) then
  begin
    player.speech.Say('����-���� ����!', 3);
    with (selectedWorldObject as TpdCampFire) do
      timeToLife := timeToLife + CAMPFIRE_TIME_ADD;
    OnDragSuccess(True);
    Result := True;
  end;
end;

function CheckBottle(): Boolean;
begin
  Result := False;
  //�����
  if (dragObject.item is TpdBottle) then
    with (dragObject.item as TpdBottle) do
    begin
      Result := True;
      if WaterLevel = 0 then
        player.speech.Say('�� ����� �����, ����� �� ���������?', 3)
      else
        case WaterStatus of
          bsWater:
          begin
            WaterStatus := bsHotWater;
            player.speech.Say('���������� � ������ ����!', 3);
          end;
          bsHotWater: ;
          bsRawTea:
          begin
            WaterStatus := bsTea;
            player.speech.Say('�-�, ����� ���� ���������!', 3);
          end;
          bsTea: ;
        end;

      OnDragSuccess(False);
    end;
end;

function CheckMushroomShashlik(): Boolean;
begin
  Result := False;
  //������� ������
  if (dragObject.item is TpdMushroomShashlikRaw) then
  begin
    Result := True;
    case inventory.AddObject(TpdMushroomShashlikHot) of
      INV_OK:
      begin
        player.speech.Say('�-�, ������� ��������!', 3);
        OnDragSuccess(True);
      end;
      INV_NO_SLOTS:
      begin
        NoPlaceToPut();
        OnDragSuccess(False);
      end;
      INV_MAX_CAPACITY:
      begin
        player.speech.Say('��������! � ���� ���'#13#10'������� �� ��������!', 3, colorYellow);
        OnDragSuccess(False);
      end;
    end;
  end;
end;

function CheckFishShashlik(): Boolean;
begin
  Result := False;
  //������ ������
  if (dragObject.item is TpdFishShashlikRaw) then
  begin
    Result := True;
    case inventory.AddObject(TpdFishShashlikHot) of
      INV_OK:
      begin
        player.speech.Say('�-�, ������� ��������!', 3);
        OnDragSuccess(True);
      end;
      INV_NO_SLOTS:
      begin
        NoPlaceToPut();
        OnDragSuccess(False);
      end;
      INV_MAX_CAPACITY:
      begin
        player.speech.Say('��������! � ���� ���'#13#10'������� �� ��������!', 3, colorYellow);
        OnDragSuccess(False);
      end;
    end;
  end;
end;

function InventoryOnMouseUp(X, Y: Integer; MouseButton: TglrMouseButton;
  Shift: TglrMouseShiftState): Boolean;
var
  dropPos: TdfVec2f;
  dropObj: TpdWorldObject;
begin
  Result := False;
  with inventory do
  begin
    if Assigned(dragObject) then
      if MouseButton = mbLeft then
      begin
        Result := True;
        //���������� ��� �� ���� �����, ���� ����������
        if Assigned(currentSlot) then
        begin
          OnDragSuccess(False);
          Exit();
        end;

        //--��������� ������
        if (dragObject.item is TpdBottle) and (Assigned(currentWater)) and (player.inWater) then
          with (dragObject.item as TpdBottle) do
          begin
            FillWithWater();
            OnDragSuccess(False);
            Exit();
          end;
        //--

        //--�������
        if (dragObject.item is TpdFishRod) and (player.inWater) then
          with (dragObject.item as TpdFishRod) do
          begin
            OnUse();
//            player.speech.Say('������ �����, ������� � ���������!', 3);
            OnDragSuccess(False);
            Exit();
          end;
        //--

        //--��������� �� ������
        if Assigned(selectedWorldObject) and (selectedWorldObject is TpdCampFire) then
        begin
          if CheckTwigAndGrass() then Exit();
          if CheckBottle() then Exit();
          if CheckMushroomShashlik() then Exit();
          if CheckFishShashlik() then Exit();
        end;
        //--

        //--������ ���� �������
        //TODO - ������� ��������� ����� � WorldObject �� ����
        dropObj := AddNewWorldObject(TpdWorldObjectClass(dragObject.item.ClassType));
        with dropObj do
        begin
          dropPos := dfVec2f(X, Y) - dfVec2f(mainScene.RootNode.Position);
          if dropPos.Dist(player.sprite.Position2D) > PLAYER_DROP_RADIUS then
            dropPos := player.sprite.Position2D + (dropPos - player.sprite.Position2D).Normal * PLAYER_DROP_RADIUS;
          sprite.Position2D := dropPos;
          RecalcBB();
          //��������� �������� ��� �����, ��� ��� ��� ����� ������������ � ������ ��������
          if ClassType = TpdBottle then
            with (dropObj as TpdBottle) do
            begin
              WaterLevel := (dragObject.item as TpdBottle).WaterLevel;
              WaterStatus := (dragObject.item as TpdBottle).WaterStatus;
            end;
        end;
        OnDragSuccess(True);
        Exit();
        //--
      end;
  end;
end;

procedure DeinitializeInventory();
begin
  inventory.Free();
  inventory := nil;
end;

end.
