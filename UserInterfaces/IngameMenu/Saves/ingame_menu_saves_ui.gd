extends Control

const SaveFileDisplay = preload("uid://cbva8qa5ctx6w")

@onready var cd_dpad := $CooldownDpad as Timer;
@onready var save_file_displays: Array[SaveFileDisplay] = [
	$SaveFileDisplay1 as SaveFileDisplay,
	$SaveFileDisplay2 as SaveFileDisplay,
	$SaveFileDisplay3 as SaveFileDisplay,
	$SaveFileDisplay4 as SaveFileDisplay,
	$SaveFileDisplay5 as SaveFileDisplay,
	$SaveFileDisplay6 as SaveFileDisplay,
	$SaveFileDisplay7 as SaveFileDisplay,
	$SaveFileDisplay8 as SaveFileDisplay];

var index: int = 0;


func prepare_view() -> void:
	index = GameData.cur_savefile_slot;
	update_save_file_displays();
	save_file_displays[index].toggle_hovered();
	return


func input_event(event: InputEvent) -> bool:
	if event.is_action_pressed("Btn_B"):
		return true
	
	if event.is_action_pressed("Btn_Y"):
		if index != GameData.cur_savefile_slot:
			print("TODO: POPUP ASK IF OVERWRITE");
			return false
		SaveFileManager.save_to_file(index);
		update_save_file_displays();
		save_file_displays[index].toggle_hovered();
	return false


func _process(_delta: float) -> void:
	var just_pressed: bool = false;
	if Input.is_action_just_pressed("D_Pad_Down") or Input.is_action_just_pressed("L_Stick_Down"):
		move_index(1);
		cd_dpad.start(0.5);
		just_pressed = true;
	elif Input.is_action_just_pressed("D_Pad_Up") or Input.is_action_just_pressed("L_Stick_Up"):
		move_index(-1);
		cd_dpad.start(0.5);
		just_pressed = true;
	
	if cd_dpad.is_stopped() and not just_pressed:
		if Input.is_action_pressed("D_Pad_Down") or Input.is_action_pressed("L_Stick_Down"):
			move_index(1);
			cd_dpad.start(0.1);
		elif Input.is_action_pressed("D_Pad_Up") or Input.is_action_pressed("L_Stick_Up"):
			move_index(-1);
			cd_dpad.start(0.1);
	return


func move_index(move: int) -> void:
	save_file_displays[index].toggle_hovered();
	index = clampi(index + move, 0, save_file_displays.size() - 1);
	save_file_displays[index].toggle_hovered();
	return


func update_save_file_displays() -> void:
	for i in save_file_displays.size():
		var data := SaveFileManager.manager_dict.get(str("slot_", i), "") as String;
		save_file_displays[i].update_data_display(data, i);
		save_file_displays[i].unhover();
	return
