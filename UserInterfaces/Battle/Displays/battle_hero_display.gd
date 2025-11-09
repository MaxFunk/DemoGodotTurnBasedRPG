extends Control

@onready var panel_selection := $ColorRect/SelectionPanel as Panel;
@onready var lbl_name := $ColorRect/LabelName as Label;
@onready var lbl_level := $ColorRect/LabelLevelData as Label;
@onready var lbl_hp := $ColorRect/LabelHealth as Label;
@onready var lbl_sp := $ColorRect/LabelStamina as Label;
@onready var bar_hp := $ColorRect/BarHealth as TextureProgressBar;
@onready var bar_sp := $ColorRect/BarStamina as TextureProgressBar;
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

var hero_data: BattleData;


func update_init(data: BattleData) -> void:
	if data == null:
		visible = false;
		return
	
	if hero_data:
		remove_battle_data();
	
	visible = true;
	lbl_name.text = data.name;
	lbl_level.text = str(data.level);
	data.update_display.connect(update);
	hero_data = data;
	update();
	return


func update() -> void:
	if !hero_data:
		return
	
	lbl_hp.text = str(hero_data.hp_cur);
	lbl_sp.text = str(hero_data.sp_cur);
	
	bar_hp.max_value = hero_data.hp_max;
	bar_hp.value = hero_data.hp_cur;
	bar_sp.max_value = hero_data.sp_max;
	bar_sp.value = hero_data.sp_cur;
	bar_ult.value = hero_data.ult_points;
	
	icon_ailment.texture = Ailments.get_ailment_icon(hero_data.ailment);
	
	var status_visible: bool = false;
	for i in range(3):
		var mod_visible: bool = hero_data.modifier[i] != 0;
		lbls_modifier_text[i].visible = mod_visible;
		lbls_modifier_values[i].visible = mod_visible;
		lbls_modifier_values[i].text = get_modifier_text(hero_data.modifier[i]);
		if mod_visible:
			status_visible = true;
	
	status_rect.visible = status_visible;
	modulate = Color.WHITE;
	return


func remove_battle_data() -> void:
	hero_data.update_display.disconnect(update);
	hero_data = null;
	return


func set_to_defeated_state() -> void:
	update();
	icon_ailment.texture = null;
	modulate = Color.DIM_GRAY;
	bar_hp.value = 0;
	bar_sp.value = 0;
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
