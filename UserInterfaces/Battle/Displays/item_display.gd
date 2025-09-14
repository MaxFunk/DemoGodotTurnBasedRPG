extends Control

@onready var icon := $IconRect as ColorRect;
@onready var lbl_name := $LabelName as Label;
@onready var lbl_amount := $LabelAmount as Label;


func update_itemdata(item: ItemConsumable) -> void:
	lbl_name.text = item.name;
	lbl_amount.text = str(item.amount);
	return


func set_selected(value: bool) -> void:
	modulate = Color.CRIMSON if value else Color.WHITE;
	return
