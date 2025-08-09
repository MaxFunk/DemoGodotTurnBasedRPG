extends Control

@onready var without_icon_ctrl := $WithoutIcon as Control;
@onready var lbl_text := $WithoutIcon/LabelText as Label;
@onready var lbl_name := $WithoutIcon/LabelName as Label;
@onready var continue_icon := $WithoutIcon/ContinueIcon as ColorRect;

@onready var question_ctrl := $QuestionUI as Control;
@onready var lbl_answer_1 := $QuestionUI/LabelAnswer1 as Label;
@onready var lbl_answer_2 := $QuestionUI/LabelAnswer2 as Label;
@onready var selector := $QuestionUI/Selector as ColorRect;

var cur_td: TextboxData;

var has_begun: bool = false;
var is_shaping: bool = false;
var is_in_question: bool = false;

var question_idx: int = 0;
var char_per_sec: float = 20.0;


func _process(delta: float) -> void:
	if !has_begun: return
	
	if Input.is_action_just_pressed("Btn_Y"):
		next_step();
		return
	
	if Input.is_action_just_pressed("Btn_B"):
		skip_shaping();
		return
	
	if Input.is_action_just_pressed("D_Pad_Down"):
		change_question_index(1);
	
	if Input.is_action_just_pressed("D_Pad_Up"):
		change_question_index(-1);
	
	if is_shaping:
		var max_time := lbl_text.get_total_character_count() / char_per_sec;
		lbl_text.visible_ratio += delta / max_time;
		if lbl_text.visible_ratio >= 1.0:
			skip_shaping();
	return


func load_cur_td() -> void:
	if cur_td == null:
		end();
		return
	
	lbl_text.text = cur_td.text;
	lbl_name.text = cur_td.speaker_name;
	
	question_idx = 0;
	is_in_question = false;
	question_ctrl.visible = false;
	lbl_answer_1.text = cur_td.answer_1;
	lbl_answer_2.text = cur_td.answer_2;
	
	continue_icon.visible = false;
	lbl_text.visible_characters = 0;
	is_shaping = true;
	return


func begin(first_text_id: int) -> void:
	cur_td = ResourceManager.get_textbox_data(first_text_id);
	load_cur_td();
	has_begun = true;
	return


func next_step() -> void:
	if is_shaping:
		return
	
	cur_td = cur_td.next_td_1 if question_idx == 0 else cur_td.next_td_2;
	load_cur_td();
	return


func skip_shaping() -> void:
	lbl_text.visible_ratio = 1.0;
	is_shaping = false;
	
	if cur_td.is_question:
		is_in_question = true;
		question_ctrl.visible = true;
		return
	
	if cur_td.next_td_1 != null:
		continue_icon.visible = true;
	return


func end() -> void:
	GameData.main_scene.clear_talking_ui();
	return


func change_question_index(value: int) -> void:
	if !is_in_question:
		return
	
	if value < 0 and question_idx == 0:
		question_idx = 1;
	elif value > 0 and question_idx == 1:
		question_idx = 0;
	else:
		question_idx = clampi(question_idx + value, 0, 1);
	
	match question_idx:
		0: selector.position.y = lbl_answer_1.position.y;
		_: selector.position.y = lbl_answer_2.position.y;
	return
