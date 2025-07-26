extends StaticBody3D

const climb_speed: float = 2.0; # m/s
var active: bool = false;
var player: PlayerCharacter;
var player_face_dir := Vector3(0, 0, -1);

@onready var climb_path := $ClimbPath as Path3D;
@onready var path_follow := $ClimbPath/PathFollow3D as PathFollow3D;

func _ready() -> void:
	player_face_dir = climb_path.global_position.direction_to(global_position).normalized();
	return


func _physics_process(delta: float) -> void:
	if !active:
		return
	
	if Input.is_action_pressed("L_Stick_Up"):
		if path_follow.progress_ratio >= 1.0:
			end_climbing();
		else:
			path_follow.progress += climb_speed * delta;
			player.global_position = path_follow.global_position;
	elif Input.is_action_pressed("L_Stick_Down"):
		if path_follow.progress_ratio <= 0.0:
			end_climbing();
		else:
			path_follow.progress -= climb_speed * delta;
			player.global_position = path_follow.global_position;
	
	if Input.is_action_pressed("Btn_B"):
		end_climbing();
	return


func end_climbing() -> void:
	player.move_mode = player.MOVEMODE.WALKING;
	player = null;
	active = false;
	return


func _on_interaction_component_bottom_interaction() -> void:
	active = true;
	player = GameData.main_scene.player_char;
	player.move_mode = player.MOVEMODE.CAM_ONLY;
	
	path_follow.progress_ratio = 0.0;
	player.global_position = path_follow.global_position;
	player.look_at(player.global_position + player_face_dir);
	return


func _on_interaction_component_top_interaction() -> void:
	active = true;
	player = GameData.main_scene.player_char;
	player.move_mode = player.MOVEMODE.CAM_ONLY;
	
	path_follow.progress_ratio = 1.0;
	player.global_position = path_follow.global_position;
	player.look_at(player.global_position + player_face_dir);
	return
