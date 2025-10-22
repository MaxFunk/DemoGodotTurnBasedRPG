class_name BattleScene
extends Node3D

const PostBattleUI := preload("res://UserInterfaces/Battle/PostBattle/post_battle_menu.gd");

@onready var battle_ui := $BattleUI as BattleUI;
@onready var post_battle_ui := $PostBattleMenu as PostBattleUI;
@onready var battle_transitions := $BattleTransitions as AnimationPlayer;

# Targeting Camera
@onready var cam_pivot := $CameraPivot as Marker3D;
@onready var cam_arm := $CameraPivot/SpringArm3D as SpringArm3D;
@onready var camera := $CameraPivot/SpringArm3D/Camera3D as Camera3D;
# Behind Camera
@onready var cam_2_pivot := $Camera2Pivot as Marker3D;
@onready var camera_2 := $Camera2Pivot/Camera2 as Camera3D;

@onready var hero_spawnpoints: Array[Marker3D] = [
	$SpawnMarker/HeroSpawnMiddle as Marker3D,
	$SpawnMarker/HeroSpawnLeft as Marker3D,
	$SpawnMarker/HeroSpawnRight as Marker3D];
@onready var enemy_spawnpoints: Array[Marker3D] = [
	$SpawnMarker/EnemySpawn1 as Marker3D,
	$SpawnMarker/EnemySpawn2 as Marker3D,
	$SpawnMarker/EnemySpawn3 as Marker3D,
	$SpawnMarker/EnemySpawn4 as Marker3D,
	$SpawnMarker/EnemySpawn5 as Marker3D];
@onready var camera_markers: Array[Marker3D] = [
	$CameraMarker/CamMarkerAll as Marker3D,
	$CameraMarker/CamMarkerAllHeros as Marker3D,
	$CameraMarker/CamMarkerAllOppos as Marker3D];

var active_heros: Array[BattleData] = [];
var opponents: Array[BattleData] = [];

var battle_chars: Array[BattleCharacter] = [];
var battle_field_global: BattleField = null;
var battle_field_heros: BattleField = null;
var battle_field_oppos: BattleField = null;

var turn_order: Array[BattleData] = [];
var next_round: Array[BattleData] = [];
var cur_actor: BattleData = null;
var cur_action: ActionData = null;

var exp_cashout: int = 0;
var battle_ending: bool = false;


func _ready() -> void:
	#camera.make_current();
	#begin_turn.connect(on_begin_turn);
	#end_turn.connect(on_end_turn);
	return


func _process(_delta: float) -> void:
	if cur_action:
		cur_action.process();
	return


func initiate_field(enemy_ids: PackedInt32Array) -> void:
	assert(enemy_ids.size() > 0, "No ids for opponents");
	
	initiate_battle_data_objects(enemy_ids);
	spawn_battle_chars();
	determine_turn_order();
	battle_ui.init_battle_ui(self);
	
	camera.make_current();
	battle_transitions.play("BattleEntrance");
	await battle_transitions.animation_finished;
	
	on_begin_turn();
	return


func initiate_battle_data_objects(oppo_ids: PackedInt32Array) -> void:
	for i in range(5):
		if i < oppo_ids.size():
			var new_oppo := BattleData.new();
			new_oppo.load_opponent_data(oppo_ids[i]);
			new_oppo.position = i + 3;
			opponents.append(new_oppo);
		else:
			opponents.append(null);
	
	for i in range(3):
		var id := GameData.active_party[i];
		if id >= 0:
			var new_hero := BattleData.new();
			new_hero.load_existing_chardata(GameData.characters[id]);
			new_hero.position = i;
			active_heros.append(new_hero);
		else:
			active_heros.append(null);
	return


