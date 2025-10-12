extends Control

@onready var label_name := $LabelName as Label;
@onready var label_amount := $LabelAmount as Label;

var time_active: float = 0.0;


func update_data(item: Item) -> void:
	label_name.text = item.name;
	label_amount.text = str(item.amount);
	return
