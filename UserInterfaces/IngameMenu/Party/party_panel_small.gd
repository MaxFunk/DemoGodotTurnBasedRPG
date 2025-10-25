extends Control

@onready var selection_panel := $SelectionPanel as Panel;
@onready var char_icon := $CharacterIcon as TextureRect;
@onready var lbl_name := $LabelName as Label;
@onready var hp_bar := $HealthBar as TextureProgressBar;
@onready var sp_bar := $StaminaBar as TextureProgressBar;


func select() -> void:
	selection_panel.visible = true;
	return


func deselect() -> void:
	selection_panel.visible = false;
	return


func fill_with_data(chd: CharacterData) -> void:
	char_icon.texture = ResourceManager.get_hero_portrait(chd.id);
	lbl_name.text = chd.name;
	hp_bar.max_value = chd.accum_stats[0];
	hp_bar.value = chd.cur_health;
	sp_bar.max_value = chd.accum_stats[1];
	sp_bar.value = chd.cur_stamina;
	return
