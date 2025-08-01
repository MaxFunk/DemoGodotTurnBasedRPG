class_name BattleData
extends RefCounted

signal update_display()

var origin_data: CharacterData;
var battle_char: BattleCharacter;

var is_hero: bool = false;
var id: int = -1;
var name: String = "???";
var level: int = 99;
var position: int = 0; # works together with is_hero flag

var hp_max: int = 999;
var hp_cur: int = 999;
var sp_max: int = 999;
var sp_cur: int = 999;

# PhyAtt, PhyDef, EthAtt, EthDef, Luck, Agility
var stats: PackedInt32Array = [99, 99, 99, 99, 99, 99];
# Offense, Defense, Accuracy (+ Crit)
var modifier: PackedInt32Array = [0, 0, 0];
var modifier_timer: PackedInt32Array = [0, 0, 0];
var ailment: int = Ailments.NONE;
var ailment_turns: int = 0;

var attribute_weak: PackedInt32Array = [];
var attribute_resist: PackedInt32Array = [];
var attribute_block: PackedInt32Array = [];

var arts: Array[BattleArt] = [null, null, null, null, null, null, null];
var default_attack: BattleArt;
var ult_art: BattleArt = null;
var ult_points: int = 0;

var exp_on_defeat: int = 0;

var is_blocking: bool = false;
var is_charged: bool = false;
var is_defeated: bool = false;
var is_analyzed: bool = false;


func _init() -> void:
	default_attack = BattleArt.new(-1);
	return


func load_opponent_data(load_id: int) -> void:
	# TODO: Check if data is valid
	var data := ResourceManager.get_opponent_data(load_id);
	id = load_id;
	
	name = data.get("name");
	level = int(data.get("level"));
	hp_max = int(data.get("health"));
	hp_cur = hp_max;
	
	var stat_data := (data.get("stats") as String).split(",");
	for i in range(6):
		stats[i] = int(stat_data[i]);
	
	
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
	
	
	var art_data := (data.get("art_ids") as String).split(",");
	for i in range(min(7, art_data.size())):
		arts[i] = BattleArt.new(int(art_data[i]));
	
	var ult_id = int(data.get("ult_id"));
	if ult_id > 0:
		ult_art = BattleArt.new(ult_id);
	
	exp_on_defeat = int(data.get("exp_on_defeat"));
	is_analyzed = GameData.analyzed_opponents.has(load_id);
	return


func load_existing_chardata(char_data: CharacterData) -> void:
	origin_data = char_data;
	is_hero = true;
	is_analyzed = true;
	id = char_data.id;
	name = char_data.name;
	level = char_data.level;
	
	hp_max = char_data.accum_stats[0];
	hp_cur = char_data.cur_health;
	sp_max = char_data.accum_stats[1];
	sp_cur = char_data.cur_stamina;
	
	for i in range(6):
		stats[i] = char_data.accum_stats[i + 2];
	
	for i in range(7):
		if char_data.art_ids[i] >= 0:
			arts[i] = BattleArt.new(char_data.art_ids[i]);
	
	if char_data.ult_id >= 0:
		ult_art = BattleArt.new(char_data.ult_id);
	
	attribute_weak = char_data.attribute_weak.duplicate();
	attribute_resist = char_data.attribute_resist.duplicate();
	attribute_block = char_data.attribute_block.duplicate();
	return


func write_back_character_data() -> void:
	if origin_data == null: return
	
	origin_data.cur_health = hp_cur;
	origin_data.cur_stamina = sp_cur;
	return


func on_turn_begin() -> void:
	if is_blocking:
		is_blocking = false;
	
	for i in 3:
		if modifier_timer[i] > 0:
			modifier_timer[i] -= 1;
		if modifier_timer[i] == 0:
			modifier[i] = 0;
	
	if ailment != Ailments.NONE:
		if randf() <= Ailments.get_clear_chance(ailment_turns):
			ailment = Ailments.NONE;
			ailment_turns = 0;
			print(name, " cleared self of ailment");
		else:
			ailment_turns += 1;
	
	if ailment == Ailments.POISONED:
		hp_cur = maxi(hp_cur - floori(hp_max * 0.05), 1);
	
	update_display.emit();
	return


func on_turn_end() -> void:
	
	return


func get_max_arts() -> int:
	var ret_val: int = 0;
	for art in arts:
		if art != null: ret_val += 1;
	return ret_val

# Returns true if dead
func take_damage(damage: int) -> bool:
	hp_cur -= damage;
	if hp_cur <= 0:
		hp_cur = 0;
		modifier = [0, 0, 0];
		modifier_timer = [0, 0, 0];
		ailment = 0;
		ailment_turns = 0;
		ult_points = 0;
		is_blocking = false;
		is_charged = false;
		is_defeated = true;
		return true
	update_display.emit();
	return false


func recieve_healing(healing: int) -> void:
	hp_cur = mini(hp_cur + healing, hp_max);
	update_display.emit();
	return


func change_sp(value: int) -> void:
	if ailment == Ailments.EXHAUSTED:
		value *= 2;
	sp_cur = clampi(sp_cur + value, 0, sp_max);
	update_display.emit();
	return


func recieve_ult_points(value: int) -> void:
	ult_points = mini(ult_points + value, 100);
	update_display.emit();
	return
