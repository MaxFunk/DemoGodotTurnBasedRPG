extends StaticBody3D

@export var amount_dropped: int = 0;
@export var item_drops: Array[int] = [];
@export var item_probabilities: Array[float] = [];
@export var crystal_id: int = -1;

@onready var mesh_inst := $MeshInstance3D as MeshInstance3D;
@onready var interact_comp := $InteractionComponent as InteractionComponent;

var is_active: bool = true;


func _ready() -> void:
	if GameData.collected_crystals.has(crystal_id):
		deactivate_crystal();
	return


func _on_interaction_component_interaction() -> void:
	if !is_active:
		return
	
	deactivate_crystal();
	
	var chosen_item: PackedInt32Array = [];
	var chosen_item_amounts: PackedInt32Array = [];
	for i in amount_dropped:
		var item_id := choose_item();
		if chosen_item.has(item_id):
			chosen_item_amounts[chosen_item.find(item_id)] += 1;
		else:
			chosen_item.append(item_id);
			chosen_item_amounts.append(1);
	
	for i in chosen_item.size():
		GameData.recieve_items(1, chosen_item[i], chosen_item_amounts[i]);
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


func deactivate_crystal() -> void:
	is_active = false;
	if crystal_id >= 0 and GameData.collected_crystals.has(crystal_id) == false:
		GameData.collected_crystals.append(crystal_id);
	
	#var material := mesh_inst.get_surface_override_material(0) as ShaderMaterial;
	var material := mesh_inst.material_override as ShaderMaterial;
	material.set_shader_parameter("is_active", false);
	return


func _on_interaction_component_update_text() -> void:
	interact_comp.interaction_text = "Collect" if is_active else "";
	return
