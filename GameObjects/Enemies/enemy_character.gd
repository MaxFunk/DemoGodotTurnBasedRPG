class_name EnemyCharacter
extends CharacterBody3D

@onready var nav_agent := $NavigationAgent3D as NavigationAgent3D;

var model_3d: Model3D;
var enemy_group: EnemyGroup;


func _ready() -> void:
	var packed_model: PackedScene = preload("res://Resources/Models/Enemies/sentinel_drone.glb");
	model_3d = packed_model.instantiate() as Model3D;
	add_child(model_3d);
	model_3d.play_animation("Idle");
	return
