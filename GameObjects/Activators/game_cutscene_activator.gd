extends Area3D

@export var game_cutscene_id: int = -1;
@export var after_cutscene_marker: Marker3D;

var has_entered: bool = false;
var loaded_cutscene: bool = false;


func _process(_delta: float) -> void:
	if has_entered and not loaded_cutscene:
		GameData.main_scene.load_game_cutscene(game_cutscene_id, self);
		loaded_cutscene = true;
	return


func _on_body_entered(body: Node3D) -> void:
	if body is PlayerCharacter and game_cutscene_id >= 0 :
		has_entered = true;
	return
