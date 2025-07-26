class_name MainScene
extends Node3D

const ingame_menu_scene := preload("res://UserInterfaces/IngameMenu/ingame_menu_ui.tscn");
const battle_scene_packed := preload("res://System/Scenes/battle_scene.tscn");

@onready var loading_screen := $LoadingScreenRect as ColorRect;

var world_scene: WorldScene;
var battle_scene: BattleScene;
var ingame_menu_node: Control;
var player_char: PlayerCharacter;

var is_world_loading: bool = false;
var enable_world_processing: bool = false;
var loading_path: StringName;


func _ready() -> void:
	GameData.main_scene = self;
	load_world(1);
	return


func _process(_delta: float) -> void:
	if is_world_loading:
		var ar: Array = [];
		var status := ResourceLoader.load_threaded_get_status(loading_path, ar);
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			instantiate_world();
	
	if enable_world_processing and world_scene:
		enable_world_processing = false;
		world_scene.process_mode = Node.PROCESS_MODE_INHERIT;
	return

## Prepares and starts threaded loading of World
func load_world(id: int) -> void:
	loading_screen.visible = true;
	
	if world_scene:
		remove_child(world_scene);
		world_scene.queue_free();
	
	loading_path = get_scene_path(id);
	ResourceLoader.load_threaded_request(loading_path);
	GameData.world_scene_id = id;
	is_world_loading = true;
	return

## Creates an Instance of the WorldScene and adds it to the SceneTree
func instantiate_world() -> void:
	is_world_loading = false;
	var scene := ResourceLoader.load_threaded_get(loading_path) as PackedScene;
	world_scene = scene.instantiate() as WorldScene;
	add_child(world_scene);
	return

## Returns the path the World
func get_scene_path(id: int) -> StringName:
	loading_screen.visible = false;
	match id:
		1: return "res://Worlds/world_scene_title_screen.tscn"
		_: return "res://Worlds/world_scene_debug.tscn"


func instantiate_ingame_menu() -> void:
	if ingame_menu_node == null:
		ingame_menu_node = ingame_menu_scene.instantiate();
		add_child(ingame_menu_node);
		world_scene.process_mode = Node.PROCESS_MODE_DISABLED;
	return


func close_ingame_menu() -> void:
	if ingame_menu_node:
		remove_child(ingame_menu_node);
		ingame_menu_node.queue_free();
		enable_world_processing = true;
	return


func instantiate_battle_scene() -> void:
	if battle_scene == null:
		battle_scene = battle_scene_packed.instantiate();
		add_child(battle_scene);
		battle_scene.global_position = player_char.global_position;
		world_scene.process_mode = Node.PROCESS_MODE_DISABLED;
		world_scene.visible = false;
	return


func end_battle_scene() -> void:
	if battle_scene:
		remove_child(battle_scene);
		battle_scene.queue_free();
		world_scene.visible = true;
		enable_world_processing = true;
	return
