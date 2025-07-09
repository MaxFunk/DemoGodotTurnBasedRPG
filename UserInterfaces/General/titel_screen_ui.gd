extends Control

@onready var screen_main := $ScreenMain as Control;
@onready var lblbtn_load := $ScreenMain/LabelButtonLoad as LabelButton;
@onready var lblbtn_settings := $ScreenMain/LabelButtonSettings as LabelButton;
@onready var lblbtn_credits := $ScreenMain/LabelButtonCredits as LabelButton;
@onready var lblbtn_quit := $ScreenMain/LabelButtonQuit as LabelButton;
@onready var main_btns: Array[LabelButton] = [lblbtn_load, lblbtn_settings, lblbtn_credits, lblbtn_quit];

@onready var screen_load := $ScreenLoad as Control;

enum SCREENSTATE {MAIN, LOAD, SETTINGS, CREDITS}

var screen_state := SCREENSTATE.MAIN;
var main_index: int = 0;


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
	return


func direction_up_event() -> void:
	match screen_state:
		SCREENSTATE.MAIN:
			main_btns[main_index].toggle_hovered();
			main_index = maxi(main_index - 1, 0);
			main_btns[main_index].toggle_hovered();
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
			SaveFileManager.load_from_file(0);
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
		SCREENSTATE.SETTINGS:
			screen_main.visible = false;
			screen_load.visible = false;
		SCREENSTATE.CREDITS:
			screen_main.visible = false;
			screen_load.visible = false;
	screen_state = new_state;
	return
