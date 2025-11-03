class_name EnemyGroup extends Node3D

enum TASK {IDLE, WANDERING, GUARDING}

@export var group_task := TASK.IDLE;
@export var enemy_ids: PackedInt32Array = [];
@export var spawn_markers: Array[Marker3D] = [];
@export var music_id: int = 10;

var enemy_chars: Array[EnemyCharacter] = [];


func _ready() -> void:
	for i in enemy_ids.size():
		var new_enemy_char := preload("res://GameObjects/Enemies/enemy_character.tscn").instantiate() as EnemyCharacter;
		var spawn_marker: Marker3D = spawn_markers[i] if i < spawn_markers.size() else null;
		if spawn_marker == null:
			new_enemy_char.position = get_spawn_offset(i);
		set_chartask(new_enemy_char);
		add_child(new_enemy_char);
		new_enemy_char.set_spawn_position(spawn_marker);
		enemy_chars.append(new_enemy_char);
		new_enemy_char.enemy_group = self;
	return


func set_chartask(enemy_char: EnemyCharacter) -> void:
	match group_task:
		TASK.IDLE:
			enemy_char.char_task = enemy_char.CHARTASK.IDLE;
		TASK.WANDERING:
			enemy_char.char_task = enemy_char.CHARTASK.WANDERING;
		TASK.GUARDING:
			enemy_char.char_task = enemy_char.CHARTASK.GUARDING;
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
