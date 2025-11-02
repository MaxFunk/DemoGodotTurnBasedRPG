class_name ActionCast
extends Node3D

signal cast_hit_succesful();

enum CASTTYPE {TOWARDS_TARGET, ON_TARGET, GLOBAL}

@export var cast_steps: int = 1;
@export var anim_player: AnimationPlayer;
@export var marker_camera: Marker3D;
@export var cast_type := CASTTYPE.TOWARDS_TARGET;

var action: ActionData;
var cast_step: int = 1;
var target_idx: int = 0;

var is_invalid: bool = false;
var is_finished: bool = false;
var wait_cast_hit: bool = false;


func _ready() -> void:
	if anim_player:
		anim_player.animation_finished.connect(on_animation_finished);
	else:
		is_invalid = true;
	return


func write_camera_marker(battle_scene: BattleScene) -> void:
	if marker_camera:
		battle_scene.update_camera_marker(marker_camera, false);
	else:
		battle_scene.update_camera_marker(self, true);
	return


func start_cast_animation(action_data: ActionData, t_idx: int) -> void:
	action = action_data;
	target_idx = t_idx;
	
	if is_invalid:
		await action.action_cast_hit(t_idx);
		is_finished = true;
		return
	
	match cast_type:
		CASTTYPE.TOWARDS_TARGET:
			transform = action.user.battle_char.transform;
			if action.user != action.targets[t_idx]:
				look_at(action.targets[t_idx].battle_char.global_position);
		CASTTYPE.ON_TARGET:
			transform = action.targets[t_idx].battle_char.transform;
		CASTTYPE.GLOBAL:
			transform = Transform3D.IDENTITY;
		
	
	anim_player.play("Cast1");
	return


func cast_hit() -> void:
	wait_cast_hit = true;
	await action.action_cast_hit(target_idx);
	cast_hit_succesful.emit();
	wait_cast_hit = false;
	return


func on_animation_finished(_anim_name: StringName) -> void:
	if cast_step >= cast_steps:
		if wait_cast_hit:
			await cast_hit_succesful;
		is_finished = true;
	return
