extends StaticBody3D


func _on_interaction_component_interaction() -> void:
	print("INTERACTION WORKED");
	GameData.main_scene.load_world(2);
	return


func _ready() -> void:
	return
