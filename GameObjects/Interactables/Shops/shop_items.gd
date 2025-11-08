extends Node3D

const item_shop_ui_scene := preload("uid://te6rbf81tcw1");


func _on_interaction_component_interaction() -> void:
	GameData.main_scene.instantiate_user_interface(item_shop_ui_scene);
	return
