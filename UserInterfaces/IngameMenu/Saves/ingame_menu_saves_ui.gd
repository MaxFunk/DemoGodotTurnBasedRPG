extends Control

const SaveFileDisplay = preload("uid://cbva8qa5ctx6w")
const color_btn_active := Color(1.0, 1.0, 1.0, 1.0);
const color_btn_inactive := Color(0.5, 0.5, 0.5, 1.0);

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
@onready var popup_overwrite := $PopupOverwrite as Control;
@onready var popup_yes := $PopupOverwrite/LabelYes as Label;
@onready var popup_no := $PopupOverwrite/LabelNo as Label;

var index: int = 0;
var popup_btn_state: int = 0;


func prepare_view() -> void:
	index = GameData.cur_savefile_slot;
	update_save_file_displays();
	save_file_displays[index].toggle_hovered();
	return


func input_event(event: InputEvent) -> bool:
	if event.is_action_pressed("Btn_B"):
		if popup_overwrite.visible:
			change_popup(false);
			return false;
		return true
	
	if event.is_action_pressed("Btn_Y"):
		if popup_overwrite.visible:
			change_popup(false);
			if popup_btn_state > 0:
				return false
		elif index != GameData.cur_savefile_slot:
			change_popup(true);
			return false
		
		SaveFileManager.save_to_file(index);
		update_save_file_displays();
		save_file_displays[index].toggle_hovered();
	return false


func _process(_delta: float) -> void:
	var just_pressed: bool = false;
	if Input.is_action_just_pressed("D_Pad_Down") or Input.is_action_just_pressed("L_Stick_Down") \
		or Input.is_action_just_pressed("D_Pad_Left") or Input.is_action_just_pressed("L_Stick_Left"):
		move_index(1);
		cd_dpad.start(0.5);
		just_pressed = true;
	elif Input.is_action_just_pressed("D_Pad_Up") or Input.is_action_just_pressed("L_Stick_Up") \
		or Input.is_action_just_pressed("D_Pad_Right") or Input.is_action_just_pressed("L_Stick_Right"):
		move_index(-1);
		cd_dpad.start(0.5);
		just_pressed = true;
	
	if cd_dpad.is_stopped() and not just_pressed:
		if Input.is_action_pressed("D_Pad_Down") or Input.is_action_pressed("L_Stick_Down") \
		or Input.is_action_pressed("D_Pad_Left") or Input.is_action_pressed("L_Stick_Left"):
			move_index(1);
			cd_dpad.start(0.1);
		elif Input.is_action_pressed("D_Pad_Up") or Input.is_action_pressed("L_Stick_Up") \
		or Input.is_action_pressed("D_Pad_Right") or Input.is_action_pressed("L_Stick_Right"):
			move_index(-1);
			cd_dpad.start(0.1);
	return


func move_index(move: int) -> void:
	if popup_overwrite.visible:
		popup_btn_state = 1 if popup_btn_state == 0 else 0;
		update_popup_btns();
		return
	
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


func change_popup(make_visible: bool) -> void:
	popup_overwrite.visible = make_visible;
	if make_visible:
		popup_btn_state = 0;
		update_popup_btns();
	return


func update_popup_btns() -> void:
	popup_yes.add_theme_color_override("font_color", color_btn_active if popup_btn_state == 0 else color_btn_inactive);
	popup_no.add_theme_color_override("font_color", color_btn_active if popup_btn_state == 1 else color_btn_inactive);
	return
