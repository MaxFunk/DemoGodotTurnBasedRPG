class_name ActionData
extends RefCounted

enum ACTIONTYPE {ATTACK = 0, ART = 1, ULT = 2, BLOCK = 3, ITEM = 4, TACTIC = 5}
enum TARGETTYPE {SINGLE_OPPONENT = 0, SINGLE_ALLY = 1, SELF_ONLY = 2, ALL_OPPONENTS = 3, 
	ALL_ALLIES = 4, ALL = 5, SPECIAL = 6, NONE = 7} # See BattleArt

var action_type := ACTIONTYPE.ATTACK;
var target_type := TARGETTYPE.SINGLE_OPPONENT;

var index_target: int = 0; # equals position, for All -> first 3 hero, then rest oppo
var battle_scene: BattleScene;
var art: BattleArt;

# Data filled after action was commited -> will not be modified afterwards
var user: BattleData;
var targets: Array[BattleData];


func _init(act_type: ACTIONTYPE, scene: BattleScene) -> void:
	action_type = act_type;
	battle_scene = scene;
	return


func commit_user_and_targets() -> void:
	user = battle_scene.cur_actor;
	
	if user.is_hero:
		match target_type:
			TARGETTYPE.SINGLE_OPPONENT:
				targets.append(battle_scene.opponents[index_target]);
			TARGETTYPE.SINGLE_ALLY, TARGETTYPE.SELF_ONLY:
				targets.append(battle_scene.active_heros[index_target]);
			TARGETTYPE.ALL_OPPONENTS:
				for oppo in battle_scene.opponents:
					if oppo != null: targets.append(oppo);
			TARGETTYPE.ALL_ALLIES:
				for hero in battle_scene.active_heros:
					if hero != null: targets.append(hero);
			TARGETTYPE.ALL:
				for hero in battle_scene.active_heros:
					if hero != null: targets.append(hero);
				for oppo in battle_scene.opponents:
					if oppo != null: targets.append(oppo);
			_:
				pass
	else:
		match target_type:
			TARGETTYPE.SINGLE_OPPONENT:
				targets.append(battle_scene.active_heros[index_target]);
			TARGETTYPE.SINGLE_ALLY, TARGETTYPE.SELF_ONLY:
				targets.append(battle_scene.opponents[index_target]);
			TARGETTYPE.ALL_OPPONENTS:
				for hero in battle_scene.active_heros:
					if hero != null: targets.append(hero);
			TARGETTYPE.ALL_ALLIES:
				for oppo in battle_scene.opponents:
					if oppo != null: targets.append(oppo);
			TARGETTYPE.ALL:
				for hero in battle_scene.active_heros:
					if hero != null: targets.append(hero);
				for oppo in battle_scene.opponents:
					if oppo != null: targets.append(oppo);
	return


func apply_action() -> void:
	if user.ailment == Ailments.STUNNED and randf() > 0.67:
		print(user.name, " is stunned ...");
		return
	
	if user.ailment == Ailments.CONFUSED and randf() > 0.67:
		action_type = ACTIONTYPE.ATTACK;
		var rand_idx: int = randi_range(0, battle_scene.opponents.size() - 1);
		targets = [battle_scene.opponents[rand_idx]];
		print(user.name, " is confused ...");
	
	match action_type:
		ACTIONTYPE.ATTACK:
			for target in targets:
				apply_art(user, target, user.default_attack);
		ACTIONTYPE.ART:
			if user.is_hero:
				user.change_sp(-art.sp_cost);
			for target in targets:
				apply_art(user, target, art);
		ACTIONTYPE.ULT:
			for target in targets:
				apply_art(user, target, user.ult_art);
			user.ult_points = 0;
			user.update_display.emit();
		ACTIONTYPE.BLOCK:
			user.is_blocking = true;
			user.recieve_ult_points(16);
		ACTIONTYPE.ITEM:
			# consume item
			print("TODO: ACTION.ITEM");
		ACTIONTYPE.TACTIC:
			print("TODO: ACTION.TACTIC");
	return


func apply_art(u: BattleData, t: BattleData, a: BattleArt) -> void:
	match a.category:
		a.CATEGORY.PHYSICAL, a.CATEGORY.ETHER, a.CATEGORY.SOULPOWER:
			var result := Calculations.calc_damage(u, t, a);
			if result.y <= 0:
				apply_ult_points(u, t, result.z, result.w);
				print(u.name, " used ",  a.name, " on ", t.name, " -> ", result);
				var defeated := t.take_damage(result.x);
				if defeated:
					battle_scene.on_character_defeated(t);
			else:
				print(u.name, " missed ",  a.name, " on ", t.name, " -> ", result);
		a.CATEGORY.HEAL:
			var heal := Calculations.calc_healing(u, a);
			t.recieve_healing(heal);
			u.recieve_ult_points(4);
			print(u.name, " used ",  a.name, " to heal ", t.name, " -> ", heal);
		a.CATEGORY.STRATEGY:
			u.recieve_ult_points(4);
			# EffectApply.apply(u, t, a);
		a.CATEGORY.AILMENT:
			var result := EffectApply.apply_ailment_art(u, t, a);
			if result:
				u.recieve_ult_points(7);
				print(u.name, " used ",  a.name, " on ", t.name);
			else:
				print(u.name, " missed ",  a.name, " on ", t.name);
	
	EffectApply.apply(u, t, a);
	return


func apply_ult_points(u: BattleData, t: BattleData, is_crit: bool, attribute_behavior: int) -> void:
	if attribute_behavior == 0:
		t.recieve_ult_points(5);
		return
	
	if is_crit:
		attribute_behavior = roundi(attribute_behavior * 1.5);
	
	u.recieve_ult_points(attribute_behavior);
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
		TARGETTYPE.SELF_ONLY, TARGETTYPE.ALL_OPPONENTS, TARGETTYPE.ALL_ALLIES, TARGETTYPE.ALL:
			pass
		_:
			index_target = 0;
	return
