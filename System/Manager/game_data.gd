extends Node

var main_scene: MainScene;
var cur_savefile_slot: int = -1;
var game_running: bool = false;

var world_scene_id: int = -1;
var money: int = 0;
var date_id: int = 0;
var playtime: float = 0.0;

var characters: Array[CharacterData] = [null, null, null, null, null, null, null, null];
var active_party: Array[int] = [-1, -1, -1];
var backup_party: Array[int] = [];
var inaccessable: Array[int] = [];


func _ready() -> void:
	#for i in range(3):
	#	add_new_chardata(i);
	
	#var total: int = 0;
	#for i in range(99):
	#	var cur: int = Calculations.get_exp_to_next_level(i);
	#	total += cur;
	#	print(i + 1, ": ", total, " ", cur);
	return


func _process(delta: float):
	if game_running:
		playtime += delta;
	return


func game_instance_reset() -> void:
	game_running = false;
	cur_savefile_slot = -1;
	
	money = 0;
	date_id = 0;
	playtime = 0.0;
	
	characters.clear();
	active_party.clear();
	backup_party.clear();
	inaccessable.clear();
	return


func save_game_data() -> Dictionary[String, Variant]:
	var char_dict: Array[Dictionary] = [];
	for i in range(8):
		if characters[i] != null:
			char_dict.append(characters[i].create_save_data());
	
	var save_dict: Dictionary[String, Variant] = {
		"worldscene_id": world_scene_id,
		"playtime": int(min(playtime, 3599999.0)),
		"date": date_id,
		"money": money,
		"party": {
			"active_party": active_party,
			"backup_party": backup_party,
			"inaccessable": inaccessable
			},
		"characters": char_dict,
	};
	return save_dict


func load_existing_game_data(data: Dictionary, save_slot: int) -> void:
	# General stuff
	playtime = float(data["playtime"]);
	date_id = data["date"];
	money = data["money"];
	
	# Party
	var party_data := data["party"] as Dictionary;
	active_party.clear();
	for i in party_data["active_party"]:
		active_party.append(int(i));
	backup_party.clear();
	for i in party_data["backup_party"]:
		backup_party.append(int(i));
	inaccessable.clear();
	for i in party_data["inaccessable"]:
		inaccessable.append(int(i));
	
	for char_dict in data["characters"] as Array:
		var chd := CharacterData.new();
		chd.load_save_data(char_dict as Dictionary);
		characters[chd.id] = chd;
	
	cur_savefile_slot = save_slot;
	game_running = true;
	main_scene.load_world(data["worldscene_id"]);
	return


func load_new_game_data(save_slot: int) -> void:
	game_instance_reset(); # maybe optional
	
	game_running = true;
	cur_savefile_slot = save_slot;
	main_scene.load_world(999);
	return


func add_new_chardata(id: int) -> void:
	var charinit_table := preload("res://Resources/DataTables/char_data_init.csv").records;
	var char_data := charinit_table[id] as Dictionary;
	var new_char := CharacterData.new();
	new_char.load_init_data(char_data);
	characters[id] = new_char;
	
	for i in range(3):
		if active_party[i] < 0:
			active_party[i] = new_char.id;
			return
	backup_party.append(new_char.id);
	return


func get_characters_only(char_array: Array[CharacterData]) -> void:
	for ch in characters:
		if ch:
			char_array.append(ch);
	return


func get_first_free_party_slot() -> int:
	for i in range(3):
		if active_party[i] < 0:
			return i
	return -1


func return_to_titlescreen() -> void:
	main_scene.close_ingame_menu();
	main_scene.load_world(1);
	game_instance_reset();
	return
