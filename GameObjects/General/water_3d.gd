class_name Water3D
extends StaticBody3D

@export var auto_height: bool = true;
@export var surface_height: float = 0.0;

func _ready() -> void:
	if auto_height:
		surface_height = global_position.y;
	return
