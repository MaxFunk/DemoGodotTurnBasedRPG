class_name CharacterData
extends RefCounted

var id: int = -1;
var name: String = "???";
var level: int = 1;
var total_exp: int = 0;
var exp_to_lvl: int = 0;

# HP, SP, PhyAtt, PhyDef, EthAtt, EthDef, Luck, Agility
var base_stats: PackedInt32Array = [7, 7, 7, 7, 7, 7, 7, 7];
var bonus_stats: PackedInt32Array = [0, 0, 0, 0, 0, 0, 0, 0];
var accum_stats: PackedInt32Array = [45, 31, 4, 4, 4, 4, 4, 4];

var cur_health: int = 1;
var cur_stamina: int = 1;

var attribute_weak: PackedInt32Array = [];
var attribute_resist: PackedInt32Array = [];
var attribute_block: PackedInt32Array = [];

var art_ids: PackedInt32Array = [-1, -1, -1, -1, -1, -1, -1];
var learned_art_ids: PackedInt32Array = [];
var ult_id: int = -1;

var level_ups: int = 0;
var level_up_art_ids: PackedInt32Array = [];
var level_up_stats: PackedInt32Array = [0, 0, 0, 0, 0, 0, 0, 0];


func accumulate_stats() -> void:
	accum_stats[0] = Calculations.calc_hp_sp(base_stats[0], level, bonus_stats[0], true);
	accum_stats[1] = Calculations.calc_hp_sp(base_stats[1], level, bonus_stats[1], false);
	for i in range(2, 8):
		accum_stats[i] = Calculations.calc_stat(base_stats[i], level, bonus_stats[i]);
	return


func reciece_exp(rec_exp: int) -> bool:
	if level >= 99:
		return false
	
	total_exp = mini(total_exp + rec_exp, 99999);
	exp_to_lvl += rec_exp;
	
	var did_level_up: bool = false;
	var next_threshold := Calculations.get_exp_to_next_level(level + level_ups);
	while exp_to_lvl >= next_threshold:
		level_ups += 1;
		did_level_up = true;
		exp_to_lvl -= next_threshold;
		next_threshold = Calculations.get_exp_to_next_level(level + level_ups);
	
	return did_level_up


func apply_level_ups() -> void:
	if level_ups <= 0: 
		level_up_stats = [0, 0, 0, 0, 0, 0, 0, 0];
		return
	
	level_up_stats = accum_stats.duplicate();
	while level_ups > 0:
		level += 1;
		accumulate_stats();
		level_ups -= 1;
		var new_art_id: int = LevelUp.get_levelup_art(id, level);
		if new_art_id > 0:
			level_up_art_ids.append(new_art_id);
	
	for i in level_up_stats.size():
		level_up_stats[i] = accum_stats[i] - level_up_stats[i];
	
	cur_health += level_up_stats[0];
	cur_stamina += level_up_stats[1];
	#print(name, ": ", level_up_stats);
	#print(name, ": ", level_up_art_ids);
	return

# TODO: Learned_ids into save data
func learn_art(new_id: int, index: int) -> void:
	if art_ids[index] >= 0:
		learned_art_ids.append(art_ids[index]);
	art_ids[index] = new_id;
	return


func load_init_data(data: Dictionary) -> void:
	id = data["id"];
	name = data["name"];
	level = data["level"];
	total_exp = data["total_exp"];
	
	var basestat_data := (data["base_stats"] as String).split(",");
	for i in range(8):
		base_stats[i] = int(basestat_data[i]);
	
	accumulate_stats();
	cur_health = accum_stats[0];
	cur_stamina = accum_stats[1];
	
	var attr_weak_data := (data.get("attr_weak") as String).split(",");
	if attr_weak_data.get(0) != "":
		for i in range(attr_weak_data.size()):
			attribute_weak.append(int(attr_weak_data[i]));
		
	var attr_res_data := (data.get("attr_resist") as String).split(",");
	if attr_res_data.get(0) != "":
		for i in range(attr_res_data.size()):
			attribute_resist.append(int(attr_res_data[i]));
		
	var attr_block_data := (data.get("attr_block") as String).split(",");
	if attr_block_data.get(0) != "":
		for i in range(attr_block_data.size()):
			attribute_block.append(int(attr_block_data[i]));
	
	var art_data := (data["art_ids"] as String).split(",");
	for i in art_data.size():
		art_ids[i] = int(art_data[i]);
	ult_id = int(data["ult_id"]);
	return


func load_save_data(data: Dictionary) -> void:
	id = int(data["id"]);
	var charinit_table := preload("res://Resources/DataTables/char_data_init.csv").records;
	var init_data := charinit_table[id] as Dictionary;
	name = init_data["name"];
	var basestat_data := (init_data["base_stats"] as String).split(",");
	for i in range(8):
		base_stats[i] = int(basestat_data[i]);
	
	level = int(data["level"]);
	total_exp = int(data["total_exp"]);
	exp_to_lvl = int(data["exp_to_lvl"]);
	
	var bonus_data := data["bonus_stats"] as Array;
	for i in bonus_data.size():
		bonus_stats[i] = int(bonus_data[i]);
	
	var attr_weak_data := data["attr_weak"] as Array;
	for attr in attr_weak_data:
		attribute_weak.append(int(attr));
		
	var attr_resist_data := data["attr_resist"] as Array;
	for attr in attr_resist_data:
		attribute_resist.append(int(attr));
		
	var attr_block_data := data["attr_block"] as Array;
	for attr in attr_block_data:
		attribute_block.append(int(attr));
	
	cur_health = int(data["cur_health"]);
	cur_stamina = int(data["cur_stamina"]);
	accumulate_stats();
	
	var art_data := data["art_ids"] as Array;
	for i in art_data.size():
		art_ids[i] = int(art_data[i]);
		
	ult_id = int(data["ult_id"]);
	
	var learned_art_data := data["learned_art_ids"] as Array;
	for i in learned_art_data.size():
		learned_art_ids.append(int(learned_art_data[i]));
	return


func create_save_data() -> Dictionary[String, Variant]:
	var save_dict: Dictionary[String, Variant] = {
		"id": id,
		"level": level,
		"total_exp": total_exp,
		"exp_to_lvl": exp_to_lvl,
		"bonus_stats": bonus_stats,
		"cur_health": cur_health,
		"cur_stamina": cur_stamina,
		"attr_weak": attribute_weak,
		"attr_resist": attribute_resist,
		"attr_block": attribute_block,
		"art_ids": art_ids,
		"ult_id": ult_id,
		"learned_art_ids": learned_art_ids
	};
	return save_dict


func get_number_of_arts() -> int:
	var num_arts: int = 0;
	for art_id in art_ids:
		if art_id >= 0: num_arts += 1;
	return num_arts
