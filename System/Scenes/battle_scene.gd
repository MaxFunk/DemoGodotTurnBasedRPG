class_name BattleScene
extends Node3D

const PostBattleUI := preload("res://UserInterfaces/Battle/PostBattle/post_battle_menu.gd");

@onready var battle_ui := $BattleUI as BattleUI;
@onready var post_battle_ui := $PostBattleMenu as PostBattleUI;
@onready var battle_transitions := $BattleTransitions as AnimationPlayer;

# Camera Markers
@onready var camera := $Camera as Camera3D;
@onready var pivot_targeting := $PivotTargeting as Marker3D;
@onready var marker_targeting := $PivotTargeting/SpringArm3D/MarkerTargeting as Marker3D;
@onready var pivot_decision := $PivotDecision as Marker3D;
@onready var marker_decision := $PivotDecision/MarkerDecision as Marker3D;

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
var battle_fields: Array[BattleField] = [null, null, null]; # global, hero, oppo

var turn_order: Array[BattleData] = [];
var next_round: Array[BattleData] = [];
var cur_actor: BattleData = null;
var cur_action: ActionData = null;

var cam_marker: Node3D = null;
var cam_interpolate: bool = false;
var cam_interp_value: float = 0.0;

var exp_cashout: int = 0;
var battle_ending: bool = false;


func _ready() -> void:
	#camera.make_current();
	#begin_turn.connect(on_begin_turn);
	#end_turn.connect(on_end_turn);
	return


func _process(delta: float) -> void:
	if cur_action:
		cur_action.process();
	
	if cam_marker and cam_marker.is_inside_tree():
		if cam_interpolate:
			camera.global_transform = camera.global_transform.interpolate_with(cam_marker.global_transform, cam_interp_value);
			cam_interp_value += delta * 2.0;
			if cam_interp_value > 1.0:
				cam_interpolate = false;
		else:
			camera.global_position = cam_marker.global_position;
			camera.global_rotation = cam_marker.global_rotation;
	return


func initiate_battle(enemy_ids: PackedInt32Array, advantage: int) -> void:
	assert(enemy_ids.size() > 0, "No ids for opponents");
	
	initiate_battle_data_objects(enemy_ids);
	spawn_battle_chars();
	determine_initial_turn_order(advantage);
	battle_ui.init_battle_ui(self);
	battle_ui.write_advantage(advantage);
	
	for data in turn_order:
		print(data.name, " ", data.stats[5]);
	
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


func determine_initial_turn_order(advantage: int) -> void:
	var turn_order_heros: Array[BattleData] = [];
	var turn_order_enemies: Array[BattleData] = [];
	turn_order.clear();
	
	for hero in active_heros:
		if hero != null:
			turn_order_heros.append(hero);
	for oppo in opponents:
		if oppo != null:
			turn_order_enemies.append(oppo);
	
	if advantage < 0:
		turn_order_heros.sort_custom(sort_agility);
		turn_order_enemies.sort_custom(sort_agility);
		turn_order.append_array(turn_order_enemies);
		turn_order.append_array(turn_order_heros);
	elif advantage > 0:
		turn_order_heros.sort_custom(sort_agility);
		turn_order_enemies.sort_custom(sort_agility);
		turn_order.append_array(turn_order_heros);
		turn_order.append_array(turn_order_enemies);
	else:
		turn_order.append_array(turn_order_heros);
		turn_order.append_array(turn_order_enemies);
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
	
	if cur_actor.is_hero:
		pivot_decision.global_transform = hero_spawnpoints[cur_actor.position].global_transform;
	else:
		pivot_decision.global_transform = enemy_spawnpoints[cur_actor.position - 3].global_transform;
	update_camera_marker(marker_decision, false);
	
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
	if cur_actor.is_hero == false:
		cur_actor.actions_done += 1;
		if cur_actor.actions_done < cur_actor.max_actions:
			opponent_turn_decision();
			return
	
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
	if action == null:
		update_camera_marker(marker_decision, true);
		return
	
	match action.target_type:
		action.TARGETTYPE.SINGLE_OPPONENT:
			pivot_targeting.transform = opponents[action.index_target].battle_char.transform;
			pivot_targeting.rotate_y(PI);
		action.TARGETTYPE.SINGLE_ALLY, action.TARGETTYPE.SELF_ONLY:
			pivot_targeting.transform = active_heros[action.index_target].battle_char.transform;
			pivot_targeting.rotate_y(PI);
		action.TARGETTYPE.ALL_OPPONENTS:
			pivot_targeting.transform = camera_markers[2].transform;
		action.TARGETTYPE.ALL_ALLIES:
			pivot_targeting.transform = camera_markers[1].transform;
		action.TARGETTYPE.ALL:
			pivot_targeting.transform = camera_markers[0].transform;
		action.TARGETTYPE.SINGLE_EVERYONE:
			if action.index_target < 3:
				pivot_targeting.transform = active_heros[action.index_target].battle_char.transform;
			else:
				pivot_targeting.transform = opponents[action.index_target - 3].battle_char.transform;
			pivot_targeting.rotate_y(PI);
		_:
			pass
	
	update_camera_marker(marker_targeting, true);
	return


func update_camera_marker(node: Node3D, with_interpolation: bool) -> void:
	if node == null:
		return
	
	cam_marker = node;
	if with_interpolation:
		cam_interpolate = true;
		cam_interp_value = 0.0;
	else:
		camera.global_position = node.global_position;
		camera.global_rotation = node.global_rotation;
	camera.make_current();
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
		
		battle_transitions.play("BattleWon");
		update_camera_marker(marker_targeting, false);
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
			if battle_fields[0]:
				remove_field(battle_fields[0]);
			add_child(field);
			battle_fields[0] = field;
		
		elif (field.field_type == field.FIELDTYPE.ALLIED and cast_by_hero) or \
		(field.field_type == field.FIELDTYPE.OPPOSITE and !cast_by_hero):
			if battle_fields[1]:
				remove_field(battle_fields[1]);
			add_child(field);
			field.global_position = hero_spawnpoints[0].global_position;
			battle_fields[1] = field;
		
		elif (field.field_type == field.FIELDTYPE.ALLIED and !cast_by_hero) or \
		(field.field_type == field.FIELDTYPE.OPPOSITE and cast_by_hero):
			if battle_fields[2]:
				remove_field(battle_fields[2]);
			add_child(field);
			field.global_position = enemy_spawnpoints[0].global_position;
			battle_fields[2] = field;
	return


func remove_field(field: BattleField) -> void:
	for field_entry in battle_fields:
		if field_entry == field:
			field_entry = null;
	
	remove_child(field);
	field.queue_free();
	return


func check_fields(actor: BattleData) -> void:
	for field in battle_fields:
		if field and field.caster == actor:
			if field.increas_turn_timer():
				remove_field(field);
	return
