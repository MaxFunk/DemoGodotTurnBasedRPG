extends Control

@onready var without_icon_ctrl := $WithoutIcon as Control;
@onready var lbl_text := $WithoutIcon/LabelText as Label;
@onready var lbl_name := $WithoutIcon/LabelName as Label;
@onready var continue_icon := $WithoutIcon/ContinueIcon as ColorRect;

var text_data: Array[TextboxData] = [];
var cur_index: int = -1;

var has_begun: bool = false;
var is_shaping: bool = false;
var char_per_sec: float = 20.0;


func _process(delta: float) -> void:
	if is_shaping:
		var max_time := lbl_text.get_total_character_count() / char_per_sec;
		lbl_text.visible_ratio += delta / max_time;
		if lbl_text.visible_ratio >= 1.0:
			is_shaping = false;
			continue_icon.visible = true;
	return


func _input(_event: InputEvent) -> void:
	if !has_begun: return
	
	if Input.is_action_just_pressed("Btn_Y"):
		next_step();
		return
	
	if Input.is_action_just_pressed("Btn_B"):
		skip_shaping();
	return


func load_text() -> void:
	load_dummy_text();
	return


func begin() -> void:
	cur_index = -1;
	has_begun = true;
	next_step();
	return


func next_step() -> void:
	if is_shaping:
		return
	
	cur_index += 1;
	if cur_index >= text_data.size():
		end();
		return
	
	var cur_text := text_data[cur_index];
	lbl_text.text = cur_text.text;
	lbl_name.text = cur_text.speaker_name;
	
	continue_icon.visible = false;
	lbl_text.visible_characters = 0;
	is_shaping = true;
	return


func skip_shaping() -> void:
	lbl_text.visible_ratio = 1.0;
	is_shaping = false;
	continue_icon.visible = true;
	return


func end() -> void:
	GameData.main_scene.clear_talking_ui();
	return


func load_dummy_text() -> void:
	print("--- Delete and replace with actual data ---");
	
	var td := TextboxData.new();
	td.text = "Hello, this is a dummy text! I can only speak a little bit.";
	td.speaker_name = "Dummy Speaker";
	text_data.append(td);
	
	td = TextboxData.new();
	td.text = "I can also speak even more, but there is nothing to talk about.";
	td.speaker_name = "Dummy Speaker";
	text_data.append(td);
	
	td = TextboxData.new();
	td.text = "Come back, when there is actual text to read here! Bye.";
	td.speaker_name = "Dummy Speaker";
	text_data.append(td);
	return
