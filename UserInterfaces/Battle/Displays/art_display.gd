extends Control

@onready var icon_art := $IconArt as TextureRect;
@onready var icon_attr_1 := $IconAttribute1 as TextureRect;
@onready var icon_attr_2 := $IconAttribute2 as TextureRect;
@onready var lbl_name := $LabelName as Label;
@onready var lbl_cost_val := $LabelCostValue as Label;
@onready var lbl_cost := $LabelCost as Label;

const color_usable := Color(1, 1, 1);
const color_unusable := Color(1.0, 0.141, 0.183, 1.0);
const color_gray := Color(0.4, 0.4, 0.4);


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
		lbl_cost_val.text = str(art.cost * 2);
	else:
		lbl_cost_val.text = str(art.cost);
	
	var check_1: bool = art.is_ult and art.cost > actor.ult_points;
	var check_2: bool = art.is_ult == false and art.cost > actor.sp_cur;
	var check_3: bool = art.is_revival_art and not GameData.main_scene.battle_scene.check_revive_art_usable();
	var unusable: bool = check_1 or check_2 or check_3;
	if unusable:
		lbl_name.modulate = color_unusable;
		lbl_cost_val.modulate = color_unusable;
		lbl_cost.modulate = color_unusable;
	else:
		lbl_name.modulate = color_usable;
		lbl_cost_val.modulate = color_usable;
		lbl_cost.modulate = color_usable;
	
	lbl_cost.text = "CP" if art.is_ult else "SP";
	
	lbl_cost.visible = false if art.is_passive_art() else true;
	lbl_cost_val.visible = false if art.is_passive_art() else true;
	var gray_out: bool = unusable or art.is_passive_art() or actor.ailment == Ailments.SHACKLED;
	modulate = color_gray if gray_out else color_usable;
	return
