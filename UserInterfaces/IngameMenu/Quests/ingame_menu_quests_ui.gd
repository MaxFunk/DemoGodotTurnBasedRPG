extends Control

const QuestLI := preload("uid://kqu8cpqeuywc");
const quest_list_item_scene := preload("uid://cio74qmj1uhfr");
const color_active := Color(0.863, 0.078, 0.235, 1.0);
const color_inactive := Color(1.0, 1.0, 1.0);

enum VIEWSTATE {STORY, QUESTS, TASKS}

@onready var cd_dir := $CooldownDirectional as Timer;
@onready var lbl_story := $TabControl/LabelStory as Label;
@onready var lbl_quests := $TabControl/LabelQuests as Label;
@onready var lbl_tasks := $TabControl/LabelTasks as Label;

@onready var quest_ctrl := $QuestsControl as Control;
@onready var quest_scroll_ctrl := $QuestsControl/ScrollControl as ScrollControl;
@onready var quest_detail_ctrl := $QuestsControl/DetailControl as Control;
@onready var lbl_quest_name := $QuestsControl/DetailControl/LabelQuestName as Label;
@onready var lbl_step_number := $QuestsControl/DetailControl/LabelStepNumber as Label;
@onready var lbl_step_description := $QuestsControl/DetailControl/LabelStepDescription as Label;
@onready var ctrl_step_data := $QuestsControl/DetailControl/ControlStepData as Control;
@onready var lbl_step_category := $QuestsControl/DetailControl/ControlStepData/LabelStepCategory as Label;
@onready var lbl_step_value := $QuestsControl/DetailControl/ControlStepData/LabelStepValue as Label;
@onready var lbl_step_target := $QuestsControl/DetailControl/ControlStepData/LabelStepTarget as Label;

var view_state := VIEWSTATE.QUESTS;

var quests: Array[Quest] = [];


func input_event(event: InputEvent) -> bool:
	if event.is_action_pressed("Btn_B"):
		return true
	
	if event.is_action_pressed("R"):
		change_view_state(1);
	if event.is_action_pressed("L"):
		change_view_state(-1);
	
	if event.is_action_pressed("Btn_X"):
		if view_state == VIEWSTATE.QUESTS:
			mark_quest();
	
	return false


func _process(_delta: float) -> void:
	var just_pressed: bool = false;
	if Input.is_action_just_pressed("D_Pad_Down") or Input.is_action_just_pressed("L_Stick_Down"):
		directional_input(1);
		just_pressed = true;
	elif Input.is_action_just_pressed("D_Pad_Up") or Input.is_action_just_pressed("L_Stick_Up"):
		directional_input(-1);
		just_pressed = true;
	
	if just_pressed:
		cd_dir.start(0.5);
	
	if cd_dir.is_stopped() and not just_pressed:
		if Input.is_action_pressed("D_Pad_Down") or Input.is_action_pressed("L_Stick_Down"):
			directional_input(1);
			cd_dir.start(0.1);
		elif Input.is_action_pressed("D_Pad_Up") or Input.is_action_pressed("L_Stick_Up"):
			directional_input(-1);
			cd_dir.start(0.1);
	return


func directional_input(dir: int) -> void:
	if view_state == VIEWSTATE.QUESTS:
		if quest_scroll_ctrl.elements.size() > 0:
			(quest_scroll_ctrl.get_current_element() as QuestLI).set_selection(false);
			quest_scroll_ctrl.change_index(dir);
			update_quest_view();
	return


func prepare_view() -> void:
	view_state = VIEWSTATE.QUESTS;
	quests.clear();
	quest_scroll_ctrl.reset();
	for quest in GameData.quest_manager.active_quests:
		quests.append(quest)
	for quest_id in GameData.quest_manager.completed_quests:
		var new_completed_quest := Quest.new(quest_id, -1);
		quests.append(new_completed_quest);
	for quest in quests:
		add_quest_element(quest);
	
	update_view();
	return


func change_view_state(dir: int) -> void:
	match view_state:
		VIEWSTATE.STORY:
			if dir > 0:
				view_state = VIEWSTATE.QUESTS;
		VIEWSTATE.QUESTS:
			if dir < 0:
				view_state = VIEWSTATE.STORY;
			if dir > 0:
				view_state = VIEWSTATE.TASKS;
		VIEWSTATE.TASKS:
			if dir < 0:
				view_state = VIEWSTATE.QUESTS;
	update_view();
	return


func update_view() -> void:
	lbl_story.modulate = color_active if view_state == VIEWSTATE.STORY else color_inactive;
	lbl_quests.modulate = color_active if view_state == VIEWSTATE.QUESTS else color_inactive;
	lbl_tasks.modulate = color_active if view_state == VIEWSTATE.TASKS else color_inactive;
	
	quest_ctrl.visible = view_state == VIEWSTATE.QUESTS;
	
	match view_state:
		VIEWSTATE.STORY:
			pass
		VIEWSTATE.QUESTS:
			update_quest_view();
		VIEWSTATE.TASKS:
			pass
	return


func update_quest_view() -> void:
	if quests.size() <= 0:
		quest_detail_ctrl.visible = false;
		return
	
	var quest := quests[quest_scroll_ctrl.idx_selected];
	lbl_quest_name.text = quest.quest_name;
	lbl_step_number.text = "Completed" if quest.completed else str("Step ", quest.quest_step + 1, " of ", quest.steps_max);
	lbl_step_description.text = quest.step_description;
	ctrl_step_data.visible = !quest.completed;
	lbl_step_category.text = quest.get_steptype_string();
	lbl_step_value.text = str(quest.quest_value);
	lbl_step_target.text = str(quest.step_value);
	
	quest_detail_ctrl.visible = true;
	(quest_scroll_ctrl.get_current_element() as QuestLI).set_selection(true);
	return


func add_quest_element(quest: Quest) -> void:
	var quest_li := quest_list_item_scene.instantiate() as QuestLI;
	quest_scroll_ctrl.add_element(quest_li);
	quest_li.write_quest_data(quest);
	return


func mark_quest() -> void:
	if quests.size() <= 0:
		return
	
	var quest := quests[quest_scroll_ctrl.idx_selected];
	if quest.marked:
		GameData.quest_manager.remove_quest_from_marked(quest);
	else:
		GameData.quest_manager.set_quest_as_marked(quest);
	
	(quest_scroll_ctrl.get_current_element() as QuestLI).write_quest_data(quest);
	return
