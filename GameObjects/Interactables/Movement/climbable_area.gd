extends Node3D

@export var interact_comp: InteractionComponent;
@export var path_vertical: Path3D;
@export var path_horizontal: Path3D;

@onready var path_follow_vert := $PathFollowVertical as PathFollow3D;
@onready var path_follow_hori := $PathFollowHorizontal as PathFollow3D;

const climb_speed: float = 2.0; # m/s
var active: bool = false;
var player: PlayerCharacter;
var player_face_dir := Vector3(-1, 0, 0);


func _ready() -> void:
	if path_vertical:
		path_follow_vert.reparent(path_vertical);
	
	if path_horizontal:
		path_follow_hori.reparent(path_horizontal);
	
	if interact_comp:
		interact_comp.interaction.connect(on_interaction_component_interaction);
	return


func _physics_process(delta: float) -> void:
	if !active:
		return
	
	if Input.is_action_pressed("L_Stick_Up"):
		path_follow_vert.progress += climb_speed * delta;
		player.global_position.y = path_follow_vert.global_position.y;
	elif Input.is_action_pressed("L_Stick_Down"):
		path_follow_vert.progress -= climb_speed * delta;
		player.global_position.y = path_follow_vert.global_position.y;
	
	if Input.is_action_pressed("L_Stick_Right"):
		path_follow_hori.progress += climb_speed * delta;
		player.global_position.x = path_follow_hori.global_position.x;
		player.global_position.z = path_follow_hori.global_position.z;
	elif Input.is_action_pressed("L_Stick_Left"):
		path_follow_hori.progress -= climb_speed * delta;
		player.global_position.x = path_follow_hori.global_position.x;
		player.global_position.z = path_follow_hori.global_position.z;
	
	if Input.is_action_pressed("Btn_B"):
		end_climbing();
	return


func end_climbing() -> void:
	player.move_mode = player.MOVEMODE.WALKING;
	player = null;
	active = false;
	return


func on_interaction_component_interaction() -> void:
	active = true;
	player = GameData.main_scene.player_char;
	player.move_mode = player.MOVEMODE.CAM_ONLY;
	
	if player.global_position.y > global_position.y:
		path_follow_vert.progress = player.global_position.y - global_position.y;
	else:
		path_follow_vert.progress_ratio = 0.0;
		player.global_position.y = path_follow_vert.global_position.y;
	
	#if player.global_position.y > global_position.y:
	#	path_follow_vert.progress = player.global_position.y - global_position.y;
	#else:
	#	path_follow_vert.progress_ratio = 0.0;
	#player.global_position.y = clampf(player.global_position.y, glos);
	
	#var max_p := path_horizontal.curve.point_count;
	#print(path_horizontal.curve.get_point_position(max_p - 1));
	
	player.look_at(player.global_position + player_face_dir);
	return
