class_name ActionData
extends RefCounted

signal finished_casting();

enum ACTIONTYPE {ATTACK = 0, ART = 1, ULT = 2, BLOCK = 3, ITEM = 4, INSPECT = 5, ANALYZE = 6}
enum TARGETTYPE {SINGLE_OPPONENT = 0, SINGLE_ALLY = 1, SELF_ONLY = 2, ALL_OPPONENTS = 3, 
	ALL_ALLIES = 4, ALL = 5, SINGLE_EVERYONE = 6, NONE = 7} # See BattleArt

var action_type := ACTIONTYPE.ATTACK;
var target_type := TARGETTYPE.SINGLE_OPPONENT;

var index_target: int = 0; # equals position, for All -> first 3 hero, then rest oppo
var battle_scene: BattleScene;
var art: BattleArt;

# Data filled after action was commited -> will not be modified afterwards
var user: BattleData;
var targets: Array[BattleData];

var action_casts: Array[ActionCast] = [];

var check_casts: bool = false;
var user_is_stunned: bool = false;
var user_is_confused: bool = false;
var sp_adjusted: bool = false;
var ult_points_adjusted: bool = false;


func _init(act_type: ACTIONTYPE, scene: BattleScene) -> void:
	action_type = act_type;
	battle_scene = scene;
	return


func commit_user_and_targets() -> void:
	user = battle_scene.cur_actor;
	
	match target_type:
		TARGETTYPE.SINGLE_OPPONENT:
			if user.is_hero:
				targets.append(battle_scene.opponents[index_target]);
			else:
				targets.append(battle_scene.active_heros[index_target]);
		TARGETTYPE.SINGLE_ALLY, TARGETTYPE.SELF_ONLY:
			if user.is_hero:
				targets.append(battle_scene.active_heros[index_target]);
			else:
				targets.append(battle_scene.opponents[index_target]);
		TARGETTYPE.ALL_OPPONENTS:
			if user.is_hero:
				for oppo in battle_scene.opponents:
					if oppo != null: targets.append(oppo);
			else:
				for hero in battle_scene.active_heros:
					if hero != null: targets.append(hero);
		TARGETTYPE.ALL_ALLIES:
			if user.is_hero:
				for hero in battle_scene.active_heros:
					if hero != null: targets.append(hero);
			else:
				for oppo in battle_scene.opponents:
					if oppo != null: targets.append(oppo);
		TARGETTYPE.ALL:
			for hero in battle_scene.active_heros:
				if hero != null: targets.append(hero);
			for oppo in battle_scene.opponents:
				if oppo != null: targets.append(oppo);
		TARGETTYPE.SINGLE_EVERYONE:
			if index_target < 3:
				targets.append(battle_scene.active_heros[index_target]);
			else:
				targets.append(battle_scene.opponents[index_target - 3]);
		_:
			pass
	return


func cast_action() -> void:
	var action_cast_scene := load(get_action_cast_path()) as PackedScene;
	
	battle_scene.battle_ui.lbl_action_name.text = get_action_name();
	battle_scene.battle_ui.lbl_action_name.visible = true;
	
	if user.is_hero:
		user.battle_char.model_3d.play_animation("EtherMultiple");
	else:
		user.battle_char.model_3d.play_animation("CastEther");
	
	if get_multcast_allowed():
		for i in targets.size():
			var action_cast: ActionCast = action_cast_scene.instantiate();
			battle_scene.add_child(action_cast);
			if action_cast.has_own_camera:
				action_cast.camera.make_current();
			action_cast.start_cast_animation(self, i);
			action_casts.append(action_cast);
	else:
		var action_cast: ActionCast = action_cast_scene.instantiate();
		battle_scene.add_child(action_cast);
		if action_cast.has_own_camera:
			action_cast.camera.make_current();
		action_cast.start_cast_animation(self, 0);
		action_casts.append(action_cast);
	
	if action_casts.size() > 1:
		# TODO: idk lol
		if action_casts[0].has_own_camera:
			action_casts[0].camera.make_current();
	elif action_casts.size() == 1:
		if action_casts[0].has_own_camera:
			action_casts[0].camera.make_current();
	
	check_casts = true;
	return


func clean_up_casts() -> void:
	for cast in action_casts:
		battle_scene.remove_child(cast);
		cast.queue_free();
	action_casts.clear();
	return


func process() -> void:
	if check_casts:
		var all_casts_finished: bool = true;
		for cast in action_casts:
			if !cast.is_finished: all_casts_finished = false;
		if all_casts_finished:
			check_casts = false;
			finished_casting.emit();
	
	# TODO
	return


func action_cast_hit(t_idx: int) -> void:
	if get_multcast_allowed():
		await apply_action(t_idx);
	else:
		for i in targets.size():
			await apply_action(i);
	return


