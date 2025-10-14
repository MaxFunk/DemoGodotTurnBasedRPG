extends Control

const HpSpDisplay := preload("res://UserInterfaces/IngameMenu/Subscenes/hp_sp_display.gd");
const StatDisplay := preload("res://UserInterfaces/IngameMenu/Subscenes/stat_display.gd");
const ArtDisplay := preload("res://UserInterfaces/IngameMenu/Subscenes/battle_art_display.gd");

@onready var lbl_name := $UpperRow/LabelName as Label;
@onready var lbl_level := $UpperRow/LabelLevelData as Label;
@onready var hp_disp := $LeftColumn/HpDisplay as HpSpDisplay;
@onready var sp_disp := $LeftColumn/SpDisplay as HpSpDisplay;
@onready var stat_disps: Array[StatDisplay] = [
	$LeftColumn/StatDisplay1 as StatDisplay,
	$LeftColumn/StatDisplay2 as StatDisplay,
	$LeftColumn/StatDisplay3 as StatDisplay,
	$LeftColumn/StatDisplay4 as StatDisplay,
	$LeftColumn/StatDisplay5 as StatDisplay,
	$LeftColumn/StatDisplay6 as StatDisplay];
@onready var art_disps: Array[ArtDisplay] = [
	$RightColumn/BattleArtDisplay1 as ArtDisplay,
	$RightColumn/BattleArtDisplay2 as ArtDisplay,
	$RightColumn/BattleArtDisplay3 as ArtDisplay,
	$RightColumn/BattleArtDisplay4 as ArtDisplay,
	$RightColumn/BattleArtDisplay5 as ArtDisplay,
	$RightColumn/BattleArtDisplay6 as ArtDisplay,
	$RightColumn/BattleArtDisplay7 as ArtDisplay,
	$RightColumn/BattleArtDisplay8 as ArtDisplay];
@onready var marker_attr_icons: Array[Control] = [
	$BottomRow/MarkerIconsWeak as Control,
	$BottomRow/MarkerIconsResist as Control,
	$BottomRow/MarkerIconsBlock as Control];

var texture_rects: Array[TextureRect] = [];


func load_character_data(bd: BattleData) -> void:
	var show_data: bool = bd.is_analyzed;
	lbl_name.text = bd.name;
	lbl_level.text = str(bd.level);
	
	hp_disp.update_inspect(bd);
	sp_disp.update_inspect(bd);
	for st_disp in stat_disps:
		st_disp.update_inspect(bd, show_data);
	
	for i in bd.arts.size():
		art_disps[i].fill_data(bd.arts[i] if show_data else null);
	
	load_attribute_icons(bd, show_data);
	return


func load_attribute_icons(bd: BattleData, show_data: bool) -> void:
	for textrect in texture_rects:
		textrect.queue_free();
	texture_rects.clear();
	
	if !show_data:
		return
	
	for i in bd.attribute_weak.size():
		var text_rect := TextureRect.new();
		marker_attr_icons[0].add_child(text_rect);
		text_rect.position.x = marker_attr_icons[0].size.x * i;
		text_rect.size = marker_attr_icons[0].size;
		text_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH;
		text_rect.texture = Attributes.get_attribute_icon(bd.attribute_weak[i]);
		texture_rects.append(text_rect);
	
	for i in bd.attribute_resist.size():
		var text_rect := TextureRect.new();
		marker_attr_icons[1].add_child(text_rect);
		text_rect.position.x = marker_attr_icons[1].size.x * i;
		text_rect.size = marker_attr_icons[1].size;
		text_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH;
		text_rect.texture = Attributes.get_attribute_icon(bd.attribute_resist[i]);
		texture_rects.append(text_rect);
	
	for i in bd.attribute_block.size():
		var text_rect := TextureRect.new();
		marker_attr_icons[2].add_child(text_rect);
		text_rect.position.x = marker_attr_icons[2].size.x * i;
		text_rect.size = marker_attr_icons[2].size;
		text_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH;
		text_rect.texture = Attributes.get_attribute_icon(bd.attribute_block[i]);
		texture_rects.append(text_rect);
	return
