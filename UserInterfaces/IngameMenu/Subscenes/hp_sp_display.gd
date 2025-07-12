extends Control

const texture_hp := preload("res://Resources/Images/ProgressBars/progbar_fill_health.png");
const texture_sp := preload("res://Resources/Images/ProgressBars/progbar_fill_stamina.png");

enum DISPLAYTYPE {HP, SP}

@onready var lbl_stat_name := $LabelStatName as Label;
@onready var lbl_stat_value_cur := $LabelStatValueCur as Label;
@onready var lbl_stat_value_max := $LabelStatValueMax as Label;
@onready var prog_bar := $TextureProgressBar as TextureProgressBar;

@export var display_type := DISPLAYTYPE.HP;


func _ready() -> void:
	match display_type:
		DISPLAYTYPE.HP: lbl_stat_name.text = "Health"; prog_bar.texture_progress = texture_hp;
		DISPLAYTYPE.SP: lbl_stat_name.text = "Stamina"; prog_bar.texture_progress = texture_sp;
	return


func update_bar(chd: CharacterData) -> void:
	var max_value: int = 0;
	var cur_value: int = 0;
	match display_type:
		DISPLAYTYPE.HP: max_value = chd.accum_stats[0]; cur_value = chd.cur_health;
		DISPLAYTYPE.SP: max_value = chd.accum_stats[1]; cur_value = chd.cur_stamina;
	
	lbl_stat_value_cur.text = str(cur_value);
	lbl_stat_value_max.text = str(max_value);
	prog_bar.max_value = max_value
	prog_bar.value = cur_value;
	return
