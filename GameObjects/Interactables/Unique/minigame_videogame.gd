extends Node3D

const Game2D = preload("uid://dahhqwglxqpo7")

@onready var game_quad := $GameQuad as MeshInstance3D;
@onready var view_cam := $ViewCamera as Camera3D;
@onready var game_2d := $SubViewport/Game2D as Game2D;

var minigame_active: bool = false;


func _ready() -> void:
	game_2d.process_mode = Node.PROCESS_MODE_DISABLED;
	return


func _process(_delta: float) -> void:
	if Input.is_action_pressed("L") and Input.is_action_pressed("R") and minigame_active:
		stop_minigame();
	return


func start_minigame() -> void:
	GameData.main_scene.player_char.process_mode = Node.PROCESS_MODE_DISABLED;
	GameData.main_scene.world_scene.exploration_ui.visible = false;
	game_2d.process_mode = Node.PROCESS_MODE_INHERIT;
	view_cam.make_current();
	minigame_active = true;
	return


func stop_minigame() -> void:
	game_2d.process_mode = Node.PROCESS_MODE_DISABLED;
	GameData.main_scene.player_char.process_mode = Node.PROCESS_MODE_INHERIT;
	GameData.main_scene.world_scene.exploration_ui.visible = true;
	view_cam.current = false;
	minigame_active = false;
	return


func _on_interaction_component_interaction() -> void:
	start_minigame();
	return
