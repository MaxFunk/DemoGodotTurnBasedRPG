extends Control

@onready var icon_art := $IconArt as TextureRect;
@onready var lbl_name := $LabelName as Label;
@onready var lbl_cost := $LabelCost as Label;


func fill_data(art: BattleArt) -> void:
	if art == null:
		icon_art.texture = ResourceManager.get_art_category_icon(-1);
		lbl_name.text = "---";
		lbl_cost.visible = false;
		modulate.a = 0.5;
		return
	
	icon_art.texture = ResourceManager.get_art_category_icon(int(art.category));
	lbl_name.text = art.name;
	lbl_cost.text = str(art.sp_cost, " SP");
	
	lbl_cost.visible = false if art.is_ult or art.category == art.CATEGORY.PASSIVE else true;
	modulate.a = 1.0;
	return
