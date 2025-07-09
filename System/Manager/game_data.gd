extends Node

var main_scene: MainScene;
var cur_savefile_slot: int = -1;
var game_running: bool = false;

var world_scene_id: int = -1;
var money: int = 0;
var date_id: int = 0;
var playtime: float = 0.0;


func _process(delta):
	if game_running:
		playtime += delta;
	return


func game_instance_reset() -> void:
	game_running = false;
	cur_savefile_slot = -1;
	
	money = 0;
	date_id = 0;
	playtime = 0.0;
	return
