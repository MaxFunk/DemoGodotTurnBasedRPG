@abstract
class_name Item extends RefCounted

var id: int = -1;
var name: String = "";
var description: String = "";
var amount: int = 0;
var item_type: int = -1; # 0 = Keyitem, 1 = Consumable, 2 = Material, 3 = Ingredient
var category_str: String = "";

var buy_value: int = -1;
var sell_value: int = -1;

@abstract
func get_category_name() -> StringName

@abstract
func get_detail_data() -> void

@abstract
func delete_items(delete_amount: int) -> bool

@abstract
func recieve_items(recieve_amount: int) -> bool
