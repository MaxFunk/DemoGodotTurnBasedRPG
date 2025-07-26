class_name CharacterData
extends RefCounted

var id: int = -1;
var name: String = "???";
var level: int = 1;
var total_exp: int = 0;
var exp_to_lvl: int = 0;

# HP, SP, PhyAtt, PhyDef, EthAtt, EthDef, Luck, Agility
var base_stats: Array[int] = [7, 7, 7, 7, 7, 7, 7, 7];
var bonus_stats: Array[int] = [0, 0, 0, 0, 0, 0, 0, 0];
var accum_stats: Array[int] = [45, 31, 4, 4, 4, 4, 4, 4];

var cur_health: int = 1;
var cur_stamina: int = 1;

var attribute_weak: Array[int] = [];
var attribute_resist: Array[int] = [];
var attribute_block: Array[int] = [];

var art_ids: Array[int] = [-1, -1, -1, -1, -1, -1, -1];
var ult_id: int = -1;


func accumulate_stats() -> void:
	accum_stats[0] = Calculations.calc_hp_sp(base_stats[0], level, bonus_stats[0], true);
	accum_stats[1] = Calculations.calc_hp_sp(base_stats[1], level, bonus_stats[1], false);
	for i in range(2, 8):
		accum_stats[i] = Calculations.calc_stat(base_stats[i], level, bonus_stats[i]);
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
		"ult_id": ult_id
	};
	return save_dict
