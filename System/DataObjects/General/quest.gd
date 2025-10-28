class_name Quest extends RefCounted

const quest_data := preload("uid://cxeerbklucetu").records;
const description_data := preload("uid://dy0xrj2dd8uya").records;
enum STEPTYPE {INTERACT = 0, COLLECT = 1, DEFEAT = 2, TALK = 3, REACHZONE = 4}

var id: int = -1;
var valid: bool = true;
var completed: bool = false;
var marked: bool = false;
var quest_step: int = 0;
var quest_value: int = 0;

var quest_name: String = "Quest";
var steps_max: int = 0;

var steps_data: String = "0:0:0:0"; # TYPE - ID - VALUE - DESCRIPTION_ID
var step_type := STEPTYPE.INTERACT;
var step_id: int = -1;
var step_value: int = 0;

var step_description_id: int = -1;
var step_description: String = "";
var step_short_description: String = "";
var completed_description_id: int = -1;

var reward_money: int = 0;
var reward_items: PackedInt32Array = [];
var reward_items_amount: PackedInt32Array = [];

# STEPS
# Interact with certain thing (id)
# Collect certain Items (id, amount)
# Defeat certain enemies (id, amount)
# Talk to certain person (id)
# Reach area/eventzone (ID of Area3D)


func _init(load_id: int, step: int = 0, value: int = 0) -> void:
	if load_id < 0 or load_id >= quest_data.size():
		valid = false;
		return
	
	var data := quest_data[load_id];
	id = load_id;
	quest_step = step;
	quest_value = value;
	quest_name = str(data["quest_name"]);
	steps_max = int(str(data["steps"]));
	steps_data = str(data["steps_data"]);
	completed_description_id = int(str(data["completed_id"]));
	reward_money = int(str(data["reward_money"]));
	
	for item_data in str(data["reward_items"]).split(","):
		var data_array := item_data.split(":");
		if data_array.size() == 2:
			reward_items.append(int(data_array[0]));
			reward_items_amount.append(int(data_array[1]));
	
	if quest_step < 0 or quest_step >= steps_max:
		on_quest_finished(false);
	else:
		load_step();
	return


func load_step() -> void:
	var steps_data_array := steps_data.split(",");
	if quest_step >= steps_data_array.size():
		return
	
	var step_data := steps_data_array[quest_step];
	var step_data_array := step_data.split(":");
	if step_data_array.size() == 4:
		step_type = int(step_data_array[0]) as STEPTYPE;
		step_id = int(step_data_array[1]);
		step_value = int(step_data_array[2]);
		step_description_id = int(step_data_array[3]);
		load_description(step_description_id);
	else:
		valid = false;
	print(step_data_array);
	return


func load_next_step() -> bool:
	quest_step += 1;
	quest_value = 0;
	if quest_step >= steps_max:
		on_quest_finished(true);
		return true
	load_step();
	return false


func load_description(descr_id: int) -> void:
	if descr_id >= 0 and descr_id < description_data.size():
		step_description = str(description_data[descr_id]["description"]);
		step_short_description = str(description_data[descr_id]["short_description"]);
	else:
		step_description = "No description available ...";
		step_short_description = "...";
	return


func event_check(event_type: STEPTYPE, event_id: int, event_amount: int) -> bool:
	if event_type == step_type and event_id == step_id:
		quest_value += event_amount;
		if quest_value >= step_value:
			return load_next_step();
	return false


func on_quest_finished(give_rewards: bool) -> void:
	load_description(completed_description_id);
	GameData.quest_manager.remove_quest_from_marked(self);
	quest_step = steps_max;
	completed = true;
	
	if give_rewards:
		GameData.money += reward_money;
		for i in reward_items.size():
			GameData.recieve_items_without_category(reward_items[i], reward_items_amount[i]);
	return


func get_steptype_string() -> StringName:
	match step_type:
		STEPTYPE.INTERACT: return "Interacted"
		STEPTYPE.COLLECT: return "Collected"
		STEPTYPE.DEFEAT: return "Defeated"
		STEPTYPE.TALK: return "Talked"
		STEPTYPE.REACHZONE: return "Reached Area"
		_: return ""
