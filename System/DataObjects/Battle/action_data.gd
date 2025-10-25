class_name ActionData extends RefCounted

signal finished_casting();

enum ACTIONTYPE {ATTACK = 0, ART = 1, BLOCK = 2, ITEM = 3, INSPECT = 4, ANALYZE = 5}
enum TARGETTYPE {SINGLE_OPPONENT = 0, SINGLE_ALLY = 1, SELF_ONLY = 2, ALL_OPPONENTS = 3, 
	ALL_ALLIES = 4, ALL = 5, SINGLE_EVERYONE = 6, NONE = 7} # See BattleArt

var action_type := ACTIONTYPE.ATTACK;
var target_type := TARGETTYPE.SINGLE_OPPONENT;

var index_target: int = 0; # equals position, for All -> first 3 hero, then rest oppo
var battle_scene: BattleScene;
var art: BattleArt;
var item: ItemConsumable;

# Data filled after action was commited -> will not be modified afterwards
var user: BattleData;
var targets: Array[BattleData];

var action_casts: Array[ActionCast] = [];

var check_casts: bool = false;
var ult_points_adjusted: bool = false;


func _init(act_type: ACTIONTYPE, scene: BattleScene) -> void:
	action_type = act_type;
	battle_scene = scene;
	user = battle_scene.cur_actor;
	return


func process() -> void:
	if check_casts:
		var all_casts_finished: bool = true;
		for cast in action_casts:
			if !cast.is_finished:
				all_casts_finished = false;
		if all_casts_finished:
			check_casts = false;
			finished_casting.emit();
	return


func commit_targets() -> void:
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


func check_user_can_cast() -> bool:
	if user.ailment == Ailments.STUNNED and randf() < 0.33:
		print(user.name, " is stunned ...");
		return false
	
	if user.ailment == Ailments.CONFUSED and randf() < 0.5:
		action_type = ACTIONTYPE.ATTACK;
		target_type = TARGETTYPE.SINGLE_OPPONENT;
		targets.clear();
		targets = [battle_scene.get_random_opponent()];
		print(user.name, " is confused ...");
	return true


func apply_action_cost() -> void:
	if action_type == ACTIONTYPE.ART:
		if art.is_ult:
			user.change_ult_points(-art.cost);
		else:
			if user.is_hero:
				user.change_sp(-art.cost);
	elif action_type == ACTIONTYPE.ITEM:
		if item: # unnecessary check?
			item.delete_items(1);
	return


func cast_action() -> void:
	var action_cast_scene := load(get_action_cast_path()) as PackedScene;
	
	battle_scene.battle_ui.lbl_action_name.text = get_action_name();
	battle_scene.battle_ui.lbl_action_name.visible = true;
	
	user.battle_char.play_anim(get_model_anim_name());
	
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
	
	match action_type:
		ACTIONTYPE.ATTACK:
			await apply_art(user, targets[t_idx], user.default_attack);
		ACTIONTYPE.ART:
			await apply_art(user, targets[t_idx], art);
		ACTIONTYPE.BLOCK:
			user.is_blocking = true;
			user.change_ult_points(16);
		ACTIONTYPE.ITEM:
			await apply_item(user, targets[t_idx], item);
		ACTIONTYPE.ANALYZE:
			var target := targets[t_idx];
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
					await battle_scene.on_character_defeated(t);
					return
		
		a.CATEGORY.HEAL:
			var action_res := Calculations.calc_healing(u, a);
			battle_scene.battle_ui.create_damage_number(action_res, t, a);
			t.recieve_healing(action_res.healing);
			u.change_ult_points(4);
		
		a.CATEGORY.STRATEGY:
			u.change_ult_points(4);
		
		a.CATEGORY.AILMENT:
			var action_res := EffectApply.apply_ailment_art(u, t, a);
			battle_scene.battle_ui.create_damage_number(action_res, t, a);
			if !action_res.is_missed:
				u.change_ult_points(7);
		
		a.CATEGORY.FIELD:
			battle_scene.create_field(a, u);
			u.change_ult_points(5);
	
	EffectApply.apply(u, t, a);
	return


func apply_item(u: BattleData, t: BattleData, i: ItemConsumable) -> void:
	var item_art := BattleArt.new(-1);
	item_art.set_from_item(i);
	var action_res := ActionResult.new();
	
	match i.type:
		0: # Restore HP
			if i.effects[0] == EffectIDs.ITEM_RESTORE_PERCENT:
				var percent_hp := t.hp_max * i.effect_values[0] / 100.0;
				action_res.healing = ceili(percent_hp);
			else:
				action_res.healing = i.effect_values[0];
			battle_scene.battle_ui.create_damage_number(action_res, t, item_art);
			t.recieve_healing(action_res.healing);
		
		1: # Restore SP
			if i.effects[0] == EffectIDs.ITEM_RESTORE_PERCENT:
				var percent_sp := t.sp_max * i.effect_values[0] / 100.0;
				action_res.healing = ceili(percent_sp);
			else:
				action_res.healing = i.effect_values[0];
			battle_scene.battle_ui.create_damage_number(action_res, t, item_art);
			t.change_sp(action_res.healing);
		
		5: # Damaging Shard/Item
			if i.effects[0] == EffectIDs.ITEM_DAMAGE:
				action_res.damage = i.effect_values[0];
				battle_scene.battle_ui.create_damage_number(action_res, t, item_art);
				var defeated := t.take_damage(action_res.damage);
				if defeated:
					await battle_scene.on_character_defeated(t);
		
		_:
			EffectApply.apply(u, t, item_art);
	
	u.change_ult_points(5);
	return


