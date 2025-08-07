class_name Calculations
extends Node

const base_crit_chance: float = 5.0;


static func calc_stat(base: int, level: int, bonus: int) -> int:
	var min_val: float = ceilf(base * 0.5);
	var max_val: float = base * 10.0;
	var level_based: int = roundi((level - 1) * (max_val - min_val) / 98.0);
	var total: int = int(min_val) + level_based + bonus;
	return total


static func calc_hp_sp(base: int, level: int, bonus: int, is_hp: bool) -> int:
	var min_val: float = 10.0 + base * (5.0 if is_hp else 3.0);
	var max_val: float = (200.0 if is_hp else 120.0) + base * (40.0 if is_hp else 24.0);
	var level_based: int = roundi((level - 1) * (max_val - min_val) / 98.0);
	var total: int = int(min_val) + level_based + bonus;
	return total


static func get_exp_to_next_level(cur_level: int) -> int:
	var level: int = cur_level + 1;
	if level <= 1 or level > 99:
		return 0
	
	if level == 99:
		return 1513; # to round to 99999
	
	return level * 19 + 4 * floori(level / 3.0);


static func calc_damage(user: BattleData, target: BattleData, art: BattleArt) -> ActionResult:
	var is_crit: int = 0;
	var missed: int = 0;
	var attr: float = 1.0;
	var offense_val: float = get_offense_val(user, art);
	var defense_val: float = get_defense_val(target, art);
	
	if user.ailment == Ailments.BURNED:
		offense_val *= 0.7;
	if target.ailment == Ailments.FROZEN:
		defense_val *= 0.7;
	
	var damage: float = user.level * art.base_power * sqrt(offense_val / defense_val) / 20.0;
	damage += (100.0 - user.level) * art.base_power / 200.0; # Low Level Correction
	damage *= get_modifier(user.modifier[0]) / get_modifier(target.modifier[1]);
	
	attr *= get_attribute_multiplier(target, art.attribute_1);
	attr *= get_attribute_multiplier(target, art.attribute_2);
	damage *= attr;
	
	var accuracy: float = get_accuracy_val(user, target, art);
	var crit_chance: float = get_crit_chance(user, target, art);
	if randf() > accuracy:
		missed = 1;
	if randf() < crit_chance:
		is_crit = 1;
		damage *= 2.0;
	if target.is_blocking: damage *= 0.5;
	if user.is_charged: damage *= 2.0;
	
	damage *= randf_range(0.9, 1.1);
	var final_damage: int = clampi(roundi(damage), 1, 99999);
	if attr == 0.0:
		final_damage = 0;
	
	var action_res := ActionResult.new();
	action_res.damage = final_damage;
	action_res.is_missed = missed;
	action_res.is_crit = is_crit;
	action_res.attribute_multiplier = attr;
	return action_res


static func calc_healing(user: BattleData, art: BattleArt) -> ActionResult:
	var offense_val: float = maxf(user.stats[2], 1.0); # Gets Ether value
	var healing: float = sqrt(user.level * offense_val * art.base_power * 0.5);
	healing *= randf_range(0.9, 1.1);
	
	var action_res := ActionResult.new();
	action_res.healing = clampi(roundi(healing), 1, 99999);
	return action_res


static func get_offense_val(chd: BattleData, art: BattleArt) -> float:
	var value: float = 0;
	match art.category:
		art.CATEGORY.PHYSICAL: value = chd.stats[0];
		art.CATEGORY.ETHER, art.CATEGORY.HEAL: value = chd.stats[2];
		art.CATEGORY.SOULPOWER: value = chd.stats[0] + chd.stats[2];
	
	if chd.ailment == Ailments.CORRUPTED:
		value *= 1.5;
	if chd.ailment == Ailments.BLESSED:
		value *= 0.5;
	
	return maxf(value, 1.0);


static func get_defense_val(chd: BattleData, art: BattleArt) -> float:
	var value: float = 0;
	match art.category:
		art.CATEGORY.PHYSICAL: value = chd.stats[1];
		art.CATEGORY.ETHER: value = chd.stats[3];
		art.CATEGORY.SOULPOWER: value = floori(chd.stats[1] * 0.5 + chd.stats[3] * 0.5);
	
	if chd.ailment == Ailments.CORRUPTED:
		value *= 0.5;
	if chd.ailment == Ailments.BLESSED:
		value *= 1.5;
	
	return maxf(value, 1.0);


static func get_accuracy_val(user: BattleData, target: BattleData, art: BattleArt) -> float:
	var accuracy: float = art.accuracy / 100.0;
	accuracy *= get_modifier(user.modifier[2]) / get_modifier(target.modifier[2]);
	if user.ailment == Ailments.BLINDED:
		accuracy *= 0.8;
	return clampf(accuracy, 0.0, 1.0);


static func get_modifier(modifier: int) -> float:
	match modifier:
		-2: return 0.65;
		-1: return 0.85;
		1: return 1.15;
		2: return 1.35;
		_: return 1.0;


static func get_crit_chance(user: BattleData, target: BattleData, art: BattleArt) -> float:
	var base: float = base_crit_chance;
	for i in art.effects.size():
		if art.effects[i] == EffectIDs.HIGH_CRIT_CHANCE:
			base *= 4.0;
		if art.effects[i] == EffectIDs.LOW_CRIT_CHANCE:
			base *= 0.25;
	var crit_delta: float = user.stats[4] / float(target.stats[4]);
	var crit_chance: float = pow(base, sqrt(crit_delta)) / 100.0;
	return clampf(crit_chance, 0.0, 1.0);


static func get_attribute_multiplier(target: BattleData, attribute: int) -> float:
	if attribute < 0:
		return 1.0
	if target.attribute_block.has(attribute):
		return 0.0
	if target.attribute_resist.has(attribute):
		return 0.5
	if target.attribute_weak.has(attribute):
		return 2.0
	return 1.0
