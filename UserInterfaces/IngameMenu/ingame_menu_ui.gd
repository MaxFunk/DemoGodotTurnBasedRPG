extends Control

const CharacterUI := preload("res://UserInterfaces/IngameMenu/ingame_menu_character_ui.gd");
const PartyUI := preload("res://UserInterfaces/IngameMenu/ingame_menu_party_ui.gd");
const ItemsUI := preload("res://UserInterfaces/IngameMenu/Items/ingame_menu_items_ui.gd");

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
@onready var character_ui := $IngameMenuCharacterUI as CharacterUI;
@onready var party_ui := $IngameMenuPartyUI as PartyUI;
@onready var items_ui := $IngameMenuItemsUI as ItemsUI;

var menu_state := MENUSTATE.MAIN;
var main_view_index: int = 0;


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
	
	if close_sub_menu:
		update_view_state(MENUSTATE.MAIN);
	return


func input_event_main(event: InputEvent) -> void:
	if event.is_action_pressed("D_Pad_Down"):
		main_view_btns[main_view_index].clear_hovered();
		main_view_index = mini(main_view_index + 1, 7);
		main_view_btns[main_view_index].set_hovered();
		return
	
	if event.is_action_pressed("D_Pad_Up"):
		main_view_btns[main_view_index].clear_hovered();
		main_view_index = maxi(main_view_index - 1, 0);
		main_view_btns[main_view_index].set_hovered();
		return
	
	if event.is_action_pressed("Btn_X"):
		return
	
	if event.is_action_pressed("Btn_Y") or event.is_action_pressed("Btn_A"):
		match main_view_index:
			0: update_view_state(MENUSTATE.PARTY);
			1: update_view_state(MENUSTATE.CHARACTERS);
			2: update_view_state(MENUSTATE.ITEMS);
			5: print("Saving File"); SaveFileManager.save_to_file(GameData.cur_savefile_slot);
			7: GameData.return_to_titlescreen();
		return
	
	if event.is_action_pressed("Btn_B"):
		GameData.main_scene.close_ingame_menu();
	return


func update_view_state(new_state: MENUSTATE) -> void:
	main_view_ctrl.visible = true if new_state == MENUSTATE.MAIN else false;
	party_ui.visible = true if new_state == MENUSTATE.PARTY else false;
	character_ui.visible = true if new_state == MENUSTATE.CHARACTERS else false;
	items_ui.visible = true if new_state == MENUSTATE.ITEMS else false;
	
	match new_state:
		MENUSTATE.MAIN:
			main_view_btns[main_view_index].set_hovered();
		MENUSTATE.PARTY:
			party_ui.prepare_view();
		MENUSTATE.CHARACTERS:
			character_ui.prepare_view();
		MENUSTATE.ITEMS:
			items_ui.prepare_view();
	
	menu_state = new_state;
	return
