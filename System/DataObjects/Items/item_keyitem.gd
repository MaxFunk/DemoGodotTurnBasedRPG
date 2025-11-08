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
	name = str(data["name"]);
	type = int(str(data["type"])) as TYPE;
	description = str(data["description"]);
	is_visible = bool(int(str(data["is_visible"])));
	
	category_str = get_category_name();
	return


func get_category_name() -> StringName:
	match type:
		0: return "Key Item"
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


func recieve_items(recieve_amount: int) -> bool:
	amount -= recieve_amount;
	if amount < 0: amount = 0; # failsafe
	GameData.item_keyitems[id] += recieve_amount;
	return amount <= 0


static func get_list_size() -> int:
	return data_table.records.size()
