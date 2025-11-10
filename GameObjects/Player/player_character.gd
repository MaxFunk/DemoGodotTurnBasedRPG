class_name PlayerCharacter
extends CharacterBody3D

enum MOVEMODE {WALKING = 0, SWIMMING = 1, BATTLEARMOR = 2, CAM_ONLY = 3, NONE = 9}

@onready var camera_pivot := $CameraPivot as Marker3D;
@onready var spring_arm := $CameraPivot/SpringArm as SpringArm3D;
@onready var player_cam := $CameraPivot/SpringArm/PlayerCam as Camera3D;
@onready var interact_cast := $RayCastInteract as RayCast3D;
@onready var water_checker := $WaterChecker as Area3D;
@onready var timer_coyote := $TimerCoyote as Timer;
@onready var timer_stillstanding := $TimerStillStanding as Timer;
@onready var timer_attackcheckdelay := $TimerAttackCheckDelay as Timer;
@onready var audio_listener := $AudioListener3D as AudioListener3D;
@onready var hitshape_attack := $HitshapeAttack as Area3D;

const move_speed: float = 150.0;
const jump_strength: float = 320.0;
const coyote_time_duration: float = 0.25;

var model_3d: Model3D;
var cur_model_id: int = -1;

var move_mode := MOVEMODE.WALKING;
var is_standing_still: bool = true;
var is_jumping: bool = false;
var is_running: bool = false;
var is_falling: bool = false;
var is_attacking: bool = false;
var is_coyote_time: bool = false;

var current_water: Water3D = null;
var jump_direction := Vector3(0, 0, 0);


func _ready() -> void:
	load_hero_model();
	timer_coyote.wait_time = coyote_time_duration;
	
	GameData.main_scene.player_char = self;
	set_process_input(true);
	audio_listener.make_current();
	return


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Btn_X"):
		GameData.main_scene.instantiate_ingame_menu();
	return


func _process(_delta: float) -> void:
	if is_jumping or is_falling:
		return
	
	if Input.is_action_just_pressed("Btn_Y") and !is_attacking:
		model_3d.play_animation("BattleAttack", true);
		is_attacking = true;
		timer_attackcheckdelay.start();
		return
	
	if is_attacking and timer_attackcheckdelay.is_stopped():
		check_attack();
		return
	
	check_interaction(Input.is_action_just_pressed("Btn_A"));
	return


func _physics_process(delta: float) -> void:
	#if current_water:
	#	if move_mode != MOVEMODE.SWIMMING:
	#		if water_checker.global_position.y <= current_water.surface_height:
	#			move_mode = MOVEMODE.SWIMMING;
	#			motion_mode = CharacterBody3D.MOTION_MODE_FLOATING;
	#	else:
	#		if water_checker.global_position.y > current_water.surface_height:
	#			move_mode = MOVEMODE.WALKING;
	#			motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED;
	
	velocity.y += get_gravity().y * delta;
	
	if is_processing_input():
		# TODO: Camera function
		if move_mode != MOVEMODE.NONE:
			var camera_input := Input.get_vector("R_Stick_Left", "R_Stick_Right", "R_Stick_Up", "R_Stick_Down");
			camera_pivot.rotate_y(-camera_input.x * delta * 2.0);
			spring_arm.rotate_x(-camera_input.y * delta);
			spring_arm.rotation.x = clampf(spring_arm.rotation.x, -1.0472, 0.523599);
		
		if !is_attacking:
			match move_mode:
				MOVEMODE.WALKING: process_walking(delta);
				MOVEMODE.SWIMMING: process_swimming(delta);
				MOVEMODE.BATTLEARMOR: process_battlearmor(delta);
				_: velocity.y = 0; model_3d.play_animation("Idle", true);
	
	camera_pivot.global_position = global_position + Vector3.UP;
	check_walking_into_enemy();
	
	# Minimap update
	if GameData.main_scene.world_scene.exploration_ui:
		GameData.main_scene.world_scene.exploration_ui.minimap_update(self);
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
	
	if is_zero_approx(velocity.length_squared()):
		if is_standing_still == false and timer_stillstanding.is_stopped():
			timer_stillstanding.start();
	else:
		if is_standing_still:
			if GameData.main_scene.world_scene.exploration_ui:
				GameData.main_scene.world_scene.exploration_ui.detail_fade_out();
			is_standing_still = false;
		timer_stillstanding.stop();
	
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


