extends Control

const selectiond_color := Color(0.863, 0.078, 0.235, 1.0);
const white_color := Color(1.0, 1.0, 1.0);
const gray_color := Color(0.5, 0.5, 0.5, 1.0);

@onready var lbl_name := $LabelName as Label;
@onready var icon_marked := $IconMarked as ColorRect;


func write_quest_data(quest: Quest) -> void:
	lbl_name.text = quest.quest_name;
	modulate = gray_color if quest.completed else white_color;
	modulate.a = 0.5 if quest.completed else 1.0;
	icon_marked.visible = quest.marked;
	return


func set_selection(selected: bool) -> void:
	lbl_name.modulate = selectiond_color if selected else white_color;
	return