func apply_action(t_idx: int) -> void:
	if t_idx < 0 or t_idx >= targets.size():
		return
	
	if user_is_stunned or user.ailment == Ailments.STUNNED and randf() > 0.67:
		print(user.name, " is stunned ...");
		user_is_stunned = true;
		return
	
	if user.ailment == Ailments.CONFUSED and randf() > 0.67 and !user_is_confused:
		action_type = ACTIONTYPE.ATTACK;
		target_type = TARGETTYPE.SINGLE_OPPONENT;
		targets.clear();
		targets = [battle_scene.get_random_opponent()];
		print(user.name, " is confused ...");
		user_is_confused = true;
	
	if user_is_confused:
		return
	
	match action_type:
		ACTIONTYPE.ATTACK:
			apply_art(user, targets[t_idx], user.default_attack);
		ACTIONTYPE.ART:
			if user.is_hero and !sp_adjusted:
				user.change_sp(-art.sp_cost);
				sp_adjusted = true;
			apply_art(user, targets[t_idx], art);
		ACTIONTYPE.ULT:
			if !ult_points_adjusted:
				user.ult_points = 0;
				user.update_display.emit();
				ult_points_adjusted = true;
			apply_art(user, targets[t_idx], user.ult_art);
		ACTIONTYPE.BLOCK:
			user.is_blocking = true;
			user.recieve_ult_points(16);
		ACTIONTYPE.ITEM:
			# consume item
			print("TODO: ACTION.ITEM");
		ACTIONTYPE.ANALYZE:
			var target := targets[t_idx];
			target.is_analyzed = true;
			if !GameData.analyzed_opponents.has(target.id):
				GameData.analyzed_opponents.append(target.id);
			battle_scene.battle_ui.prepare_after_analyze();
			await battle_scene.battle_ui.close_analyze;
	return


func apply_art(u: BattleData, t: BattleData, a: BattleArt) -> void:
	match a.category:
		a.CATEGORY.PHYSICAL, a.CATEGORY.ETHER, a.CATEGORY.SOULPOWER:
			var action_res := Calculations.calc_damage(u, t, a);
			battle_scene.battle_ui.create_damage_number(action_res, t, a);
			if !action_res.is_missed:
				apply_ult_points(u, t, action_res);
				var defeated := t.take_damage(action_res.damage);
				if defeated:
					battle_scene.on_character_defeated(t);
		
		a.CATEGORY.HEAL:
			var action_res := Calculations.calc_healing(u, a);
			battle_scene.battle_ui.create_damage_number(action_res, t, a);
			t.recieve_healing(action_res.healing);
			u.recieve_ult_points(4);
		
		a.CATEGORY.STRATEGY:
			u.recieve_ult_points(4);
		
		a.CATEGORY.AILMENT:
			var action_res := EffectApply.apply_ailment_art(u, t, a);
			battle_scene.battle_ui.create_damage_number(action_res, t, a);
			if !action_res.is_missed:
				u.recieve_ult_points(7);
	
	EffectApply.apply(u, t, a);
	return


func apply_ult_points(u: BattleData, t: BattleData, action_res: ActionResult) -> void:
	if action_res.attribute_multiplier == 0.0:
		t.recieve_ult_points(10);
		return
	
	var points: float = action_res.attribute_multiplier * 8.0;
	if action_res.is_crit:
		points *= 1.5;
	
	u.recieve_ult_points(roundi(points));
	return


func set_targettype(tt: TARGETTYPE) -> void:
	target_type = tt;
	init_target_index();
	return


func set_targettype_from_art(new_art: BattleArt) -> void:
	art = new_art;
	target_type = art.targeting as TARGETTYPE; # TODO match{} to make it safe
	init_target_index();
	return


func init_target_index() -> void:
	match target_type:
		TARGETTYPE.SINGLE_OPPONENT:
			index_target = 0;
			for oppo in battle_scene.opponents:
				if oppo != null:
					index_target = oppo.position;
					return
		TARGETTYPE.SINGLE_ALLY, TARGETTYPE.SELF_ONLY:
			index_target = battle_scene.cur_actor.position;
		TARGETTYPE.ALL_OPPONENTS:
			index_target = -1;
		TARGETTYPE.ALL_ALLIES:
			index_target = -2;
		TARGETTYPE.ALL:
			index_target = -3;
		TARGETTYPE.SINGLE_EVERYONE:
			index_target = 3; # 0-2 = heros, 3-7 = opponents;
			for oppo in battle_scene.opponents:
				if oppo != null:
					index_target = oppo.position + 3;
					return
		_:
			index_target = 0;
	return


