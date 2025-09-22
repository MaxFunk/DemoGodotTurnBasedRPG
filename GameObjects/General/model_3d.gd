class_name Model3D extends Node3D

signal animation_finished(anim_name: String);

@export var default_animation: StringName = "";

var anim_player: AnimationPlayer;
var current_anim: StringName;
var current_speed: float = 1.0;


func _ready() -> void:
	for child in get_children(true):
		if child is AnimationPlayer:
			anim_player = child as AnimationPlayer;
			anim_player.playback_default_blend_time = 0.2; #TODO
			anim_player.animation_finished.connect(on_anim_finished);
			
			if anim_player.has_animation(default_animation):
				anim_player.play(default_animation);
	return


func play_animation(anim_name: String, with_capture: bool = false, speed_scale: float = 1.0) -> bool:
	if anim_player == null:
		return false
	
	if anim_name == current_anim:
		if is_equal_approx(current_speed, speed_scale):
			return true
		else:
			anim_player.play(anim_name, -1.0, speed_scale);
			return true
	#current_animation_position
	
	if anim_player.has_animation(anim_name):
		current_anim = anim_name;
		current_speed = speed_scale;
		
		if with_capture:
			anim_player.play_with_capture(anim_name, -1.0, -1.0, speed_scale);
		else:
			anim_player.play(anim_name, -1.0, speed_scale);
		return true
	return false


func on_anim_finished(anim_name: StringName) -> void:
	animation_finished.emit(anim_name);
	return


func has_animation(anim_name: String) -> bool:
	return anim_player and anim_player.has_animation(anim_name);
