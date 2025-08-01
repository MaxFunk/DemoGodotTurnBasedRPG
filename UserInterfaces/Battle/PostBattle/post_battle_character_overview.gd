extends Control

@onready var icon_char := $IconChar as TextureRect;
@onready var lbl_name := $LabelName as Label;
@onready var lbl_level := $LabelLevelValue as Label;
@onready var lbl_exp := $LabelExpValue as Label;
@onready var bar_exp := $BarExp as TextureProgressBar;
@onready var icon_lvlup := $IconLevelUp as ColorRect;


func update_full(chd: CharacterData) -> void:
	icon_char.texture = ResourceManager.get_hero_portrait(chd.id);
	lbl_name.text = chd.name;
	lbl_level.text = str(chd.level + chd.level_ups);
	lbl_exp.text = str(chd.total_exp);
	
	bar_exp.max_value = Calculations.get_exp_to_next_level(chd.level + chd.level_ups);
	bar_exp.value = chd.exp_to_lvl;
	return


func update_continous(chd: CharacterData) -> void:
	lbl_exp.text = str(chd.total_exp);
	bar_exp.value = chd.exp_to_lvl;
	return


func set_level_up() -> void:
	icon_lvlup.visible = true;
	return
