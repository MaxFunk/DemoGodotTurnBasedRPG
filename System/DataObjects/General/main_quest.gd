class_name MainQuest extends Resource

const main_quest_data := preload("uid://bgmxu21ad2yj6").records;
enum STEPTYPE {INTERACT = 0, COLLECT = 1, DEFEAT = 2, TALK = 3, REACHZONE = 4}

var step: int = -1;
var step_type := STEPTYPE.INTERACT;
var step_id: int = -1;
var step_value: int = 0;
var step_description: String = "";
var step_short_description: String = "";
var quest_value: int = 0;


func _init(load_step_value: int, load_quest_value: int) -> void:
	if load_step_value < 0 or load_step_value >= main_quest_data.size():
		load_fallback();
		return
	
	load_step(load_step_value);
	quest_value = load_quest_value;
	return


func progress_main_quest() -> void:
	step += 1;
	if step < 0 or step >= main_quest_data.size():
		load_fallback();
		return
	load_step(step);
	return


func load_step(load_step_value: int) -> void:
	var data := main_quest_data[load_step_value];
	step = load_step_value;
	step_type = int(str(data.get("step_type", 0))) as STEPTYPE;
	step_id = int(str(data.get("step_id", 0)));
	step_value = int(str(data.get("step_value", 0)));
	step_short_description = str(data.get("short_description", ""));
	step_description = str(data.get("description", ""));
	return


func load_fallback() -> void:
	step = -1;
	step_type = STEPTYPE.INTERACT;
	step_id = -1;
	step_value = -1;
	step_short_description = "Finished Main Quest"
	step_description = "Finished Main Quest, have fun with the rest of the game!"
	return


func event_check(event_type: STEPTYPE, event_id: int, event_amount: int) -> bool:
	if event_type == step_type and event_id == step_id:
		quest_value += event_amount;
		if quest_value >= step_value:
			progress_main_quest();
			return true
	return false


func create_quest_copy() -> Quest:
	var copy_quest := Quest.new(-1);
	copy_quest.valid = true;
	copy_quest.main_quest_copy = true;
	copy_quest.quest_step = -1;
	copy_quest.quest_name = step_short_description;
	return copy_quest
