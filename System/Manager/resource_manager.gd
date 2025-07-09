extends Node


func get_hero_model(id: int) -> PackedScene:
	match id:
		0: return preload("res://Resources/Models/Heros/hero_M.glb");
		1: return preload("res://Resources/Models/Heros/hero_A.glb");
		_: return preload("res://Resources/Models/Heros/hero_E.glb");
