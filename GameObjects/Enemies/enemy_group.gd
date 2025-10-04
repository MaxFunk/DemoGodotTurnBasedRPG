class_name EnemyGroup extends Node3D

@export var enemy_ids: PackedInt32Array = [];

var enemy_chars: Array[EnemyCharacter] = [];


func _ready() -> void:
	for i in enemy_ids.size():
		var new_enemy_char := preload("res://GameObjects/Enemies/enemy_character.tscn").instantiate() as EnemyCharacter;
		add_child(new_enemy_char);
		enemy_chars.append(new_enemy_char);
		new_enemy_char.enemy_group = self;
		new_enemy_char.position = get_spawn_pos(i);
	return


func get_spawn_pos(i: int) -> Vector3:
	match i:
		0: return Vector3(0, 0, 0);
		1: return Vector3(1, 0, 0);
		2: return Vector3(0, 0, 1);
		3: return Vector3(-1, 0, 0);
		4: return Vector3(0, 0, -1);
		_: return Vector3(0, 0, -2);


func on_battle_finished() -> void:
	queue_free();
	return