func next_target() -> void:
	match target_type:
		TARGETTYPE.SINGLE_OPPONENT:
			while true:
				index_target += 1;
				if index_target >= battle_scene.opponents.size():
					index_target = 0;
				if battle_scene.opponents[index_target] != null:
					break;
		TARGETTYPE.SINGLE_ALLY:
			while true:
				index_target += 1;
				if index_target >= battle_scene.active_heros.size():
					index_target = 0;
				if battle_scene.active_heros[index_target] != null:
					break;
		TARGETTYPE.SINGLE_EVERYONE:
			while true:
				index_target += 1;
				if index_target < 3:
					if battle_scene.active_heros[index_target] != null:
						break;
				else:
					if index_target >= battle_scene.opponents.size() + 3:
						index_target = -1;
					elif battle_scene.opponents[index_target - 3] != null:
						break;
		TARGETTYPE.SELF_ONLY, TARGETTYPE.ALL_OPPONENTS, TARGETTYPE.ALL_ALLIES, TARGETTYPE.ALL:
			pass
		_:
			index_target = 0;
	return


func previous_target() -> void:
	match target_type:
		TARGETTYPE.SINGLE_OPPONENT:
			while true:
				index_target -= 1;
				if index_target < 0:
					index_target = battle_scene.opponents.size() - 1;
				if battle_scene.opponents[index_target] != null:
					break;
		TARGETTYPE.SINGLE_ALLY:
			while true:
				index_target -= 1;
				if index_target < 0:
					index_target = battle_scene.active_heros.size() - 1;
				if battle_scene.active_heros[index_target] != null:
					break;
		TARGETTYPE.SINGLE_EVERYONE:
			while true:
				index_target -= 1;
				if index_target < 3:
					if index_target < 0:
						index_target =  battle_scene.opponents.size() - 1 + 3;
					elif battle_scene.active_heros[index_target] != null:
						break;
				else:
					if battle_scene.opponents[index_target - 3] != null:
						break;
		TARGETTYPE.SELF_ONLY, TARGETTYPE.ALL_OPPONENTS, TARGETTYPE.ALL_ALLIES, TARGETTYPE.ALL:
			pass
		_:
			index_target = 0;
	return

# TODO: bad name lol
func select_random_target_as_opponent() -> void:
	match target_type:
		TARGETTYPE.SINGLE_OPPONENT:
			var possible_ids: PackedInt32Array = [];
			for hero in battle_scene.active_heros:
				if hero != null and !hero.is_defeated: 
					possible_ids.append(hero.position);
			index_target = possible_ids[randi_range(0, possible_ids.size() - 1)];
		
		TARGETTYPE.SINGLE_ALLY:
			var possible_ids: PackedInt32Array = [];
			for oppo in battle_scene.opponents:
				if oppo != null and !oppo.is_defeated: 
					possible_ids.append(oppo.position);
			index_target = possible_ids[randi_range(0, possible_ids.size() - 1)];
		
		TARGETTYPE.SINGLE_EVERYONE:
			# 0-2 = heros, 3-7 = opponents;
			var possible_ids: PackedInt32Array = [];
			for hero in battle_scene.active_heros:
				if hero != null and !hero.is_defeated: 
					possible_ids.append(hero.position);
			for oppo in battle_scene.opponents:
				if oppo != null and !oppo.is_defeated: 
					possible_ids.append(oppo.position + 3);
			index_target = possible_ids[randi_range(0, possible_ids.size() - 1)];
		
		_:
			pass; # index_target stays the same
	return


func is_inspect_action() -> bool:
	return action_type == ACTIONTYPE.INSPECT


func get_action_cast_path() -> String:
	var cast_path: String = "res://GameObjects/Battle/ActionCasts/";
	var default_cast: StringName = "res://GameObjects/Battle/ActionCasts/General/action_cast_default.tscn";
	match action_type:
		ACTIONTYPE.ATTACK:
			cast_path = default_cast;
		ACTIONTYPE.ART:
			cast_path += art.cast_path;
		ACTIONTYPE.ULT:
			cast_path += user.ult_art.cast_path;
		ACTIONTYPE.BLOCK:
			cast_path = default_cast;
		ACTIONTYPE.ITEM:
			cast_path = default_cast;
		ACTIONTYPE.ANALYZE:
			cast_path = default_cast;
		_:
			cast_path = default_cast;
	
	if !ResourceLoader.exists(cast_path):
		cast_path = default_cast;
	return cast_path


func get_multcast_allowed() -> bool:
	match action_type:
		ACTIONTYPE.ATTACK: return true
		ACTIONTYPE.ART: return !art.disable_multcast;
		ACTIONTYPE.ULT: return !user.ult_art.disable_multcast;
		ACTIONTYPE.BLOCK: return false
		ACTIONTYPE.ITEM: return true
		ACTIONTYPE.ANALYZE: return false
		_: return true


func get_action_name() -> String:
	match action_type:
		ACTIONTYPE.ATTACK: return "Attack";
		ACTIONTYPE.ART: return art.name;
		ACTIONTYPE.ULT: return user.ult_art.name;
		ACTIONTYPE.BLOCK: return "Block";
		ACTIONTYPE.ITEM: return "Item";
		ACTIONTYPE.ANALYZE: return "Analyze";
		_: return ""
