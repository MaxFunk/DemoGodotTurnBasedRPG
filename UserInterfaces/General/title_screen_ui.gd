extends Control

const SaveFileDisplay := preload("res://UserInterfaces/Custom/save_file_display.gd");

@onready var screen_main := $ScreenMain as Control;
@onready var lblbtn_load := $ScreenMain/LabelButtonLoad as LabelButton;
@onready var lblbtn_settings := $ScreenMain/LabelButtonSettings as LabelButton;
@onready var lblbtn_credits := $ScreenMain/LabelButtonCredits as LabelButton;
@onready var lblbtn_quit := $ScreenMain/LabelButtonQuit as LabelButton;
@onready var main_btns: Array[LabelButton] = [lblbtn_load, lblbtn_settings, lblbtn_credits, lblbtn_quit];

@onready var screen_load := $ScreenLoad as Control;
@onready var save_file_displays: Array[SaveFileDisplay] = [
	$ScreenLoad/SaveFileDisplay1 as SaveFileDisplay,
	$ScreenLoad/SaveFileDisplay2 as SaveFileDisplay,
	$ScreenLoad/SaveFileDisplay3 as SaveFileDisplay,
	$ScreenLoad/SaveFileDisplay4 as SaveFileDisplay,
	$ScreenLoad/SaveFileDisplay5 as SaveFileDisplay,
	$ScreenLoad/SaveFileDisplay6 as SaveFileDisplay,
	$ScreenLoad/SaveFileDisplay7 as SaveFileDisplay,
	$ScreenLoad/SaveFileDisplay8 as SaveFileDisplay,
];

enum SCREENSTATE {MAIN, LOAD, SETTINGS, CREDITS}

var screen_state := SCREENSTATE.MAIN;
var main_index: int = 0;
var load_index: int = 0;


func _ready() -> void:
	main_btns[main_index].toggle_hovered();
	return


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("D_Pad_Down"):
		direction_down_event();
		return
	
	if event.is_action_pressed("D_Pad_Up"):
		direction_up_event();
		return
	
	if event.is_action_pressed("Btn_Y") or event.is_action_pressed("Btn_A"):
		confirm_event();
		return
	
	if event.is_action_pressed("Btn_B"):
		cancel_event();
	return


func direction_down_event() -> void:
	match screen_state:
		SCREENSTATE.MAIN:
			main_btns[main_index].toggle_hovered();
			main_index = mini(main_index + 1, 3);
			main_btns[main_index].toggle_hovered();
		SCREENSTATE.LOAD:
			save_file_displays[load_index].toggle_hovered();
			load_index = mini(load_index + 1, 7);
			save_file_displays[load_index].toggle_hovered();
	return


func direction_up_event() -> void:
	match screen_state:
		SCREENSTATE.MAIN:
			main_btns[main_index].toggle_hovered();
			main_index = maxi(main_index - 1, 0);
			main_btns[main_index].toggle_hovered();
		SCREENSTATE.LOAD:
			save_file_displays[load_index].toggle_hovered();
			load_index = maxi(load_index - 1, 0);
			save_file_displays[load_index].toggle_hovered();
	return


func confirm_event() -> void:
	match screen_state:
		SCREENSTATE.MAIN:
			match main_index:
				0: update_screen(SCREENSTATE.LOAD);
				1: update_screen(SCREENSTATE.SETTINGS);
				2: update_screen(SCREENSTATE.CREDITS);
				3: get_tree().quit();
		SCREENSTATE.LOAD:
			SaveFileManager.load_from_file(load_index);
		_:
			print("TODO")
	return


func cancel_event() -> void:
	match screen_state:
		SCREENSTATE.LOAD, SCREENSTATE.SETTINGS, SCREENSTATE.CREDITS:
			update_screen(SCREENSTATE.MAIN);
	return


func update_screen(new_state: SCREENSTATE) -> void:
	match new_state:
		SCREENSTATE.MAIN:
			screen_main.visible = true;
			screen_load.visible = false;
		SCREENSTATE.LOAD:
			screen_main.visible = false;
			screen_load.visible = true;
			update_save_file_displays();
			load_index = 0;
			save_file_displays[load_index].toggle_hovered();
		SCREENSTATE.SETTINGS:
			screen_main.visible = false;
			screen_load.visible = false;
		SCREENSTATE.CREDITS:
			screen_main.visible = false;
			screen_load.visible = false;
	screen_state = new_state;
	return


func update_save_file_displays() -> void:
	for i in range(8):
		var data := SaveFileManager.manager_dict.get(str("slot_", i), "") as String;
		save_file_displays[i].update_data_display(data, i);
		save_file_displays[i].unhover();
	return
