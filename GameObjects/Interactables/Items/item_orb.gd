extends Area3D

enum ITEMTYPE {KEYITEM, CONSUMABLE, MATERIAL, INGREDIENT}

@export var item_type := ITEMTYPE.CONSUMABLE;
@export var item_drops: Array[int] = [];
@export var item_probabilities: Array[float] = [];


func _on_body_entered(body: Node3D) -> void:
	if body is PlayerCharacter:
		var item_id := choose_item();
		if item_id >= 0:
			GameData.recieve_items(get_catergory_id(), item_id, 1);
			queue_free();
	return


func choose_item() -> int:
	if item_drops.size() != item_probabilities.size():
		return -1
	if item_drops.size() == 0 or item_probabilities.size() == 0:
		return -1
	
	var rand_num := randf();
	var prob_total: float = 0.0;
	for i in item_drops.size():
		prob_total += item_probabilities[i];
		if rand_num <= prob_total:
			return item_drops[i];
	return -1


func get_catergory_id() -> int:
	match item_type:
		ITEMTYPE.KEYITEM: return 0
		ITEMTYPE.CONSUMABLE: return 1
		ITEMTYPE.MATERIAL: return 2
		ITEMTYPE.INGREDIENT: return 3
	return 1
