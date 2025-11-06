class_name BattleAnimation extends Node3D

signal animation_finished();

@export var animation_player: AnimationPlayer = null;
@export var animation_name: StringName = "";
@export var marker_camera: Marker3D = null;


func _ready() -> void:
	if animation_player:
		animation_player.animation_finished.connect(on_anim_player_animation_finished);
	return


func play_animation() -> bool:
	if animation_player.has_animation(animation_name):
		animation_player.play(animation_name);
		return true
	return false


func write_camera_marker(battle_scene: BattleScene) -> void:
	if marker_camera:
		battle_scene.update_camera_marker(marker_camera, false);
	else:
		battle_scene.update_camera_marker(self, false);
	return


func on_anim_player_animation_finished(anim_name: StringName) -> void:
	if animation_name == anim_name:
		animation_finished.emit();
	return
