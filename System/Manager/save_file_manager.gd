extends Node

const user_dir: StringName = "user://"
const file_dir: StringName = "user://savefiles";
const filepath: StringName = "user://savefiles/savefile_";
const filetype: StringName = ".save";
const managerfile: StringName = "user://savefiles/manager.save";

var manager_dict: Dictionary;


func _ready() -> void:
	var file := FileAccess.open(managerfile, FileAccess.READ);
	if file == null:
		create_manager_file();
		file = FileAccess.open(managerfile, FileAccess.READ);
	read_manager_file();
	file.close();
	return


func create_manager_file() -> void:
	# "{LocationID},{DateID},{PlaytimeInSeconds}"
	var save_dict: Dictionary[String, Variant] = {
		"slot_0": "",
		"slot_1": "",
		"slot_2": "",
		"slot_3": "",
		"slot_4": "",
		"slot_5": "",
		"slot_6": "",
		"slot_7": "",
	};
	
	var dir := DirAccess.open(user_dir);
	dir.make_dir(file_dir);
	var file = FileAccess.open(managerfile, FileAccess.WRITE);
	
	var data = JSON.stringify(save_dict, "\t", false);
	file.store_string(data);
	file.close();
	return


func read_manager_file() -> void:
	var file := FileAccess.open(managerfile, FileAccess.READ);
	var content = file.get_as_text();
	file.close();
	
	var json: JSON = JSON.new();
	var error = json.parse(content);
	assert(error == OK, str("JSON Parse Error: ", json.get_error_message(), " in Line ", json.get_error_line()));
	
	manager_dict = json.data as Dictionary;
	return


func store_manager_file() -> void:
	var file = FileAccess.open(managerfile, FileAccess.WRITE);
	var data = JSON.stringify(manager_dict, "\t", false);
	file.store_string(data);
	file.close();
	return


func save_to_file(slot: int) -> void:
	assert(slot >= 0 and slot < 8, "error: invalid save slot index when saving");
	
	var save_dict: Dictionary[String, Variant] = {
		"worldscene_id": GameData.world_scene_id,
		"playtime": int(min(GameData.playtime, 3599999.0)),
		"date": GameData.date_id,
		"money": GameData.money,
	};
	
	var save_data = JSON.stringify(save_dict, "\t", false);
	var file_path: String = filepath + str(slot + 1) + filetype;
	var file := FileAccess.open(file_path, FileAccess.WRITE);
	file.store_string(save_data);
	file.close();
	
	manager_dict[str("slot_", slot)] = str(GameData.world_scene_id, ",", GameData.date_id, ",", int(min(GameData.playtime, 3599999.0)));
	store_manager_file();
	GameData.cur_savefile_slot = slot;
	return


func load_from_file(slot: int) -> void:
	assert(slot >= 0 and slot < 8, "error: invalid save slot index when loading");
	
	if manager_dict.get(str("slot_", slot), "") as String == "":
		GameData.load_new_game_data(slot);
		return
	
	var file_path: String = filepath + str(slot + 1) + filetype;
	var file := FileAccess.open(file_path, FileAccess.READ);
	var content = file.get_as_text();
	file.close();
	
	var json: JSON = JSON.new();
	var error = json.parse(content);
	assert(error == OK, str("JSON Parse Error: ", json.get_error_message(), " in Line ", json.get_error_line()));
	
	var data := json.data as Dictionary;
	GameData.load_existing_game_data(data, slot);
	return


func file_exists(slot: int) -> bool:
	var path: String = filepath + str(slot + 1) + filetype;
	return FileAccess.file_exists(path)


func delete_file(slot: int) -> void:
	var filename: String = str("savefile_", slot + 1, filetype);
	var dir: DirAccess = DirAccess.open(file_dir);
	if dir:
		if dir.file_exists(filename):
			dir.remove(filename);
			print("Savefile ", str(slot + 1), " deleted!");
	return
