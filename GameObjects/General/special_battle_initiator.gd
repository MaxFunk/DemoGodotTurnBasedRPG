class_name SpecialBattleInitiator
extends Area3D

@export var anim_player: AnimationPlayer;
@export var camera_3d: Camera3D;
@export var battle_marker: Marker3D;

@export var animation_name: StringName;
@export var opponent_ids: Array[int] = [];
@export var music_id: int = 10;

var anim_valid: bool = true;


func _ready() -> void:
	if !anim_player or !camera_3d or !anim_player.has_animation(animation_name):
		anim_valid = false;
	
	body_entered.connect(on_body_entered);
	if anim_valid:
		anim_player.animation_finished.connect(on_animation_finished);
	return


func on_body_entered(body: Node3D) -> void:
	if body is PlayerCharacter:
		if anim_valid:
			var player := body as PlayerCharacter;
			player.move_mode = player.MOVEMODE.NONE;
			#player.process_mode = Node.PROCESS_MODE_DISABLED; # Disable World instead?
			camera_3d.make_current();
			anim_player.play(animation_name);
			GameData.main_scene.battle_finished.connect(on_battle_finished);
		else:
			GameData.main_scene.battle_finished.connect(on_battle_finished);
			on_animation_finished(animation_name);
	return


func on_animation_finished(anim_name: StringName) -> void:
	if anim_name == animation_name:
		var player := GameData.main_scene.player_char;
		player.move_mode = player.MOVEMODE.WALKING;
		var enemy_group := EnemyGroup.new();
		enemy_group.enemy_ids = opponent_ids;
		enemy_group.music_id = music_id;
		enemy_group.surpress_spwans = true;
		add_child(enemy_group)
		if battle_marker:
			GameData.main_scene.instantiate_battle_scene(battle_marker.global_transform, enemy_group, 0);
		else:
			GameData.main_scene.instantiate_battle_scene(global_transform, enemy_group, 0);
	return


func on_battle_finished() -> void:
	# TODO: set flags e.g. for Minibosses?
	GameData.main_scene.battle_finished.disconnect(on_battle_finished);
	queue_free();
	return
