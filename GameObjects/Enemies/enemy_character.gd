class_name EnemyCharacter
extends CharacterBody3D

enum CHARSTATE {IDLE, WALKING, FOLLOWING, ATTACKING, RETURNING, DEFEATED}
enum CHARTASK {IDLE, WANDERING, GUARDING}

@onready var nav_agent := $NavigationAgent3D as NavigationAgent3D;
@onready var view_area := $ViewArea as Area3D;
@onready var view_colshape := $ViewArea/ViewAreaColShape as CollisionShape3D;
@onready var raycast_attack := $RayCastAttack as RayCast3D;
@onready var timer_path_fetch := $TimerPathFetch as Timer;

var model_3d: Model3D;
var enemy_group: EnemyGroup;
var target_player: PlayerCharacter;

var char_state := CHARSTATE.IDLE;
var char_task := CHARTASK.GUARDING;

var attack_anim_name: StringName = "BattlePhysicalArt";
var walking_speed: float = 100.0;
var view_range: float = 5;
var attack_range: float = 1.5;
var attack_threshold: float = 1.0;
var max_follow_range: float = 8;
var max_walk_range: float = 12;
var sqr_max_walk_range: float = 144;

var spawn_position: Vector3;
var spawn_rotation: Vector3;
var is_waiting := false;


func _ready() -> void:
	var packed_model: PackedScene = preload("res://Resources/Models/Enemies/sentinel_drone.glb");
	model_3d = packed_model.instantiate() as Model3D;
	add_child(model_3d);
	model_3d.animation_finished.connect(on_model_3d_animation_finished);
	model_3d.play_animation("Idle");
	
	var box_shape := BoxShape3D.new();
	box_shape.size.z = view_range;
	view_colshape.shape = box_shape;
	view_colshape.position.z -= view_range / 2.0;
	
	raycast_attack.target_position.z = -attack_range;
	
	sqr_max_walk_range = max_walk_range * max_walk_range;
	return


func _process(_delta: float) -> void:
	if char_state == CHARSTATE.FOLLOWING:
		var player_dist := global_position.distance_to(target_player.global_position);
		if player_dist > max_follow_range:
			if char_task == CHARTASK.GUARDING:
				new_returning_target();
			else:
				new_walking_target();
		elif player_dist < attack_threshold:
			start_attack();
	return


func _physics_process(delta: float) -> void:
	var walk_factor: float = 0.0;
	
	if is_waiting:
		return
	
	match char_state:
		CHARSTATE.WALKING:
			walk_factor = 0.5;
		CHARSTATE.ATTACKING:
			walk_factor = 0.75;
		CHARSTATE.FOLLOWING, CHARSTATE.RETURNING:
			walk_factor = 1.0;
		_:
			return
	
	var next_path_position := nav_agent.get_next_path_position();
	var next_dir := global_position.direction_to(next_path_position);
	if is_waiting: # necessary, otherwise still called despite is_waiting == true
		return
	if next_dir.length_squared() > 0.1:
		look_at_position(global_position + next_dir);
	velocity = next_dir * walking_speed * delta * walk_factor;
	move_and_slide();
	return


func set_spawn_position(spawn_marker: Marker3D) -> void:
	if spawn_marker:
		global_transform = spawn_marker.global_transform;
	#else: set beforehhand?
	
	spawn_position = global_position;
	spawn_rotation = global_rotation;
	
	if char_task == CHARTASK.WANDERING:
		new_walking_target();
	return


func new_returning_target() -> void:
	nav_agent.target_position = spawn_position;
	is_waiting = false;
	target_player = null;
	char_state = CHARSTATE.RETURNING;
	model_3d.play_animation("Walk");
	timer_path_fetch.start(2.0);
	return


func new_walking_target() -> void:
	var rand_dir := Vector3(randf() - 0.5, 0, randf() - 0.5).normalized();
	var target_position = spawn_position + rand_dir * max_walk_range * randf();
	nav_agent.target_position = target_position;
	
	is_waiting = false;
	char_state = CHARSTATE.WALKING;
	model_3d.play_animation("Walk");
	
	timer_path_fetch.start(10.0);
	return


func new_following_target() -> void:
	if target_player == null:
		new_walking_target(); # TODO correct failsafe
		return
	
	nav_agent.target_position = target_player.global_position;
	is_waiting = false;
	char_state = CHARSTATE.FOLLOWING;
	model_3d.play_animation("Run");
	timer_path_fetch.start(0.5);
	return


func start_attack() -> void:
	char_state = CHARSTATE.ATTACKING;
	timer_path_fetch.start(1.0); # attack after x seconds
	model_3d.play_animation(attack_anim_name, true);
	return


func check_for_player_hit() -> void:
	if raycast_attack.is_colliding():
		var collider := raycast_attack.get_collider();
		if collider is PlayerCharacter:
			is_waiting = true;
			if enemy_group.enemy_ids.size() > 0:
				var player := collider as PlayerCharacter;
				GameData.main_scene.instantiate_battle_scene(player.global_transform, enemy_group);
	return


func look_at_position(pos: Vector3) -> void:
	var corrected_pos := Vector3(pos.x, global_position.y, pos.z);
	look_at(corrected_pos);
	return


func _on_view_area_body_entered(body: Node3D) -> void:
	if body is PlayerCharacter:
		if char_task == CHARTASK.IDLE or char_state == CHARSTATE.RETURNING:
			# or char_state == CHARSTATE.DEFEATED
			return
		target_player = body as PlayerCharacter;
		new_following_target();
	return


func _on_timer_path_fetch_timeout() -> void:
	match char_state:
		CHARSTATE.WALKING:
			new_walking_target();
		CHARSTATE.FOLLOWING:
			new_following_target();
		CHARSTATE.RETURNING:
			new_returning_target();
		CHARSTATE.ATTACKING:
			timer_path_fetch.stop();
			check_for_player_hit();
		_:
			timer_path_fetch.stop();
			model_3d.play_animation("Idle");
	return


func _on_navigation_agent_3d_navigation_finished() -> void:
	match char_state:
		CHARSTATE.WALKING:
			is_waiting = true;
			model_3d.play_animation("Idle");
		CHARSTATE.RETURNING:
			is_waiting = true;
			model_3d.play_animation("Idle");
			char_state = CHARSTATE.IDLE;
			global_rotation = spawn_rotation;
			global_position = spawn_position;
		CHARSTATE.FOLLOWING, CHARSTATE.ATTACKING:
			is_waiting = true;
	return


func on_model_3d_animation_finished(anim_name: String) -> void:
	if anim_name == attack_anim_name and char_state == CHARSTATE.ATTACKING:
		new_following_target();
	return
