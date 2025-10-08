class_name EnemyGroup extends Node3D

@export var enemy_ids: PackedInt32Array = [];

var enemy_chars: Array[EnemyCharacter] = [];


func _ready() -> void:
	for i in enemy_ids.size():
		var new_enemy_char := preload("res://GameObjects/Enemies/enemy_character.tscn").instantiate() as EnemyCharacter;
		new_enemy_char.position = get_spawn_offset(i);
		add_child(new_enemy_char);
		new_enemy_char.set_spawn_position();
		enemy_chars.append(new_enemy_char);
		new_enemy_char.enemy_group = self;
	return


func get_spawn_offset(i: int) -> Vector3:
	match i:
		0: return Vector3(0, 0, 0);
		1: return Vector3(1, 0, 0);
		2: return Vector3(0, 0, 1);
		3: return Vector3(-1, 0, 0);
		4: return Vector3(0, 0, -1);
		_: return Vector3(0, 0, 0);


func on_battle_finished() -> void:
	queue_free();
	return
