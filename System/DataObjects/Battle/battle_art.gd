class_name BattleArt
extends RefCounted

enum CATEGORY {PHYSICAL = 0, ETHER = 1, HEAL = 2, STRATEGY = 3, AILMENT = 4, SOULPOWER = 5, PASSIVE = 6, NONE = 7}
enum TARGETING {SINGLE_OPPONENT = 0, SINGLE_ALLY = 1, SELF_ONLY = 2, ALL_OPPONENTS = 3, 
	ALL_ALLIES = 4, ALL = 5, SPECIAL = 6, NONE = 7}

var id: int = -1;
var name: String = "Art";
var anim_path: StringName = "";
var description: String = "";

var category := CATEGORY.NONE;
var targeting := TARGETING.NONE;

var base_power: int = 0;
var accuracy: int = 98;
var sp_cost: int = 0;
var hit_amount: int = 0;

var is_ult: bool = false;
# var effects .. 

func _init(call_id: int) -> void:
	var data_row := preload("res://Resources/DataTables/arts.csv").records[call_id] as Dictionary;
	id = call_id;
	name = data_row["name"];
	anim_path = data_row["anim_path"];
	description = data_row["description"];
	
	category = int(data_row["category"]) as CATEGORY;
	targeting = int(data_row["targeting"]) as TARGETING;
	
	base_power = int(data_row["base_power"]);
	accuracy = int(data_row["accuracy"]);
	sp_cost = int(data_row["sp_cost"]);
	hit_amount = int(data_row["hit_amount"]);
	
	is_ult = bool(int(data_row["is_ult"]));
	return