func apply_ult_points(u: BattleData, t: BattleData, action_res: ActionResult) -> void:
	if action_res.attribute_multiplier == 0.0:
		t.change_ult_points(10);
		return
	
	var points: float = action_res.attribute_multiplier * 8.0;
	if action_res.is_crit:
		points *= 1.5;
	
	u.change_ult_points(roundi(points));
	return


func set_targettype(tt: TARGETTYPE) -> void:
	target_type = tt;
	init_target_index();
	return


func set_targettype_from_art(new_art: BattleArt) -> void:
	art = new_art;
	target_type = int(art.targeting) as TARGETTYPE;
	init_target_index();
	return


func set_targettype_from_item(new_item: ItemConsumable) -> void:
	item = new_item;
	target_type = item.cast_targeting as TARGETTYPE;
	init_target_index();
	return


func init_target_index() -> void:
	match target_type:
		TARGETTYPE.SINGLE_OPPONENT:
			index_target = 0;
			for oppo in battle_scene.opponents:
				if oppo != null:
					index_target = oppo.position - 3;
					return
		TARGETTYPE.SINGLE_ALLY, TARGETTYPE.SELF_ONLY:
			index_target = user.position if user.is_hero else user.position - 3;
		TARGETTYPE.ALL_OPPONENTS:
			index_target = -1;
		TARGETTYPE.ALL_ALLIES:
			index_target = -2;
		TARGETTYPE.ALL:
			index_target = -3;
		TARGETTYPE.SINGLE_EVERYONE:
			index_target = 0; # 0-2 = heros, 3-7 = opponents;
			for oppo in battle_scene.opponents:
				if oppo != null:
					index_target = oppo.position - 3;
					return
		_:
			index_target = 0;
	return


func next_target_index(dir: int) -> void:
	match target_type:
		TARGETTYPE.SINGLE_OPPONENT:
			while true:
				index_target += dir;
				if index_target < 0:
					index_target = 4;
				if index_target >= 5:
					index_target = 0;
				if battle_scene.opponents[index_target] != null:
					break;
		
		TARGETTYPE.SINGLE_ALLY:
			while true:
				index_target += dir;
				if index_target < 0:
					index_target = 2;
				if index_target >= 3:
					index_target = 0;
				if battle_scene.active_heros[index_target] != null:
					break;
		
		TARGETTYPE.SINGLE_EVERYONE:
			while true:
				index_target += dir;
				if index_target < 0:
					index_target = 7;
				if index_target >= 8:
					index_target = 0;
				if index_target < 3:
					if battle_scene.active_heros[index_target] != null:
						break;
				else:
					if battle_scene.opponents[index_target - 3] != null:
						break;
		
		TARGETTYPE.SELF_ONLY, TARGETTYPE.ALL_OPPONENTS, TARGETTYPE.ALL_ALLIES, TARGETTYPE.ALL:
			pass
		_:
			index_target = 0;
	return


func set_target_index(index: int, is_hero: bool) -> void:
	match target_type:
		TARGETTYPE.SINGLE_OPPONENT, TARGETTYPE.SINGLE_ALLY, TARGETTYPE.SINGLE_EVERYONE:
			index_target = index if is_hero else index - 3;
		
		TARGETTYPE.SELF_ONLY, TARGETTYPE.ALL_OPPONENTS, TARGETTYPE.ALL_ALLIES, TARGETTYPE.ALL:
			return
		_:
			index_target = 0;
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
		ACTIONTYPE.BLOCK:
			cast_path = "res://GameObjects/Battle/ActionCasts/General/action_cast_block.tscn";
		ACTIONTYPE.ITEM:
			cast_path += item.cast_path;
		ACTIONTYPE.ANALYZE:
			cast_path = default_cast;
		_:
			cast_path = default_cast;
	
	if !ResourceLoader.exists(cast_path):
		cast_path = default_cast;
	return cast_path


func get_model_anim_name() -> String:
	if user.is_hero == false:
		return "CastEther"
	
	match action_type:
		ACTIONTYPE.ATTACK:
			return "BattleAttack"
		ACTIONTYPE.ART:
			if art.category == art.CATEGORY.PHYSICAL:
				return "BattlePhysicalArt"
			return "BattleEtherArt"
		ACTIONTYPE.BLOCK:
			return "BattleBlock"
		ACTIONTYPE.ITEM, ACTIONTYPE.ANALYZE:
			return "BattleEtherArt"
	return ""


func get_multcast_allowed() -> bool:
	match action_type:
		ACTIONTYPE.ATTACK: return true
		ACTIONTYPE.ART: return !art.disable_multcast;
		ACTIONTYPE.BLOCK: return false
		ACTIONTYPE.ITEM: return true
		ACTIONTYPE.ANALYZE: return false
		_: return true


func get_action_name() -> String:
	match action_type:
		ACTIONTYPE.ATTACK: return "Attack";
		ACTIONTYPE.ART: return art.name;
		ACTIONTYPE.BLOCK: return "Block";
		ACTIONTYPE.ITEM: return item.name;
		ACTIONTYPE.ANALYZE: return "Analyze";
		_: return ""
