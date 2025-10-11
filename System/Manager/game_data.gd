extends Node

var main_scene: MainScene;
var cur_savefile_slot: int = -1;
var game_running: bool = false;

var world_scene_id: int = -1;
var money: int = 0;
var date_id: int = 0;
var playtime: float = 0.0;

var characters: Array[CharacterData] = [null, null, null, null, null, null, null, null];
var active_party: PackedInt32Array = [-1, -1, -1];
var backup_party: PackedInt32Array = [];
var inaccessable: PackedInt32Array = [];

var analyzed_opponents: PackedInt32Array = [];
var collected_crystals: PackedInt32Array = [];

var item_keyitems: PackedInt32Array = [];
var item_consumables: PackedInt32Array = [];
var item_materials: PackedInt32Array = [];
var item_ingredients: PackedInt32Array = [];




func _ready() -> void:
	#for i in range(3):
	#	add_new_chardata(i);
	
	#var total: int = 0;
	#for i in range(99):
		#var cur: int = Calculations.get_exp_to_next_level(i);
		#total += cur;
		#print(i + 1, ": ", total, " ", cur);
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
	characters = [null, null, null, null, null, null, null, null];
	
	active_party = [-1, -1, -1];
	backup_party.clear();
	inaccessable.clear();
	
	collected_crystals.clear();
	analyzed_opponents.clear();
	reset_item_data();
	return


func save_game_data() -> Dictionary[String, Variant]:
	var player_valid := main_scene.player_char != null;
	
	var char_dict: Array[Dictionary] = [];
	for i in range(8):
		if characters[i] != null:
			char_dict.append(characters[i].create_save_data());
	
	var save_dict: Dictionary[String, Variant] = {
		"worldscene_id": world_scene_id,
		"playtime": int(min(playtime, 3599999.0)),
		"date": date_id,
		"money": money,
		"player": {
			"player_valid": player_valid,
			"player_pos": main_scene.player_char.global_position if player_valid else Vector3.ZERO,
			"player_rot": main_scene.player_char.global_rotation if player_valid else Vector3.ZERO,
			},
		"party": {
			"active_party": active_party,
			"backup_party": backup_party,
			"inaccessable": inaccessable
			},
		"characters": char_dict,
		
		"analyzed_opponents": analyzed_opponents,
		"collected_crystals": collected_crystals,
		
		"items_keyitems": item_keyitems,
		"items_consumables": item_consumables,
		"items_materials": item_materials,
		"items_ingredients": item_ingredients,
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
	
	for analyzed_id in data["analyzed_opponents"] as Array:
		analyzed_opponents.append(int(analyzed_id));
	for crystals_id in data["collected_crystals"] as Array:
		collected_crystals.append(int(crystals_id));
	
	reset_item_data(); # ? unnecessary ?
	var item_data_k := data["items_keyitems"] as Array;
	for i in item_data_k.size():
		item_keyitems[i] = int(item_data_k[i]);
	var item_data_c := data["items_consumables"] as Array;
	for i in item_data_c.size():
		item_consumables[i] = int(item_data_c[i]);
	var item_data_m := data["items_materials"] as Array;
	for i in item_data_m.size():
		item_materials[i] = int(item_data_m[i]);
	var item_data_i := data["items_ingredients"] as Array;
	for i in item_data_i.size():
		item_ingredients[i] = int(item_data_i[i]);
	
	cur_savefile_slot = save_slot;
	game_running = true;
	main_scene.load_world(data["worldscene_id"]);
	
	var player_data := data["player"] as Dictionary;
	if player_data["player_valid"] as bool == true:
		main_scene.load_player_transform(player_data["player_pos"], player_data["player_rot"]);
	return


func load_new_game_data(save_slot: int) -> void:
	game_instance_reset(); # maybe optional
	# reset_item_data(); if above is removed
	
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
	main_scene.end_battle_scene();
	main_scene.close_ingame_menu();
	main_scene.load_world(1);
	game_instance_reset();
	return


func reload_savefile() -> void:
	main_scene.end_battle_scene();
	main_scene.close_ingame_menu();
	var load_slot: int = GameData.cur_savefile_slot;
	game_instance_reset();
	SaveFileManager.load_from_file(load_slot);
	return


func reset_item_data() -> void:
	item_keyitems.clear();
	item_keyitems.resize(ItemKeyitem.get_list_size());
	
	item_consumables.clear();
	item_consumables.resize(ItemConsumable.get_list_size());
	
	item_materials.clear();
	item_materials.resize(ItemMaterial.get_list_size());
	
	item_ingredients.clear();
	item_ingredients.resize(ItemIngredient.get_list_size());
	return
