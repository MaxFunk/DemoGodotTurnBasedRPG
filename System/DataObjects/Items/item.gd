@abstract
class_name Item extends RefCounted

var id: int = -1;
var name: String = "";
var description: String = "";
var amount: int = 0;
var category_str: String = "";

@abstract
func get_category_name() -> StringName

@abstract
func get_detail_data() -> void

@abstract
func delete_items(delete_amount: int) -> bool
