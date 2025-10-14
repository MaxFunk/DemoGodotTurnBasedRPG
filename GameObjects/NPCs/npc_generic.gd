extends StaticBody3D

@export var first_text_id: int = -1;
@export var model_packed_scene: PackedScene;

var model_3d: Model3D = null;


func _ready() -> void:
	if model_packed_scene:
		model_3d = model_packed_scene.instantiate() as Model3D;
		add_child(model_3d);
		if model_3d.play_animation("Idle") == false:
			model_3d.play_animation("IdleStanding");
	return


func _on_interaction_component_interaction() -> void:
	GameData.main_scene.instantiate_talking_ui(first_text_id);
	return
