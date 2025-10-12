class_name ItemMaterial extends Item

const data_table := preload("res://Resources/DataTables/item_material_data.csv");

enum TYPE {MATERIAL, OTHERS}

var type := TYPE.MATERIAL;


func _init(lookup_id: int, amount_value: int) -> void:
	item_type = 2;
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
		0: return "Material"
		_: return "Unknown"


func get_detail_data() -> void:
	print("TODO")
	return


func delete_items(delete_amount: int) -> bool:
	amount -= delete_amount;
	if amount < 0: amount = 0; # failsafe
	GameData.item_materials[id] = amount;
	return amount <= 0


static func get_list_size() -> int:
	return data_table.records.size()
