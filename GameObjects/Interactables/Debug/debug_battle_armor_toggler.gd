extends Node3D


func _on_interaction_component_interaction() -> void:
	GameData.main_scene.player_char.toggle_battlearmor();
	return
