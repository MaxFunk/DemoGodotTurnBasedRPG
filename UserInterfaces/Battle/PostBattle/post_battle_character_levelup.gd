extends Control

const HpSpDisplay := preload("uid://dudprjba6ha0n");
const StatDisplay := preload("uid://ct3qrk8k2otmi");
const ArtDisplay := preload("uid://dfs2yk165bs6o");

@onready var char_portrait := $UpperRow/CharPortrait as TextureRect;
@onready var lbl_name := $UpperRow/LabelName as Label;
@onready var lbl_level := $UpperRow/LabelLevelData as Label;
@onready var exp_bar := $UpperRow/ExpBar as TextureProgressBar;

@onready var hp_disp := $LeftColumn/HpDisplay as HpSpDisplay;
@onready var sp_disp := $LeftColumn/SpDisplay as HpSpDisplay;
@onready var stat_disps: Array[StatDisplay] = [
	$LeftColumn/StatDisplay1 as StatDisplay,
	$LeftColumn/StatDisplay2 as StatDisplay,
	$LeftColumn/StatDisplay3 as StatDisplay,
	$LeftColumn/StatDisplay4 as StatDisplay,
	$LeftColumn/StatDisplay5 as StatDisplay,
	$LeftColumn/StatDisplay6 as StatDisplay];
@onready var stat_up_lbls: Array[Label] = [
	$LeftColumn/LabelStatUp1 as Label,
	$LeftColumn/LabelStatUp2 as Label,
	$LeftColumn/LabelStatUp3 as Label,
	$LeftColumn/LabelStatUp4 as Label,
	$LeftColumn/LabelStatUp5 as Label,
	$LeftColumn/LabelStatUp6 as Label,
	$LeftColumn/LabelStatUp7 as Label,
	$LeftColumn/LabelStatUp8 as Label];

@onready var art_disps: Array[ArtDisplay] = [
	$RightColumn/BattleArtDisplay1 as ArtDisplay,
	$RightColumn/BattleArtDisplay2 as ArtDisplay,
	$RightColumn/BattleArtDisplay3 as ArtDisplay,
	$RightColumn/BattleArtDisplay4 as ArtDisplay,
	$RightColumn/BattleArtDisplay5 as ArtDisplay,
	$RightColumn/BattleArtDisplay6 as ArtDisplay,
	$RightColumn/BattleArtDisplay7 as ArtDisplay,
	$RightColumn/BattleArtDisplay8 as ArtDisplay];
@onready var new_art_disp := $RightColumn/BattleArtDisplayNew as ArtDisplay;
@onready var new_art_lbl := $RightColumn/LabelNewArt as Label;
@onready var art_selector := $RightColumn/ArtSelector as ColorRect;


var cur_displayed_ult: BattleArt;
var cur_displayed_arts: Array[BattleArt] = [];
var cur_displayed_newart: BattleArt;


func update_view(index: int, show_stat_ups: bool) -> void:
	var chd := GameData.characters[index];
	char_portrait.texture = ResourceManager.get_hero_portrait(chd.id);
	lbl_name.text = chd.name;
	lbl_level.text = str(chd.level);
	exp_bar.max_value = Calculations.get_exp_to_next_level(chd.level);
	exp_bar.value = chd.exp_to_lvl;
	
	hp_disp.update_bar(chd);
	sp_disp.update_bar(chd);
	for st_disp in stat_disps:
		st_disp.update_bar(chd);
	
	cur_displayed_arts.clear();
	for id in chd.art_ids:
		if id >= 0:
			cur_displayed_arts.append(BattleArt.new(id));
		else:
			cur_displayed_arts.append(null);
	for i in cur_displayed_arts.size():
		art_disps[i].fill_data(cur_displayed_arts[i]);
	
	for i in range(8):
		if chd.level_up_stats[i] > 0 and show_stat_ups:
			stat_up_lbls[i].text = str("+ ", chd.level_up_stats[i]);
			stat_up_lbls[i].visible = true;
		else:
			stat_up_lbls[i].visible = false;
	
	new_art_disp.visible = false;
	new_art_lbl.visible = false;
	return


func update_newart(id: int, selection_visible: bool) -> void:
	if id < 0:
		cur_displayed_newart = null;
		new_art_disp.visible = false;
		new_art_lbl.visible = false;
		art_selector.visible = false;
		return
	
	cur_displayed_newart = BattleArt.new(id);
	new_art_disp.fill_data(cur_displayed_newart);
	new_art_disp.visible = true;
	new_art_lbl.visible = true;
	art_selector.visible = selection_visible;
	return


func update_selection_position(index: int) -> void:
	art_selector.position.y = art_disps[index].position.y;
	return
