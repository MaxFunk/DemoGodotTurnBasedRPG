class_name MainScene
extends Node3D

@onready var loading_screen := $LoadingScreenRect as ColorRect;

var world_scene: WorldScene;
var is_world_loading: bool = false;
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
