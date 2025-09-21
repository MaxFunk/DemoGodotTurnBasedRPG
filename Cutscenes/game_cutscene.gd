class_name GameCutscene extends Node3D

const GameCutsceneActivator = preload("uid://dq37il40rkaym")

@export var camera: Camera3D;
@export var anim_player: AnimationPlayer;
@export var talking_ui: TalkingUI;

@export var max_anim_steps: int = 1;
@export var step_conditions: Array[int] = []; # 0 = automatic, 1 = event

var anim_step: int = 0; # anim_names: Step1, Step2, ...
var after_cutscene_transform := Transform3D();


func _ready() -> void:
	if step_conditions.size() < max_anim_steps:
		step_conditions.resize(max_anim_steps);
	
	anim_player.animation_finished.connect(anim_player_animation_finished);
	camera.make_current();
	return


func setup_cutscene(activator: GameCutsceneActivator) -> void:
	global_position = activator.global_position;
	
	if activator.after_cutscene_marker:
		after_cutscene_transform = activator.after_cutscene_marker.global_transform;
	else:
		after_cutscene_transform = global_transform;
	return


func start_next_step() -> void:
	anim_step += 1;
	
	if anim_step > max_anim_steps:
		GameData.main_scene.finish_game_cutscene(after_cutscene_transform);
		return
	
	anim_player.play(str("Step", anim_step));
	return


func anim_player_animation_finished(_anim_name: StringName) -> void:
	if step_conditions[anim_step - 1] == 0:
		start_next_step();
	return


func talking_ui_begin(start_id: int) -> void:
	if talking_ui:
		anim_player.pause();
		talking_ui.visible = true;
		talking_ui.begin(start_id);
	return


func talking_ui_end() -> void:
	if talking_ui:
		anim_player.play();
		talking_ui.visible = false;
	return
