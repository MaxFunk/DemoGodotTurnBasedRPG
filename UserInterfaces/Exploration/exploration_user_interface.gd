extends Control

@onready var label_date := $LabelDate as Label;

var current_world_scene: WorldScene = null;

func update_data() -> void:
	label_date.text = ResourceManager.dates_table.records[GameData.date_id]["as_string"];
	print("TODO (EXPLORATION UI): Create a Date object, hold one in GameData, use it for events");
	
	return
