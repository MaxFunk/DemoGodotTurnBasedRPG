class_name MainScene
extends Node3D

const ingame_menu_scene := preload("res://UserInterfaces/IngameMenu/ingame_menu_ui.tscn");
const battle_scene_packed := preload("res://System/Scenes/battle_scene.tscn");
const IngameMenu := preload("res://UserInterfaces/IngameMenu/ingame_menu_ui.gd");

signal world_scene_instantiated();
signal battle_finished();

@onready var loading_screen := $LoadingScreen as LoadingScreen;

var world_scene: WorldScene;
var battle_scene: BattleScene;
var player_char: PlayerCharacter;

var ingame_menu_node: IngameMenu;
var talking_ui: TalkingUI;

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
	if id == 1:
		loading_screen.set_active();
	else:
		loading_screen.start_fade_in();
		await loading_screen.fade_finished;
	
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
	
	loading_screen.start_fade_out();
	world_scene_instantiated.emit();
	return


func load_player_transform(pos: String, rot: String) -> void:
	await world_scene_instantiated;
	
	var pos_array := pos.remove_chars("()").split(", ");
	var rot_array := rot.remove_chars("()").split(", ");
	
	if player_char == null or pos_array.size() < 3 or rot_array.size() < 3:
		return
	
	player_char.global_position = Vector3(float(pos_array[0]), float(pos_array[1]), float(pos_array[2]));
	player_char.global_rotation = Vector3(float(rot_array[0]), float(rot_array[1]), float(rot_array[2]));
	return


## Returns the path the World
func get_scene_path(id: int) -> StringName:
	match id:
		1: return "res://Worlds/world_scene_title_screen.tscn"
		_: return "res://Worlds/world_scene_debug.tscn"


func instantiate_ingame_menu() -> void:
	if ingame_menu_node == null:
		ingame_menu_node = ingame_menu_scene.instantiate() as IngameMenu;
		add_child(ingame_menu_node);
		world_scene.process_mode = Node.PROCESS_MODE_DISABLED;
	return


func close_ingame_menu() -> void:
	if ingame_menu_node:
		remove_child(ingame_menu_node);
		ingame_menu_node.queue_free();
		player_char.load_hero_model();
		enable_world_processing = true;
	return


func instantiate_talking_ui(first_text_id: int) -> void:
	if talking_ui == null: # safety?
		player_char.move_mode = player_char.MOVEMODE.NONE;
		talking_ui = preload("res://UserInterfaces/General/talking_ui.tscn").instantiate() as TalkingUI;
		add_child(talking_ui);
		talking_ui.begin(first_text_id);
	return


func clear_talking_ui() -> void:
	if talking_ui:
		remove_child(talking_ui);
		talking_ui.queue_free();
		player_char.move_mode = player_char.MOVEMODE.WALKING;
	return


func instantiate_battle_scene(scene_transform: Transform3D, enemy_group: EnemyGroup) -> void:
	if enemy_group == null:
		return
	
	if battle_scene == null:
		battle_finished.connect(enemy_group.on_battle_finished);
		battle_scene = battle_scene_packed.instantiate() as BattleScene;
		world_scene.add_child(battle_scene);
		world_scene.change_all_actors_visibility(false);
		battle_scene.global_transform = scene_transform;
		battle_scene.initiate_field(enemy_group.enemy_ids);
	return


func end_battle_scene() -> void:
	if battle_scene:
		world_scene.remove_child(battle_scene);
		world_scene.change_all_actors_visibility(true);
		battle_scene.queue_free();
		battle_finished.emit();
	return


func load_game_cutscene(_id: int, activator: Node3D) -> void:
	world_scene.process_mode = Node.PROCESS_MODE_DISABLED;
	loading_screen.start_fade_in();
	await loading_screen.fade_finished;
	
	var cutscene_node := preload("uid://dhljnek2lxm7i").instantiate() as GameCutscene;
	world_scene.add_cutscene_node(cutscene_node);
	cutscene_node.setup_cutscene(activator);
	player_char.visible = false;
	activator.queue_free();
	
	loading_screen.start_fade_out();
	cutscene_node.start_next_step();
	return


func finish_game_cutscene(char_transform: Transform3D) -> void:
	loading_screen.start_fade_in();
	await loading_screen.fade_finished;
	
	world_scene.clear_cutscene_node();
	world_scene.process_mode = Node.PROCESS_MODE_INHERIT;
	player_char.global_transform = char_transform;
	player_char.visible = true;
	player_char.model_3d.play_animation("Idle");
	
	loading_screen.start_fade_out();
	return
