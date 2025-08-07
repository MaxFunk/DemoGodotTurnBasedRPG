extends StaticBody3D

@onready var model_3d := $ModelNPC as Model3D;


func _ready() -> void:
	model_3d.play_animation("IdleStanding");
	return


func _on_interaction_component_interaction() -> void:
	GameData.main_scene.instantiate_talking_ui();
	return
