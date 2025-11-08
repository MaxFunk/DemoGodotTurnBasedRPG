class_name ItemConsumable extends Item

const data_table := preload("res://Resources/DataTables/item_consumable_data.csv");

enum TYPE {
	RESTORE_HP = 0, 
	RESTORE_SP = 1,
	RESTORE_AILMENT = 2,
	STRATEGY_SHARD = 3,
	AILMENT_SHARD = 4,
	DAMAGE_SHARD = 5,
	DISHES = 6,
	STAT_SHARD = 7,
	ART_SHARD = 8
	}

var type := TYPE.RESTORE_HP;

var battle_only: bool = false;
var menu_only: bool = false;
var used_on_all: bool = false;

var effects: PackedInt32Array = [];
var effect_values: PackedInt32Array = [];
var cast_path: String = "";
var cast_targeting: int = 0;


func _init(lookup_id: int, amount_value: int) -> void:
	item_type = 1;
	id = lookup_id;
	amount = amount_value;
	
	var data := data_table.records[id];
	name = str(data["name"]);
	type = int(str(data["type"])) as TYPE;
	battle_only = bool(int(str(data["battle_only"])));
	used_on_all = bool(int(str(data["on_all"])));
	description = str(data["description"]);
	cast_targeting = int(str(data["cast_targeting"]));
	cast_path = str(data["cast_path"]);
	buy_value = int(str(data["buy"]));
	sell_value = int(str(data["sell"]));
	
	category_str = get_category_name();
	
	var effect_ids := str(data["effect_ids"]).split(",");
	var effect_values_str := str(data["effect_values"]).split(",");
	for i in range(effect_ids.size()):
		effects.append(int(effect_ids[i]));
		effect_values.append(int(effect_values_str[i]));
	
	match type:
		TYPE.DISHES, TYPE.STAT_SHARD, TYPE.ART_SHARD: menu_only = true;
	return


func get_category_name() -> StringName:
	match type:
		0: return "Health Restore"
		1: return "Stamina Restore"
		2: return "Ailment Restore"
		3: return "Strategic Shard"
		4: return "Ailment Shard"
		5: return "Damaging Shard"
		6: return "Dish"
		7: return "Stat Shard"
		8: return "Art Shard"
		_: return "Unknown"


func get_detail_data() -> void:
	print("TODO")
	return


func delete_items(delete_amount: int) -> bool:
	amount -= delete_amount;
	if amount < 0: amount = 0; # failsafe
	GameData.item_consumables[id] = amount;
	return amount <= 0


func recieve_items(recieve_amount: int) -> bool:
	amount -= recieve_amount;
	if amount < 0: amount = 0; # failsafe
	GameData.item_consumables[id] += recieve_amount;
	return amount <= 0


static func get_list_size() -> int:
	return data_table.records.size()
