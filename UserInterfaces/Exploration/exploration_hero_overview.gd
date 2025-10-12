extends Control

@onready var icon_char := $IconChar as TextureRect;
@onready var bar_health := $BarHealth as TextureProgressBar;
@onready var bar_stamina := $BarStamina as TextureProgressBar;
@onready var label_name := $LabelName as Label;
@onready var label_level := $LabelLevelValue as Label;


func update_data(char_data: CharacterData) -> void:
	if char_data == null:
		visible = false;
		return
	
	visible = true;
	icon_char.texture = ResourceManager.get_hero_portrait(char_data.id);
	bar_health.max_value = char_data.accum_stats[0];
	bar_health.value = char_data.cur_health;
	bar_stamina.max_value = char_data.accum_stats[1];
	bar_stamina.value = char_data.cur_stamina;
	label_name.text = char_data.name;
	label_level.text = str(char_data.level);
	return
