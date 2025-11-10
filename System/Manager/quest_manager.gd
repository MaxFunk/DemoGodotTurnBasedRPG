class_name QuestManager extends RefCounted

enum EVENTTYPE {INTERACT = 0, COLLECT = 1, DEFEAT = 2, TALK = 3, REACHZONE = 4}

var main_quest: MainQuest = null;
var active_quests: Array[Quest] = [];
var active_tasks: Array[int] = [];
var completed_quests: PackedInt32Array = [];
var completed_tasks: PackedInt32Array = [];
var marked_quests: PackedInt32Array = [];


func clear_data() -> void:
	main_quest = null;
	active_quests.clear();
	active_tasks.clear();
	completed_quests.clear();
	completed_tasks.clear();
	marked_quests.clear();
	return


func load_data(data: Dictionary) -> void:
	clear_data();
	
	var story_step: int = int(str(data["story_step"]));
	var main_quest_value: int = int(str(data.get("main_quest_value", 0)));
	main_quest = MainQuest.new(story_step, main_quest_value);
	
	var active_quests_str: String = str(data["active_quests"]);
	var completed_quests_str: String = str(data["completed_quests"]);
	var marked_quests_str: String = str(data["marked_quests"]);
	
	for id_str in completed_quests_str.split(","):
		completed_quests.append(int(id_str));
	for id_str in marked_quests_str.split(","):
		marked_quests.append(int(id_str));
	
	for data_str in active_quests_str.split(","):
		var quest_data := data_str.split(":");
		if quest_data.size() == 3:
			var new_quest := Quest.new(int(quest_data[0]), int(quest_data[1]), int(quest_data[2]));
			active_quests.append(new_quest);
			if marked_quests.has(new_quest.id):
				new_quest.marked = true;
	return


func save_data() -> Dictionary:
	var active_quests_str: String = "";
	var completed_quests_str: String = "";
	var marked_quests_str: String = "";
	
	for quest in active_quests:
		active_quests_str += str(quest.id, ":", quest.quest_step, ":", quest.quest_value, ",");
	for id in completed_quests:
		completed_quests_str += str(id, ",");
	for id in marked_quests:
		marked_quests_str += str(id, ",");
	
	var save_dict: Dictionary[String, Variant] = {
		"story_step": main_quest.step,
		"main_quest_value": main_quest.quest_value,
		"active_quests": active_quests_str.trim_suffix(","),
		"completed_quests": completed_quests_str.trim_suffix(","),
		"marked_quests": marked_quests_str.trim_suffix(",")
	};
	return save_dict


func add_new_quest(quest_id: int) -> void:
	if completed_quests.has(quest_id):
		return
	
	for quest in active_quests:
		if quest.id == quest_id:
			return
	
	var new_quest := Quest.new(quest_id);
	if new_quest.valid:
		active_quests.append(new_quest);
		if GameData.main_scene.world_scene.exploration_ui:
			GameData.main_scene.world_scene.exploration_ui.add_quest_to_queue(new_quest);
	return


func event_check(event_type: EVENTTYPE, event_id: int, event_amount: int) -> void:
	var finished_quests: Array[Quest] = [];
	var exploration_ui := GameData.main_scene.world_scene.exploration_ui;
	
	if main_quest.event_check(int(event_type), event_id, event_amount):
		if exploration_ui:
			exploration_ui.add_quest_to_queue(main_quest.create_quest_copy());
	
	for quest in active_quests:
		var step_type := int(event_type);
		if step_type in Quest.STEPTYPE.values():
			var quest_res := quest.event_check(step_type, event_id, event_amount);
			if quest_res == 0: # Step update
				if exploration_ui:
					exploration_ui.add_quest_to_queue(quest);
			if quest_res == 1: # Finished update
				print("FINISHED QUEST: ", quest.quest_name);
				finished_quests.append(quest);
	
	for quest in finished_quests:
		active_quests.erase(quest);
		completed_quests.append(quest.id);
		if exploration_ui:
			exploration_ui.add_quest_to_queue(quest);
	
	if exploration_ui:
		exploration_ui.update_quest_view();
	return


func set_quest_as_marked(quest: Quest) -> bool:
	if quest.completed or !quest.valid or marked_quests.size() >= 3:
		return false
	
	quest.marked = true;
	marked_quests.append(quest.id);
	if GameData.main_scene.world_scene.exploration_ui:
		GameData.main_scene.world_scene.exploration_ui.update_quest_view();
	return true


func remove_quest_from_marked(quest: Quest) -> void:
	if quest.completed or !quest.valid or !marked_quests.has(quest.id):
		return
	
	var index := marked_quests.find(quest.id);
	marked_quests.remove_at(index);
	quest.marked = false;
	if GameData.main_scene.world_scene.exploration_ui:
		GameData.main_scene.world_scene.exploration_ui.update_quest_view();
	return


func get_marked_quest(index: int) -> Quest:
	if index < marked_quests.size():
		var quest_id := marked_quests[index];
		for quest in active_quests:
			if quest.id == quest_id:
				return quest
	return null
