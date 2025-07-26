extends Control

@onready var panel_selection := $ColorRect/SelectionPanel as Panel;
@onready var lbl_name := $ColorRect/LabelName as Label;
@onready var lbl_level := $ColorRect/LabelLevelData as Label;
@onready var bar_hp := $ColorRect/BarHealth as TextureProgressBar;
@onready var bar_ult := $ColorRect/BarUlt as TextureProgressBar;
@onready var icon_ailment := $ColorRect/IconAilment as TextureRect;

@onready var status_rect := $StatusRect as ColorRect;
@onready var lbls_modifier_text: Array[Label] = [
	$StatusRect/LabelAtt as Label,
	$StatusRect/LabelDef as Label,
	$StatusRect/LabelAcc as Label];
@onready var lbls_modifier_values: Array[Label] = [
	$StatusRect/LabelAttValue as Label,
	$StatusRect/LabelDefValue as Label,
	$StatusRect/LabelAccValue as Label];

var oppo_data: BattleData;


func update_init(data: BattleData) -> void:
	if data == null:
		visible = false;
		return
	
	visible = true;
	lbl_name.text = data.name;
	lbl_level.text = str(data.level);
	
	data.update_display.connect(update);
	oppo_data = data;
	
	update()
	return


func update() -> void:
	if !oppo_data:
		return
	
	bar_hp.max_value = oppo_data.hp_max;
	bar_hp.value = oppo_data.hp_cur;
	bar_ult.value = oppo_data.ult_points;
	
	icon_ailment.texture = Ailments.get_ailment_icon(oppo_data.ailment);
	
	var status_visible: bool = false;
	for i in range(3):
		var mod_visible: bool = oppo_data.modifier[i] != 0;
		lbls_modifier_text[i].visible = mod_visible;
		lbls_modifier_values[i].visible = mod_visible;
		lbls_modifier_values[i].text = get_modifier_text(oppo_data.modifier[i]);
		if mod_visible:
			status_visible = true;
	
	status_rect.visible = status_visible;
	return


func set_selection(value: bool) -> void:
	panel_selection.visible = value;
	return


func get_modifier_text(value: int) -> String:
	match value:
		-2: return "<<"
		-1: return "<"
		1: return ">"
		2: return ">>"
		_: return ""
