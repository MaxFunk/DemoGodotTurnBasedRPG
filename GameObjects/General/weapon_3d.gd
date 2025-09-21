class_name Weapon3D extends Node3D

var anim_player: AnimationPlayer;
var current_anim: StringName;
var current_speed: float = 1.0;


func _ready() -> void:
	for child in get_children(true):
		if child is AnimationPlayer:
			anim_player = child as AnimationPlayer;
			anim_player.playback_default_blend_time = 0.2; #TODO
	return


func play_animation(anim_name: String, with_capture: bool = false, speed_scale: float = 1.0) -> void:
	if anim_player == null:
		return
	
	if anim_name == current_anim:
		if is_equal_approx(current_speed, speed_scale):
			return
		else:
			anim_player.play(anim_name, -1.0, speed_scale);
			return
	
	if anim_player.has_animation(anim_name):
		visible = true;
		current_anim = anim_name;
		current_speed = speed_scale;
		if with_capture:
			anim_player.play_with_capture(anim_name, -1.0, -1.0, speed_scale);
		else:
			anim_player.play(anim_name, -1.0, speed_scale);
	else:
		visible = false;
	return
