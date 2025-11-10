class_name WorldScene
extends Node3D

@export var load_exploration_ui: bool = true;
@export var area_music_id: int = -1;
@export var battle_markers_parent: Node = null;

var cutscene_node: GameCutscene = null;
var exploration_ui: ExplorationUI = null;


func _ready() -> void:
	if load_exploration_ui:
		var exploration_scene := preload("res://UserInterfaces/Exploration/exploration_user_interface.tscn");
		exploration_ui = exploration_scene.instantiate() as ExplorationUI;
		add_child(exploration_ui);
		exploration_ui.current_world_scene = self;
		exploration_ui.update_data();
	
	AudioManager.play_area_music(area_music_id);
	return


func add_cutscene_node(gc_node: GameCutscene) -> void:
	cutscene_node = gc_node;
	add_child(cutscene_node);
	cutscene_node.process_mode = Node.PROCESS_MODE_ALWAYS;
	return


func clear_cutscene_node() -> void:
	if cutscene_node:
		if cutscene_node.get_parent() == self:
			remove_child(cutscene_node);
		cutscene_node.queue_free();
		cutscene_node = null;
	return


func change_all_actors_visibility(value: bool) -> void:
	for child in get_children():
		if child.is_in_group("Actors") and child is Node3D:
			(child as Node3D).visible = value;
			child.process_mode = Node.PROCESS_MODE_INHERIT if value else Node.PROCESS_MODE_DISABLED;
	return


func set_exploration_ui_visibility(value: bool) -> void:
	if exploration_ui:
		exploration_ui.visible = value;
		exploration_ui.process_mode = Node.PROCESS_MODE_INHERIT if value else Node.PROCESS_MODE_DISABLED;
		if value:
			exploration_ui.update_data();
	return


func get_closest_battle_marker(pos: Vector3) -> Node3D:
	if battle_markers_parent:
		var closest_marker: Node3D = null;
		var closest_distance: float = 10000000.0;
		for child in battle_markers_parent.get_children():
			if child is Node3D:
				var dist := (child as Node3D).global_position.distance_to(pos);
				if dist < closest_distance:
					closest_distance = dist;
					closest_marker = (child as Node3D);
		return closest_marker;
	return null
