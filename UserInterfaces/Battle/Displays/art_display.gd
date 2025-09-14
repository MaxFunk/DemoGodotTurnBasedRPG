extends Control

@onready var icon_art := $IconArt as TextureRect;
@onready var icon_attr_1 := $IconAttribute1 as TextureRect;
@onready var icon_attr_2 := $IconAttribute2 as TextureRect;
@onready var lbl_name := $LabelName as Label;
@onready var lbl_cost_val := $LabelCostValue as Label;
@onready var lbl_cost := $LabelCost as Label;


func update(art: BattleArt, actor: BattleData) -> void:
	if art == null:
		visible = false;
		return
	
	visible = true;
	icon_art.texture = ResourceManager.get_art_category_icon(int(art.category));
	icon_attr_1.texture = Attributes.get_attribute_icon(art.attribute_1);
	icon_attr_2.texture = Attributes.get_attribute_icon(art.attribute_2);
	lbl_name.text = art.name;
	if actor.ailment == Ailments.EXHAUSTED:
		lbl_cost_val.text = str(art.sp_cost * 2);
	else:
		lbl_cost_val.text = str(art.sp_cost);
	
	if art.sp_cost > actor.sp_cur:
		lbl_cost_val.modulate = Color.WEB_MAROON;
		lbl_cost.modulate = Color.WEB_MAROON;
	else:
		lbl_cost_val.modulate = Color.WHITE;
		lbl_cost.modulate = Color.WHITE;
	
	lbl_cost.visible = false if art.is_ult or art.is_passive_art() else true;
	lbl_cost_val.visible = false if art.is_ult or art.is_passive_art() else true;
	modulate.a = 0.5 if art.is_passive_art() or actor.ailment == Ailments.SHACKLED else 1.0;
	return
