extends Control

const CharacterUI := preload("uid://kn3kj0xbch8q");
const PartyUI := preload("uid://by3qxgay8qbd7");
const ItemsUI = preload("uid://dr27i5yit4hhc");
const QuestsUI = preload("uid://bf2l225emcn");
const SavesUI = preload("uid://imlt0rs7uh15");

enum MENUSTATE {MAIN, PARTY, CHARACTERS, ITEMS, MAP, QUESTS, SAVES, SETTINGS, TITELSCREEN}

@onready var main_view_ctrl := $MainView as Control;
@onready var main_view_btns: Array[LabelButton] = [
	$MainView/LabelButton1,
	$MainView/LabelButton2,
	$MainView/LabelButton3,
	$MainView/LabelButton4,
	$MainView/LabelButton5,
	$MainView/LabelButton6,
	$MainView/LabelButton7,
	$MainView/LabelButton8];
@onready var lbl_money := $MainView/LabelMoney as Label;
@onready var lbl_hqpoints := $MainView/LabelHQPoints as Label;

@onready var character_ui := $IngameMenuCharacterUI as CharacterUI;
@onready var party_ui := $IngameMenuPartyUI as PartyUI;
@onready var items_ui := $IngameMenuItemsUI as ItemsUI;
@onready var quests_ui := $IngameMenuQuestsUI as QuestsUI;
@onready var saves_ui := $IngameMenuSavesUI as SavesUI;
@onready var cd_dir := $CooldownDirectional as Timer;

var menu_state := MENUSTATE.MAIN;
var main_view_index: int = 0;
var check_process: bool = true;


func _ready() -> void:
	update_view_state(MENUSTATE.MAIN);
	return


func _input(event: InputEvent) -> void:
	var close_sub_menu: bool = false;
	
	match menu_state:
		MENUSTATE.MAIN:
			input_event_main(event);
		MENUSTATE.PARTY:
			close_sub_menu = party_ui.input_event(event);
		MENUSTATE.CHARACTERS:
			close_sub_menu = character_ui.input_event(event);
		MENUSTATE.ITEMS:
			close_sub_menu = items_ui.input_event(event);
		MENUSTATE.QUESTS:
			close_sub_menu = quests_ui.input_event(event);
		MENUSTATE.SAVES:
			close_sub_menu = saves_ui.input_event(event);
	
	if close_sub_menu:
		update_view_state(MENUSTATE.MAIN);
	return


func _process(_delta: float) -> void:
	if check_process:
		var just_pressed: bool = false;
		if Input.is_action_just_pressed("D_Pad_Down") or Input.is_action_just_pressed("L_Stick_Down"):
			update_main_index(1);
			cd_dir.start(0.5);
			just_pressed = true;
		elif Input.is_action_just_pressed("D_Pad_Up") or Input.is_action_just_pressed("L_Stick_Up"):
			update_main_index(-1);
			cd_dir.start(0.5);
			just_pressed = true;
		
		if cd_dir.is_stopped() and not just_pressed:
			if Input.is_action_pressed("D_Pad_Down") or Input.is_action_pressed("L_Stick_Down"):
				update_main_index(1);
				cd_dir.start(0.1);
			elif Input.is_action_pressed("D_Pad_Up") or Input.is_action_pressed("L_Stick_Up"):
				update_main_index(-1);
				cd_dir.start(0.1);
	return


func input_event_main(event: InputEvent) -> void:
	if event.is_action_pressed("Btn_X"):
		return
	
	if event.is_action_pressed("Btn_Y") or event.is_action_pressed("Btn_A"):
		match main_view_index:
			0: update_view_state(MENUSTATE.PARTY);
			1: update_view_state(MENUSTATE.CHARACTERS);
			2: update_view_state(MENUSTATE.ITEMS);
			4: update_view_state(MENUSTATE.QUESTS);
			5: update_view_state(MENUSTATE.SAVES);
			7: GameData.return_to_titlescreen();
		return
	
	if event.is_action_pressed("Btn_B"):
		GameData.main_scene.close_ingame_menu();
	return


func update_main_index(index_change: int) -> void:
	main_view_btns[main_view_index].clear_hovered();
	main_view_index = main_view_index + index_change;
	if main_view_index < 0:
		main_view_index = 7;
	elif main_view_index > 7:
		main_view_index = 0;
	main_view_btns[main_view_index].set_hovered();
	return


func update_view_state(new_state: MENUSTATE) -> void:
	main_view_ctrl.visible = new_state == MENUSTATE.MAIN;
	party_ui.visible = new_state == MENUSTATE.PARTY;
	character_ui.visible = new_state == MENUSTATE.CHARACTERS;
	items_ui.visible = new_state == MENUSTATE.ITEMS;
	quests_ui.visible = new_state == MENUSTATE.QUESTS;
	saves_ui.visible = new_state == MENUSTATE.SAVES;
	
	check_process = new_state == MENUSTATE.MAIN;
	party_ui.process_mode = PROCESS_MODE_INHERIT if new_state == MENUSTATE.PARTY else PROCESS_MODE_DISABLED;
	character_ui.process_mode = PROCESS_MODE_INHERIT if new_state == MENUSTATE.CHARACTERS else PROCESS_MODE_DISABLED;
	items_ui.process_mode = PROCESS_MODE_INHERIT if new_state == MENUSTATE.ITEMS else PROCESS_MODE_DISABLED;
	quests_ui.process_mode = PROCESS_MODE_INHERIT if new_state == MENUSTATE.QUESTS else PROCESS_MODE_DISABLED;
	saves_ui.process_mode = PROCESS_MODE_INHERIT if new_state == MENUSTATE.SAVES else PROCESS_MODE_DISABLED;
	
	match new_state:
		MENUSTATE.MAIN:
			var left_part := floori(GameData.money / 100.0);
			var right_part := GameData.money - left_part * 100;
			lbl_money.text = str(left_part, ".", right_part, " €");
			lbl_hqpoints.text = str(GameData.hq_points, " P");
			main_view_btns[main_view_index].set_hovered();
		MENUSTATE.PARTY:
			party_ui.prepare_view();
		MENUSTATE.CHARACTERS:
			character_ui.prepare_view();
		MENUSTATE.ITEMS:
			items_ui.prepare_view();
		MENUSTATE.QUESTS:
			quests_ui.prepare_view();
		MENUSTATE.SAVES:
			saves_ui.prepare_view();
	
	menu_state = new_state;
	return
