class_name OpponentDecision


static func decide_action_standard(opponent: BattleData, scene: BattleScene) -> ActionData:
	var action := ActionData.new(ActionData.ACTIONTYPE.ATTACK, scene);
	var weights: PackedInt32Array = [];
	var targets: Array[BattleData] = [];
	
	for i in opponent.arts.size():
		var art_target := select_random_target(opponent.arts[i], opponent, scene);
		var art_weight := get_art_weight(opponent.arts[i], opponent, art_target);
		weights.append(art_weight);
		targets.append(art_target);
	
	var indices: PackedInt32Array = [];
	for i in weights.size():
		for j in weights[i]:
			indices.append(i);
	print(weights);
	var selected_index: int = -1;
	if indices.size() > 0:
		selected_index = indices[randi_range(0, indices.size() - 1)];
	
	if selected_index < 0: #randf() < 0.05:
		var random_target := select_random_target(opponent.default_attack, opponent, scene);
		action.action_type = ActionData.ACTIONTYPE.ATTACK;
		action.set_targettype_from_art(opponent.default_attack);
		action.set_target_index(random_target.position, random_target.is_hero);
	else:
		action.action_type = ActionData.ACTIONTYPE.ART;
		action.set_targettype_from_art(opponent.arts[selected_index]);
		action.set_target_index(targets[selected_index].position, targets[selected_index].is_hero);
	return action


static func get_art_weight(art: BattleArt, opponent: BattleData, target: BattleData) -> int:
	if art == null:
		return 0
	
	match art.category:
		art.CATEGORY.PHYSICAL, art.CATEGORY.ETHER, art.CATEGORY.SOULPOWER:
			if art.is_ult:
				# Maybe turn into x2 for below attr lookup
				return 8 if opponent.ult_points > art.cost else 0
			else:
				var attr: float = 1.0;
				attr *= Calculations.get_attribute_multiplier(target, art.attribute_1);
				attr *= Calculations.get_attribute_multiplier(target, art.attribute_2);
				if is_zero_approx(attr):
					return 1
				if attr < 1.0:
					return 3
				if attr > 1.0:
					return 6
				return 5
		art.CATEGORY.HEAL:
			var hp_percent: float = target.hp_cur / float(target.hp_max);
			return 3 if hp_percent < 0.35 else 0
		art.CATEGORY.AILMENT:
			return 5 if target.ailment == 0 else 0;
		art.CATEGORY.STRATEGY:
			return get_strategy_weight(art, target);
		#_: return 0
	return 0


static func get_strategy_weight(art: BattleArt, target: BattleData) -> int:
	var strategy_subcat := EffectIDs.strategy_art_subcategory(art);
	var modifiers := target.get_modifier_total();
	
	match strategy_subcat:
		1: # Buff Art
			if modifiers < -2:
				return 10
			if modifiers <= 0:
				return 4
		2: # Debuff Art
			if modifiers > 2:
				return 6
			if modifiers >= 0:
				return 4
	return 0


static func select_random_target(art: BattleArt, actor: BattleData, battle_scene: BattleScene) -> BattleData:
	if art == null:
		return null
	
	match art.targeting:
		art.TARGETING.SINGLE_OPPONENT, art.TARGETING.ALL_OPPONENTS:
			var valid_heros: Array[BattleData] = [];
			for hero in battle_scene.active_heros:
				if hero != null and !hero.is_defeated: 
					valid_heros.append(hero);
			return valid_heros[randi_range(0, valid_heros.size() - 1)];
		
		art.TARGETING.SINGLE_ALLY, art.TARGETING.ALL_ALLIES:
			var valid_oppos: Array[BattleData] = [];
			for oppo in battle_scene.opponents:
				if oppo != null and !oppo.is_defeated: 
					valid_oppos.append(oppo);
			return valid_oppos[randi_range(0, valid_oppos.size() - 1)];
		
		art.TARGETING.SINGLE_EVERYONE, art.TARGETING.SELF_ONLY:
			# 0-2 = heros, 3-7 = opponents;
			return actor; # TODO do not always return self lol?
		
		_:
			print("PROBLEM: No target for Art in Enemy Decission...")
	return null
