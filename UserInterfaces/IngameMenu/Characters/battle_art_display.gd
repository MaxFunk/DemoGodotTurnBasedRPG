extends Control

@onready var icon_art := $IconArt as TextureRect;
@onready var icon_attr_1 := $IconAttribute1 as TextureRect;
@onready var icon_attr_2 := $IconAttribute2 as TextureRect;
@onready var lbl_name := $LabelName as Label;
@onready var lbl_cost_val := $LabelCostValue as Label;
@onready var lbl_cost := $LabelCost as Label;

var valid_art: bool = true;


func fill_data(art: BattleArt) -> void:
	if art == null:
		icon_art.texture = ResourceManager.get_art_category_icon(-1);
		icon_attr_1.texture = null;
		icon_attr_2.texture = null;
		lbl_name.text = "---";
		lbl_cost_val.visible = false;
		lbl_cost.visible = false;
		modulate.a = 0.5;
		valid_art = false;
		return
	
	icon_art.texture = ResourceManager.get_art_category_icon(int(art.category));
	icon_attr_1.texture = Attributes.get_attribute_icon(art.attribute_1);
	icon_attr_2.texture = Attributes.get_attribute_icon(art.attribute_2);
	lbl_name.text = art.name;
	lbl_cost_val.text = str(art.cost);
	lbl_cost.text = "CP" if art.is_ult else "SP";
	
	lbl_cost_val.visible = !art.is_passive_art();
	lbl_cost.visible = !art.is_passive_art();
	modulate.a = 1.0;
	valid_art = true;
	return
