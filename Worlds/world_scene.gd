class_name WorldScene
extends Node3D

var cutscene_node: GameCutscene = null;


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
