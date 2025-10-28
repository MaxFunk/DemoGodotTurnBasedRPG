extends Control

@onready var lbl_name := $LabelName as Label;
@onready var lbl_short_desc := $LabelShortDescription as Label;
@onready var lbl_quest_value := $LabelQuestValue as Label;
@onready var lbl_quest_goal := $LabelQuestGoal as Label;


func write_data(quest: Quest) -> void:
	if quest == null:
		visible = false;
		return
	
	visible = true;
	lbl_name.text = quest.quest_name;
	lbl_short_desc.text = quest.step_short_description;
	lbl_quest_value.text = str(quest.quest_value);
	lbl_quest_goal.text = str(quest.step_value);
	return
