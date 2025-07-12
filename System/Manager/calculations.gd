class_name Calculations
extends Node


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
	if level <= 1:
		return 0
	
	if level >= 99:
		return 1513; # to round to 99999
	
	return level * 19 + 4 * floori(level / 3.0);
