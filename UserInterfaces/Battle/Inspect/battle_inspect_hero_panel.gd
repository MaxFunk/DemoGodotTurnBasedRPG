extends Control

@onready var control := $Control as Control
@onready var lbl_name := $Control/LabelCharacter as Label;
@onready var lbl_level := $Control/LabelLevelValue as Label;
@onready var bar_hp := $Control/BarHealth as TextureProgressBar;
@onready var bar_sp := $Control/BarStamina as TextureProgressBar;
@onready var bar_cp := $Control/BarCP as TextureProgressBar;
@onready var icon_ailment := $Control/IconAilment as TextureRect;
@onready var panel_selection := $Panel as Panel;


func update_view(char_data: BattleData) -> void:
	if char_data == null:
		control.visible = false;
		return;
	
	control.visible = true;
	lbl_name.text = char_data.name;
	lbl_level.text = str(char_data.level);
	bar_hp.max_value = char_data.hp_max;
	bar_hp.value = char_data.hp_cur;
	bar_sp.max_value = char_data.sp_max;
	bar_sp.value = char_data.sp_cur;
	bar_cp.value = char_data.ult_points;
	
	icon_ailment.texture = Ailments.get_ailment_icon(char_data.ailment);
	return


func set_selection(value: bool) -> void:
	panel_selection.visible = value;
	return
