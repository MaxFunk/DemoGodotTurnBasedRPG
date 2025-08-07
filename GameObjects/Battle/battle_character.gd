class_name BattleCharacter
extends CharacterBody3D

var model_3d: Model3D;


func _ready() -> void:
	if model_3d:
		play_idle_anim();
	return


func load_model(model_id: int, is_hero: bool) -> void:
	var packed_model: PackedScene;
	if is_hero:
		packed_model = ResourceManager.get_hero_model(model_id);
	else:
		packed_model = preload("res://Resources/Models/NPCs/char_base.glb");
	model_3d = packed_model.instantiate() as Model3D;
	add_child(model_3d);
	
	model_3d.animation_finished.connect(play_idle_anim);
	return


func play_idle_anim() -> void:
	if model_3d.play_animation("BattleIdle") == false:
		model_3d.play_animation("IdleBattle");
	return
