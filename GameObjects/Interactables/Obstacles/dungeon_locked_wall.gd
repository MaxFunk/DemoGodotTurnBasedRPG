extends StaticBody3D

@export var required_keyitem_id: int = -1;
@export var interaction_comp: InteractionComponent = null;
@export var mesh_instance: MeshInstance3D = null;
@export var collision_shape: CollisionShape3D = null;


func _ready() -> void:
	if interaction_comp:
		interaction_comp.interaction.connect(on_interaction_event);
		interaction_comp.update_text.connect(on_interaction_update_text);
	return


func on_interaction_event() -> void:
	if required_keyitem_id < 0 or required_keyitem_id >= GameData.item_keyitems.size():
		return
	
	if GameData.item_keyitems[required_keyitem_id] > 0:
		GameData.item_keyitems[required_keyitem_id] -= 1;
		unlock_wall();
	else:
		print("REQUIRES A KEY TO OPEN THE LOCK");
	return


func on_interaction_update_text() -> void:
	if GameData.item_keyitems[required_keyitem_id] > 0:
		interaction_comp.interaction_text = "Unlock Door";
	else:
		interaction_comp.interaction_text = "Locked";
	return


func unlock_wall() -> void:
	# TODO: Play opening anim
	# disable coll shape when opened (on anim ended)
	
	interaction_comp.block_interaction = true;
	
	if mesh_instance:
		mesh_instance.visible = false;
	
	if collision_shape:
		collision_shape.disabled = true;
	return
