extends StaticBody3D

@export var interaction_comp: InteractionComponent = null;
@export var mesh_instance: MeshInstance3D = null;
@export var collision_shape: CollisionShape3D = null;


func _ready() -> void:
	if interaction_comp:
		interaction_comp.interaction.connect(on_interaction_event);
	return


func on_interaction_event() -> void:
	if mesh_instance:
		mesh_instance.visible = false;
	
	if collision_shape:
		collision_shape.disabled = true;
	return
