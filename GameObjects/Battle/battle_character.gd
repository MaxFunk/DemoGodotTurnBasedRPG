class_name BattleCharacter
extends CharacterBody3D

signal defeated_anim_finished();

var model_3d: Model3D;
var weapon_3d: Weapon3D;


func _ready() -> void:
	if model_3d:
		play_idle_anim("");
	return


func load_model(model_id: int, is_hero: bool) -> void:
	var packed_model: PackedScene;
	var packed_weapon: PackedScene;
	if is_hero:
		packed_model = ResourceManager.get_hero_model(model_id);
		packed_weapon = ResourceManager.get_hero_weapon(model_id);
	else:
		packed_model = ResourceManager.get_hero_model(2); #preload("res://Resources/Models/NPCs/char_base.glb");
	model_3d = packed_model.instantiate() as Model3D;
	add_child(model_3d);
	if is_hero:
		weapon_3d = packed_weapon.instantiate() as Weapon3D;
		add_child(weapon_3d);
		weapon_3d.rotate_y(PI);
		model_3d.rotate_y(PI);
	
	model_3d.animation_finished.connect(play_idle_anim);
	return


func play_anim(anim_name: String, with_capture: bool = false, speed_scale: float = 1.0) -> void:
	if model_3d:
		model_3d.play_animation(anim_name, with_capture, speed_scale);
	
	if weapon_3d:
		weapon_3d.play_animation(anim_name, with_capture, speed_scale);
	return


func play_idle_anim(prev_anim_name: String) -> void:
	if prev_anim_name == "BattleBlock":
		return
	
	if prev_anim_name == "BattleDefeat":
		defeated_anim_finished.emit();
	
	if model_3d.play_animation("BattleIdle") == false:
		model_3d.play_animation("IdleBattle");
	
	if weapon_3d:
		weapon_3d.play_animation("BattleIdle");
	return
