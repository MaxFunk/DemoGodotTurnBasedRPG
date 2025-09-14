class_name LabelButton
extends Label

@export var base_color := Color(1, 1, 1);
@export var hovered_color := Color(0.98, 0.486, 0.514);

signal btn_pressed();

var btn_hovered: bool = false;


func toggle_hovered() -> void:
	btn_hovered = !btn_hovered;
	if btn_hovered:
		self_modulate = hovered_color;
	else:
		self_modulate = base_color;
	return


func clear_hovered() -> void:
	btn_hovered = false;
	self_modulate = base_color;
	return


func set_hovered() -> void:
	btn_hovered = true;
	self_modulate = hovered_color;
	return


func set_hovered_value(val: bool) -> void:
	btn_hovered = val;
	self_modulate = hovered_color if val else base_color;
	return


func press_button() -> void:
	btn_pressed.emit();
	return
