class_name ItemIngredient extends Item

const data_table := preload("res://Resources/DataTables/item_ingredient_data.csv");

enum TYPE {FRUITS, VEGETABLES, GRAINS, SPICES, SWEETS, LIQUIDS, OTHER}

var type := TYPE.FRUITS;


func _init(lookup_id: int, amount_value: int) -> void:
	item_type = 3;
	id = lookup_id;
	amount = amount_value;
	
	var data := data_table.records[id];
	name = data["name"];
	type = (data["type"] as int) as TYPE;
	description = data["description"];
	
	category_str = get_category_name();
	return


func get_category_name() -> StringName:
	match type:
		0: return "Fruits"
		1: return "Vegetables"
		2: return "Grains"
		3: return "Spices"
		4: return "Sweets"
		5: return "Liquids"
		6: return "Other"
		_: return "Unknown"


func get_detail_data() -> void:
	print("TODO")
	return


func delete_items(delete_amount: int) -> bool:
	amount -= delete_amount;
	if amount < 0: amount = 0; # failsafe
	GameData.item_ingredients[id] = amount;
	return amount <= 0


static func get_list_size() -> int:
	return data_table.records.size()