func spawn_battle_chars() -> void:
	for i in range(3):
		if active_heros[i] != null:
			var new_battle_char := preload("res://GameObjects/Battle/battle_character.tscn").instantiate() as BattleCharacter;
			new_battle_char.load_model(active_heros[i].id, true);
			active_heros[i].battle_char = new_battle_char;
			add_child(new_battle_char);
			new_battle_char.global_transform = hero_spawnpoints[i].global_transform;
			battle_chars.append(new_battle_char);
	
	for i in range(5):
		if opponents[i] != null:
			var new_battle_char := preload("res://GameObjects/Battle/battle_character.tscn").instantiate() as BattleCharacter;
			new_battle_char.load_model(opponents[i].id, false);
			opponents[i].battle_char = new_battle_char;
			add_child(new_battle_char);
			new_battle_char.global_transform = enemy_spawnpoints[i].global_transform;
			new_battle_char.rotate_y(PI);
			battle_chars.append(new_battle_char);
	return


func determine_turn_order() -> void:
	for hero in active_heros:
		if hero != null:
			turn_order.append(hero);
	for oppo in opponents:
		if oppo != null:
			turn_order.append(oppo);
	
	turn_order.sort_custom(sort_agility);
	return

## Does everything that happen when a new turn begins
func on_begin_turn() -> void:
	if turn_order.size() <= 0:
		turn_order = next_round.duplicate();
		next_round.clear();
	
	cur_actor = turn_order[0];
	turn_order.remove_at(0);
	cur_actor.on_turn_begin();
	
	update_camera_2_positioning();
	
	print("Begin turn: ", cur_actor.name);
	if cur_actor.is_hero:
		battle_ui.on_hero_turn_start();
	else:
		opponent_turn_decision();
	return


func commit_action(action: ActionData) -> void:
	if cur_actor.is_hero: # maybe not needed anymore -> MENUSTATE.OFF does the same
		battle_ui.accept_inputs = false;
	
	cur_action = action;
	cur_action.commit_targets();
	if cur_action.check_user_can_cast():
		cur_action.apply_action_cost();
		cur_action.cast_action();
		await cur_action.finished_casting;
		cur_action.clean_up_casts();
	cur_action = null;
	
	if !battle_ending:
		on_end_turn();
	return


## Does everything that happen when current turn ends
func on_end_turn() -> void:
	cur_actor.on_turn_end();
	check_fields(cur_actor);
	next_round.append(cur_actor);
	next_round.sort_custom(sort_agility);
	cur_actor = null;
	
	on_begin_turn();
	return


func opponent_turn_decision() -> void:
	var opponent_action := OpponentDecision.decide_action_standard(cur_actor, self);
	commit_action(opponent_action);
	return


func update_camera_targeting(action: ActionData) -> void:
	if !action:
		update_camera_2_positioning();
		return
	
	camera.make_current();
	match action.target_type:
		action.TARGETTYPE.SINGLE_OPPONENT:
			cam_pivot.transform = opponents[action.index_target].battle_char.transform;
			#cam_pivot.rotate_y(PI);
		action.TARGETTYPE.SINGLE_ALLY, action.TARGETTYPE.SELF_ONLY:
			cam_pivot.transform = active_heros[action.index_target].battle_char.transform;
		action.TARGETTYPE.ALL_OPPONENTS:
			cam_pivot.transform = camera_markers[2].transform;
		action.TARGETTYPE.ALL_ALLIES:
			cam_pivot.transform = camera_markers[1].transform;
		action.TARGETTYPE.ALL:
			cam_pivot.transform = camera_markers[0].transform;
		action.TARGETTYPE.SINGLE_EVERYONE:
			if action.index_target < 3:
				cam_pivot.transform = active_heros[action.index_target].battle_char.transform;
			else:
				cam_pivot.transform = opponents[action.index_target - 3].battle_char.transform;
		_:
			pass
	return


func update_camera_2_positioning() -> void:
	camera_2.make_current();
	if cur_actor.is_hero:
		cam_2_pivot.global_transform = hero_spawnpoints[cur_actor.position].global_transform;
	else:
		cam_2_pivot.global_transform = enemy_spawnpoints[cur_actor.position - 3].global_transform;
	return