func process_battlearmor(delta: float) -> void:
	var horizontal_input := Input.get_vector("L_Stick_Left", "L_Stick_Right", "L_Stick_Up", "L_Stick_Down");
	var vertical_input := Input.get_axis("ZL", "ZR");
	var boost_mult: float = 6.0 if Input.is_action_pressed("Btn_B") else 3.0;
	
	var movement_dir := camera_pivot.transform.basis * Vector3(horizontal_input.x, 0, horizontal_input.y);
	velocity.x = movement_dir.x * move_speed * delta * boost_mult;
	velocity.z = movement_dir.z * move_speed * delta * boost_mult;
	velocity.y = vertical_input * move_speed * delta * 2.0;
	if movement_dir.length_squared() > 0.0:
		look_at(global_position + movement_dir);
	move_and_slide();
	return


func check_interaction(interact: bool) -> void:
	var explore_ui := GameData.main_scene.world_scene.exploration_ui;
	var show_interaction: bool = false;
	var interaction_text: String = ""
	
	if interact_cast.is_colliding() and not is_jumping:
		var collider := interact_cast.get_collider();
		if collider is InteractionComponent:
			var interact_comp := (collider as InteractionComponent);
			if interact_comp.is_interactable():
				if interact:
					interact_comp.emit_interaction();
				else:
					show_interaction = true;
					interaction_text = interact_comp.get_interaction_text();
	
	if explore_ui:
		explore_ui.update_interaction_text(show_interaction, interaction_text);
	return


func check_attack() -> void:
	if is_jumping or !hitshape_attack.has_overlapping_bodies():
		return
	
	for body in hitshape_attack.get_overlapping_bodies():
		if body is EnemyCharacter:
			var enemy_group := (body as EnemyCharacter).enemy_group;
			if enemy_group.enemy_ids.size() > 0:
				GameData.main_scene.instantiate_battle_scene(global_transform, enemy_group, 1);
	return


func check_walking_into_enemy() -> void:
	var last_collision := get_last_slide_collision();
	if last_collision == null:
		return
	for i in last_collision.get_collision_count():
		if last_collision.get_collider(i) is EnemyCharacter:
			var enemy_group := (last_collision.get_collider(i) as EnemyCharacter).enemy_group;
			if enemy_group.enemy_ids.size() > 0:
				GameData.main_scene.instantiate_battle_scene(global_transform, enemy_group, 0);
				break;
	return


func toggle_battlearmor() -> void:
	if move_mode == MOVEMODE.WALKING and not is_jumping:
		#motion_mode = CharacterBody3D.MOTION_MODE_FLOATING;
		move_mode = MOVEMODE.BATTLEARMOR;
		floor_stop_on_slope = false;
		model_3d.play_animation("Fall", true);
	elif move_mode == MOVEMODE.BATTLEARMOR:
		#motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED;
		move_mode = MOVEMODE.WALKING;
		floor_stop_on_slope = true;
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


func on_model3d_animation_finished(anim_name: String) -> void:
	if anim_name == "Jump":
		is_jumping = false;
		is_falling = true;
		model_3d.play_animation("Fall", true);
	
	if anim_name == "BattleAttack":
		is_attacking = false;
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
	if is_jumping == false:
		is_falling = true;
		model_3d.play_animation("Fall", true);
	return


func _on_timer_still_standing_timeout() -> void:
	if GameData.main_scene.world_scene.exploration_ui:
		GameData.main_scene.world_scene.exploration_ui.detail_fade_in();
	is_standing_still = true;
	timer_stillstanding.stop();
	return
