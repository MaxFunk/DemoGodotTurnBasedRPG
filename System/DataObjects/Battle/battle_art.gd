class_name BattleArt
extends RefCounted

enum CATEGORY {PHYSICAL = 0, ETHER = 1, HEAL = 2, STRATEGY = 3, AILMENT = 4, FIELD = 5, SOULPOWER = 6, PASSIVE = 7, NONE = 8}
enum TARGETING {SINGLE_OPPONENT = 0, SINGLE_ALLY = 1, SELF_ONLY = 2, ALL_OPPONENTS = 3, 
	ALL_ALLIES = 4, ALL = 5, SINGLE_EVERYONE = 6, NONE = 7}

var id: int = -1;
var name: String = "Art";
var cast_path: String = "";
var description: String = "";

var category := CATEGORY.NONE;
var targeting := TARGETING.NONE;

var base_power: int = 0;
var accuracy: int = 98;
var sp_cost: int = 0;
var hit_amount: int = 0;

var is_ult: bool = false;
var attribute_1: int = -1;
var attribute_2: int = -1;
var effects: PackedInt32Array = [];
var effect_values: PackedInt32Array = [];

var disable_multcast: bool = false;


func _init(call_id: int) -> void:
	if call_id < 0:
		init_default_art();
		return
	
	var data_row := preload("res://Resources/DataTables/arts.csv").records[call_id] as Dictionary;
	id = call_id;
	name = data_row["name"];
	cast_path = data_row["cast_path"];
	description = data_row["description"];
	
	category = int(data_row["category"]) as CATEGORY;
	targeting = int(data_row["targeting"]) as TARGETING;
	
	base_power = int(data_row["base_power"]);
	accuracy = int(data_row["accuracy"]);
	sp_cost = int(data_row["sp_cost"]);
	hit_amount = int(data_row["hit_amount"]);
	
	is_ult = bool(int(data_row["is_ult"]));
	attribute_1 = int(data_row["attr_1"]);
	attribute_2 = int(data_row["attr_2"]);
	
	var effect_ids := (data_row["effects"] as String).split(",");
	var effect_values_str := (data_row["effect_values"] as String).split(",");
	for i in range(effect_ids.size()):
		effects.append(int(effect_ids[i]));
		effect_values.append(int(effect_values_str[i]));
	
	if data_row["disable_multcast"] != "0":
		disable_multcast = true;
	return


func init_default_art() -> void:
	name = "Attack";
	#
	description = "Default Attack";
	category = CATEGORY.PHYSICAL;
	targeting = TARGETING.SINGLE_OPPONENT;
	base_power = 10;
	hit_amount = 1;
	return


func set_from_item(item: ItemConsumable) -> void:
	effects = item.effects.duplicate();
	effect_values = item.effect_values.duplicate();
	cast_path = item.cast_path;
	name = item.name;
	accuracy = 100;
	targeting = item.cast_targeting as TARGETING;
	match item.type:
		0, 1, 2: category = CATEGORY.HEAL;
		3: category = CATEGORY.STRATEGY;
		4: category = CATEGORY.AILMENT;
		5: category = CATEGORY.ETHER;
		_: category = CATEGORY.PASSIVE;
	return


func is_passive_art() -> bool:
	return category == CATEGORY.PASSIVE
