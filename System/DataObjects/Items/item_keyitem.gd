class_name ItemKeyitem extends Item

const data_table := preload("res://Resources/DataTables/item_keyitem_data.csv");

enum TYPE {STANDARD, KEY_SHARDS, SPECIAL}

var type := TYPE.STANDARD;
var is_visible: bool = false;


func _init(lookup_id: int, amount_value: int) -> void:
	item_type = 0;
	id = lookup_id;
	amount = amount_value;
	
	var data := data_table.records[id];
	name = data["name"];
	type = (data["type"] as int) as TYPE;
	description = data["description"];
	is_visible = (data["is_visible"] as int) as bool;
	
	category_str = get_category_name();
	return


func get_category_name() -> StringName:
	match type:
		0: return "Keyitem"
		1: return "Special Shard"
		2: return "Special"
		_: return "Unknown"


func get_detail_data() -> void:
	print("TODO")
	return


func delete_items(delete_amount: int) -> bool:
	amount -= delete_amount;
	if amount < 0: amount = 0; # failsafe
	GameData.item_keyitems[id] = amount;
	return amount <= 0


static func get_list_size() -> int:
	return data_table.records.size()
