class_name PlayerCharacter
extends CharacterBody3D

enum MOVEMODE {WALKING = 0, SWIMMING = 1, CAM_ONLY = 2, NONE = 9}

@onready var camera_pivot := $CameraPivot as Marker3D;
@onready var spring_arm := $CameraPivot/SpringArm as SpringArm3D;
@onready var player_cam := $CameraPivot/SpringArm/PlayerCam as Camera3D;
@onready var interact_cast := $RayCastInteract as RayCast3D;
@onready var water_checker := $WaterChecker as Area3D;
@onready var timer_coyote := $TimerCoyote as Timer;

const move_speed: float = 150.0;
const jump_strength: float = 320.0;
const coyote_time_duration: float = 0.25;

var model_3d: Model3D;
var cur_model_id: int = -1;

var move_mode := MOVEMODE.WALKING;
var is_jumping: bool = false;
var is_running: bool = false;
var is_falling: bool = false;
var is_coyote_time: bool = false;

var current_water: Water3D = null;
var jump_direction := Vector3(0, 0, 0);


func _ready() -> void:
	load_hero_model();
	timer_coyote.wait_time = coyote_time_duration;
	
	GameData.main_scene.player_char = self;
	set_process_input(true);
	return


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Btn_Y") and event.is_pressed():
		check_interaction();
	
	if event.is_action_pressed("Btn_X"):
		GameData.main_scene.instantiate_ingame_menu();
	return


func _physics_process(delta: float) -> void:
	if current_water:
		if move_mode != MOVEMODE.SWIMMING:
			if water_checker.global_position.y <= current_water.surface_height:
				move_mode = MOVEMODE.SWIMMING;
				motion_mode = CharacterBody3D.MOTION_MODE_FLOATING;
		else:
			if water_checker.global_position.y > current_water.surface_height:
				move_mode = MOVEMODE.WALKING;
				motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED;
	
	velocity.y += get_gravity().y * delta;
	
	if is_processing_input():
		# TODO: Camera function
		if move_mode != MOVEMODE.NONE:
			var camera_input := Input.get_vector("R_Stick_Left", "R_Stick_Right", "R_Stick_Up", "R_Stick_Down");
			camera_pivot.rotate_y(-camera_input.x * delta * 2.0);
			spring_arm.rotate_x(-camera_input.y * delta);
			spring_arm.rotation.x = clampf(spring_arm.rotation.x, -1.0472, 0.523599);
		
		match move_mode:
			MOVEMODE.WALKING: process_walking(delta);
			MOVEMODE.SWIMMING: process_swimming(delta);
			_: velocity.y = 0; model_3d.play_animation("Idle", true);
	
	camera_pivot.global_position = global_position + Vector3.UP;
	return


func process_walking(delta: float) -> void:
	if Input.is_action_just_pressed("ZR"):
		is_running = !is_running;
	
	var move_input := Input.get_vector("L_Stick_Left", "L_Stick_Right", "L_Stick_Up", "L_Stick_Down");
	var run_mult: float = 2.5 if is_running else 1.0;
	var just_jumped: bool = false;
	
	if Input.is_action_just_pressed("Btn_B") and (is_on_floor() or is_coyote_time):
		#jump_direction = Vector3(move_input.x, 0, move_input.y);
		velocity.y += jump_strength * delta;
		is_jumping = true;
		just_jumped = true;
	
	var movement_dir := camera_pivot.transform.basis * Vector3(move_input.x, 0, move_input.y);
	if is_jumping or is_falling:
		movement_dir = movement_dir * 0.67; # + jump_direction * 0.33;
	velocity.x = movement_dir.x * move_speed * delta * run_mult;
	velocity.z = movement_dir.z * move_speed * delta * run_mult;
	
	if movement_dir.length_squared() > 0.0:
		look_at(global_position + movement_dir);
	move_and_slide();
	
	if is_jumping:
		if just_jumped:
			model_3d.play_animation("Jump", true, 1.0);
	elif is_falling == false:
		if is_zero_approx(velocity.x) and is_zero_approx(velocity.z):
			model_3d.play_animation("Idle", true);
		else:
			var input_speed: float = snappedf(move_input.length(), 0.01);
			if is_running:
				model_3d.play_animation("Run", true, 2.0 * input_speed);
			else:
				model_3d.play_animation("Walk", true, 2.0 * input_speed);
	
	var on_floor := is_on_floor();
	if on_floor:
		is_jumping = false;
		is_falling = false;
	
	# Check if started falling in this frame
	if !on_floor and !is_jumping and !is_falling and !is_coyote_time:
		is_coyote_time = true;
		timer_coyote.start();
	return


func process_swimming(delta: float) -> void:
	if Input.is_action_just_pressed("ZR"):
		is_running = !is_running;
	
	var move_input := Input.get_vector("L_Stick_Left", "L_Stick_Right", "L_Stick_Up", "L_Stick_Down");
	var run_mult: float = 2.5 if is_running else 1.0;
	var movement_dir := camera_pivot.transform.basis * Vector3(move_input.x, 0, move_input.y);
	velocity.x = movement_dir.x * move_speed * delta * run_mult;
	velocity.z = movement_dir.z * move_speed * delta * run_mult;
	velocity.y = 0;
	#if water_checker.global_position.y < current_water.surface_height:
	#global_position.y += delta;
	
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
	return


func check_interaction() -> void:
	if is_jumping:
		return
	
	if interact_cast.is_colliding():
		var collider := interact_cast.get_collider();
		if collider is InteractionComponent:
			(collider as InteractionComponent).emit_interaction();
		
		if collider is EnemyCharacter:
			var enemy_group := (collider as EnemyCharacter).enemy_group;
			if enemy_group.enemy_ids.size() > 0:
				GameData.main_scene.instantiate_battle_scene(global_transform, enemy_group);
	return


func load_hero_model() -> void:
	var model_id: int = GameData.active_party[0];
	
	if cur_model_id == model_id:
		return
	
	if model_3d:
		remove_child(model_3d);
		model_3d.queue_free(); # TODO: cache Model?
	
	var packed_model: PackedScene = ResourceManager.get_hero_model(model_id);
	model_3d = packed_model.instantiate() as Model3D;
	add_child(model_3d);
	model_3d.rotate_y(PI);
	model_3d.animation_finished.connect(on_model3d_animation_finished);
	cur_model_id = model_id;
	return


func _on_water_checker_body_entered(body: Node3D) -> void:
	if body is Water3D:
		current_water = body as Water3D;
	return


func _on_water_checker_body_exited(body: Node3D) -> void:
	if body is Water3D:
		current_water = null;
		move_mode = MOVEMODE.WALKING;
		motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED;
	return


func _on_timer_coyote_timeout() -> void:
	is_coyote_time = false;
	is_falling = true;
	model_3d.play_animation("Fall", true);
	return


func on_model3d_animation_finished(anim_name: String) -> void:
	if anim_name == "Jump":
		is_jumping = false;
		is_falling = true;
		model_3d.play_animation("Fall", true);
	return
