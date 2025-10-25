extends Control

@onready var lbl_item_name := $LabelItemName as Label;
@onready var lbl_amount := $LabelAmount as Label;
@onready var cd_dir := $CooldownDirectional as Timer;

var max_amount: int = 0;
var cur_amount: int = 0;


func input_event(event: InputEvent) -> int:
	if event.is_action_pressed("Btn_B"):
		return -1
	
	if event.is_action_pressed("Btn_Y"):
		return cur_amount
	
	return 0


func _process(_delta: float) -> void:
	var just_pressed: bool = false;
	if Input.is_action_just_pressed("D_Pad_Down") or Input.is_action_just_pressed("L_Stick_Down"):
		change_amount(-1);
		cd_dir.start(0.5);
		just_pressed = true;
	elif Input.is_action_just_pressed("D_Pad_Up") or Input.is_action_just_pressed("L_Stick_Up"):
		change_amount(1);
		cd_dir.start(0.5);
		just_pressed = true;
	elif Input.is_action_just_pressed("D_Pad_Left") or Input.is_action_just_pressed("L_Stick_Left"):
		change_amount(-10);
		cd_dir.start(0.5);
		just_pressed = true;
	elif Input.is_action_just_pressed("D_Pad_Right") or Input.is_action_just_pressed("L_Stick_Right"):
		change_amount(10);
		cd_dir.start(0.5);
		just_pressed = true;
	
	if cd_dir.is_stopped() and not just_pressed:
		if Input.is_action_pressed("D_Pad_Down") or Input.is_action_pressed("L_Stick_Down"):
			change_amount(-1);
			cd_dir.start(0.1);
		elif Input.is_action_pressed("D_Pad_Up") or Input.is_action_pressed("L_Stick_Up"):
			change_amount(1);
			cd_dir.start(0.1);
		elif Input.is_action_pressed("D_Pad_Left") or Input.is_action_pressed("L_Stick_Left"):
			change_amount(-10);
			cd_dir.start(0.1);
		elif Input.is_action_pressed("D_Pad_Right") or Input.is_action_pressed("L_Stick_Right"):
			change_amount(10);
			cd_dir.start(0.1);
	return


func prepare_view(item_name: String, max_val: int) -> void:
	max_amount = max_val;
	cur_amount = 0;
	lbl_amount.text = str(cur_amount);
	lbl_item_name.text = item_name;
	return


func change_amount(val: int) -> void:
	if cur_amount == 0 and val < 0:
		cur_amount = max_amount;
	if cur_amount == max_amount and val > 0:
		cur_amount = 0;
	else:
		cur_amount = clampi(cur_amount + val, 0, max_amount);
	lbl_amount.text = str(cur_amount);
	return
