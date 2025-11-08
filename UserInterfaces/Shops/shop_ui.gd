class_name ShopUI extends Control

var cd_dir: Timer = null;


func _ready() -> void:
	cd_dir = Timer.new();
	cd_dir.name = "CooldownDirectional";
	cd_dir.one_shot = true;
	cd_dir.wait_time = 0.2;
	add_child(cd_dir);
	
	custom_ready();
	return


func _process(delta: float) -> void:
	custom_process(delta);
	
	var just_pressed: bool = false;
	if Input.is_action_just_pressed("D_Pad_Down") or Input.is_action_just_pressed("L_Stick_Down"):
		input_down()
		just_pressed = true;
	elif Input.is_action_just_pressed("D_Pad_Up") or Input.is_action_just_pressed("L_Stick_Up"):
		input_up()
		just_pressed = true;
	elif Input.is_action_just_pressed("D_Pad_Left") or Input.is_action_just_pressed("L_Stick_Left"):
		input_left()
		just_pressed = true;
	elif Input.is_action_just_pressed("D_Pad_Right") or Input.is_action_just_pressed("L_Stick_Right"):
		input_right()
		just_pressed = true;
	
	if just_pressed:
		cd_dir.start(0.5);
	
	if cd_dir.is_stopped() and not just_pressed:
		if Input.is_action_pressed("D_Pad_Down") or Input.is_action_pressed("L_Stick_Down"):
			input_down()
			cd_dir.start(0.1);
		elif Input.is_action_pressed("D_Pad_Up") or Input.is_action_pressed("L_Stick_Up"):
			input_up()
			cd_dir.start(0.1);
		elif Input.is_action_pressed("D_Pad_Left") or Input.is_action_pressed("L_Stick_Left"):
			input_left()
			cd_dir.start(0.1);
		elif Input.is_action_pressed("D_Pad_Right") or Input.is_action_pressed("L_Stick_Right"):
			input_right()
			cd_dir.start(0.1);
	return


func custom_ready() -> void:
	return


func custom_process(delta: float) -> void:
	delta = delta;
	return


func input_down() -> void:
	return


func input_up() -> void:
	return


func input_left() -> void:
	return


func input_right() -> void:
	return
