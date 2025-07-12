class_name PlayerCharacter
extends CharacterBody3D

@onready var camera_pivot := $CameraPivot as Marker3D;
@onready var spring_arm := $CameraPivot/SpringArm as SpringArm3D;
@onready var player_cam := $CameraPivot/SpringArm/PlayerCam as Camera3D;
@onready var interact_cast := $RayCastInteract as RayCast3D;

const move_speed: float = 150.0;
const jump_strength: float = 320.0;

var model_3d: Model3D;

var is_jumping: bool = false;
var is_running: bool = false;


func _ready() -> void:
	load_hero_model(0);
	set_process_input(true);
	return


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Btn_Y") and event.is_pressed():
		check_interaction();
	
	if event.is_action_pressed("Btn_X"):
		GameData.main_scene.instantiate_ingame_menu();
	return


func _physics_process(delta: float) -> void:
	velocity.y += get_gravity().y * delta;
	
	if is_processing_input() == false:
		return
	
	if Input.is_action_just_pressed("ZR"):
		is_running = !is_running;
	
	if Input.is_action_just_pressed("Btn_B") and is_on_floor():
		velocity.y += jump_strength * delta;
		is_jumping = true;
	
	var camera_input := Input.get_vector("R_Stick_Left", "R_Stick_Right", "R_Stick_Up", "R_Stick_Down");
	camera_pivot.rotate_y(-camera_input.x * delta * 2.0);
	spring_arm.rotate_x(-camera_input.y * delta);
	spring_arm.rotation.x = clampf(spring_arm.rotation.x, -1.0472, 0.523599);
	
	var move_input := Input.get_vector("L_Stick_Left", "L_Stick_Right", "L_Stick_Up", "L_Stick_Down");
	var multiplier: float = (2.5 if is_running else 1.0) * (0.33 if is_jumping else 1.0);
	var movement_dir := camera_pivot.transform.basis * Vector3(move_input.x, 0, move_input.y);
	velocity.x = movement_dir.x * move_speed * delta * multiplier;
	velocity.z = movement_dir.z * move_speed * delta * multiplier;
	
	if movement_dir.length_squared() > 0.0:
		look_at(global_position + movement_dir);
	move_and_slide();
	
	if is_zero_approx(velocity.x) and is_zero_approx(velocity.z):
		model_3d.play_animation("Idle", true);
	else:
		var input_speed: float = snappedf(move_input.length(), 0.01);
		if is_running:
			model_3d.play_animation("Run", true, 2.0 * input_speed);
		else:
			model_3d.play_animation("Walk", true, 1.7 * input_speed);
	
	if is_on_floor():
		is_jumping = false;
	
	camera_pivot.global_position = global_position + Vector3.UP;
	return


func check_interaction() -> void:
	if is_jumping:
		return
	
	if interact_cast.is_colliding():
		var collider := interact_cast.get_collider();
		if collider is InteractionComponent:
			(collider as InteractionComponent).emit_interaction();
	return


func load_hero_model(model_id: int) -> void:
	var packed_model: PackedScene = ResourceManager.get_hero_model(model_id);
	model_3d = packed_model.instantiate() as Model3D;
	add_child(model_3d);
	return
