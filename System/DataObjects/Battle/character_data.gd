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

var art_ids: Array[int] = [-1, -1, -1, -1, -1, -1, -1, -1];
var ultart_id: int = -1;


func accumulate_stats() -> void:
	accum_stats[0] = Calculations.calc_hp_sp(base_stats[0], level, bonus_stats[0], true);
	accum_stats[1] = Calculations.calc_hp_sp(base_stats[1], level, bonus_stats[1], false);
	for i in range(2, 8):
		accum_stats[i] = Calculations.calc_stat(base_stats[i], level, bonus_stats[i]);
	
	# TODO Cur HP, SP:
	cur_health = accum_stats[0];
	cur_stamina = accum_stats[1];
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
	return


func load_save_data() -> void:
	print("TODO character_data.gd::load_save_data()");
	return
