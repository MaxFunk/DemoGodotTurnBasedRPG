extends Control

const HpSpDisplay := preload("uid://dudprjba6ha0n");

@onready var selection_panel := $SelectionPanel as Panel;
@onready var char_icon := $CharacterIcon as TextureRect;
@onready var lbl_name := $LabelName as Label;
@onready var hp_disp := $HpDisplay as HpSpDisplay;
@onready var sp_disp := $SpDisplay as HpSpDisplay;


func select() -> void:
	selection_panel.visible = true;
	return


func deselect() -> void:
	selection_panel.visible = false;
	return


func fill_with_data(chd: CharacterData) -> void:
	if chd == null:
		char_icon.visible = false;
		lbl_name.visible = false;
		hp_disp.visible = false;
		sp_disp.visible = false;
		return
	
	char_icon.visible = true;
	lbl_name.visible = true;
	hp_disp.visible = true;
	sp_disp.visible = true;
	
	char_icon.texture = ResourceManager.get_hero_portrait(chd.id);
	lbl_name.text = chd.name;
	hp_disp.update_bar(chd);
	sp_disp.update_bar(chd);
	return