func sort_agility(a: BattleData, b: BattleData) -> bool: 
	var agil_a: float = a.stats[5] * Calculations.get_modifier(a.modifier[2]);
	var agil_b: float = b.stats[5] * Calculations.get_modifier(b.modifier[2]);
	return agil_a > agil_b


func on_character_defeated(chd: BattleData) -> void:
	await chd.on_defeat();
	
	remove_child(chd.battle_char); # queue_free? (careful with 'battle_chars' !)
	turn_order.erase(chd);
	next_round.erase(chd);
	
	if chd.is_hero:
		battle_ui.hero_displays[chd.position].set_to_defeated_state();
		
		for hero in active_heros:
			if hero.is_defeated == false: return
		
		battle_ending = true;
		process_mode = Node.PROCESS_MODE_DISABLED;
		post_battle_ui.init_ui(true, exp_cashout);
	else:
		var chd_index := chd.position - 3;
		exp_cashout += chd.exp_on_defeat;
		opponents[chd_index] = null;
		battle_ui.oppo_displays[chd_index].visible = false;
		battle_ui.oppo_displays[chd_index].oppo_data = null;
		
		for oppo in opponents:
			if oppo != null: return
		
		camera.make_current();
		battle_transitions.play("BattleWon");
		await battle_transitions.animation_finished;
		
		battle_ending = true;
		for hero in active_heros:
			if hero:
				hero.write_back_character_data();
		process_mode = Node.PROCESS_MODE_DISABLED;
		post_battle_ui.init_ui(false, exp_cashout);
	return


func get_random_opponent() -> BattleData:
	var valid_indices: PackedInt32Array = [];
	for i in opponents.size():
		if opponents[i] != null: valid_indices.append(i);
	
	var random_index: int = valid_indices[randi_range(0, valid_indices.size() - 1)];
	return opponents[random_index];


func create_field(art: BattleArt, caster: BattleData) -> void:
	if art.effects.size() <= 0 or art.effect_values.size() <= 0:
		return
	if art.effects[0] == EffectIDs.FIELD_CREATE:
		var field_id: int = art.effect_values[0];
		var field_scene := BattleFieldHandler.get_field_scene(field_id);
		var field := field_scene.instantiate() as BattleField;
		var cast_by_hero = caster.is_hero;
		field.caster = caster;
		if field == null:
			return
		
		if field.field_type == field.FIELDTYPE.GLOBAL:
			if battle_field_global:
				remove_field(battle_field_global);
			add_child(field);
			battle_field_global = field;
		
		elif (field.field_type == field.FIELDTYPE.ALLIED and cast_by_hero) or \
		(field.field_type == field.FIELDTYPE.OPPOSITE and !cast_by_hero):
			if battle_field_heros:
				remove_field(battle_field_heros);
			add_child(field);
			field.global_position = hero_spawnpoints[0].global_position;
			battle_field_heros = field;
		
		elif (field.field_type == field.FIELDTYPE.ALLIED and !cast_by_hero) or \
		(field.field_type == field.FIELDTYPE.OPPOSITE and cast_by_hero):
			if battle_field_oppos:
				remove_field(battle_field_oppos);
			add_child(field);
			field.global_position = enemy_spawnpoints[0].global_position;
			battle_field_oppos = field;
	return


func remove_field(field: BattleField) -> void:
	if battle_field_global == field:
		battle_field_global = null;
	elif battle_field_heros == field:
		battle_field_global = null;
	elif battle_field_oppos == field:
		battle_field_global = null;
	
	remove_child(field);
	field.queue_free();
	return


func check_fields(actor: BattleData) -> void:
	if battle_field_global and battle_field_global.caster == actor:
		if battle_field_global.increas_turn_timer():
			remove_field(battle_field_global);
	
	if battle_field_heros and battle_field_heros.caster == actor:
		if battle_field_heros.increas_turn_timer():
			remove_field(battle_field_heros);
	
	if battle_field_oppos and battle_field_oppos.caster == actor:
		if battle_field_oppos.increas_turn_timer():
			remove_field(battle_field_oppos);
	return
