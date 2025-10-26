extends Control

@export var base_color := Color(1, 1, 1);
@export var hovered_color := Color(0.98, 0.486, 0.514);

@onready var lbl_slot := $LabelSlot as Label;
@onready var lbl_newgame := $LabelNewGame as Label;
@onready var ctrl_exists := $FileExists as Control;
@onready var lbl_loc := $FileExists/LabelLocation as Label;
@onready var lbl_date := $FileExists/LabelDate as Label;
@onready var lbl_time := $FileExists/LabelPlaytime as Label;

var btn_hovered: bool = false;


func update_data_display(data: String, slot: int) -> void:
	lbl_slot.text = str("File ", slot + 1);
	
	if data == "":
		lbl_newgame.visible = true;
		ctrl_exists.visible = false;
		return
	
	var data_array := data.split(","); # TODO: Check if data_array has size == 3
	lbl_loc.text = str("{Location: ", data_array[0], "}");
	lbl_date.text = ResourceManager.dates_table.records[int(data_array[1])]["as_string"];
	lbl_time.text = playtime_to_string(float(data_array[2]));
	lbl_newgame.visible = false;
	ctrl_exists.visible = true;
	return


func playtime_to_string(playtime: float) -> String:
	if playtime > 3599999.0:
		return "999:59:59";
	var plyt: int = int(playtime);
	@warning_ignore("integer_division")
	var hours: int = plyt / 3600;
	plyt = plyt % 3600;
	@warning_ignore("integer_division")
	var minutes: int = plyt / 60;
	var seconds: int = plyt % 60;
	return str(hours).lpad(3, "0") + ":" + str(minutes).lpad(2, "0") + ":" + str(seconds).lpad(2, "0")


func toggle_hovered() -> void:
	btn_hovered = !btn_hovered;
	if btn_hovered:
		modulate = hovered_color;
	else:
		modulate = base_color;
	return


func unhover() -> void:
	btn_hovered = false;
	modulate = base_color;
	return
