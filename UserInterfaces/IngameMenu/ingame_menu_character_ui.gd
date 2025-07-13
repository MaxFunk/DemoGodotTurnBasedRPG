extends Control

const HpSpDisplay := preload("res://UserInterfaces/IngameMenu/Subscenes/hp_sp_display.gd");
const StatDisplay := preload("res://UserInterfaces/IngameMenu/Subscenes/stat_display.gd");
const ArtDisplay := preload("res://UserInterfaces/IngameMenu/Subscenes/battle_art_display.gd");

@onready var tab_btns: Array[LabelButton] = [
	$TabBar/LabelButtonTab0 as LabelButton,
	$TabBar/LabelButtonTab1 as LabelButton,
	$TabBar/LabelButtonTab2 as LabelButton,
	$TabBar/LabelButtonTab3 as LabelButton,
	$TabBar/LabelButtonTab4 as LabelButton,
	$TabBar/LabelButtonTab5 as LabelButton,
	$TabBar/LabelButtonTab6 as LabelButton,
	$TabBar/LabelButtonTab7 as LabelButton];
@onready var char_portrait := $ContentControl/LeftColumn/CharPortrait as TextureRect;
@onready var lbl_level := $ContentControl/LeftColumn/LabelLevelData as Label;
@onready var lbl_tot_exp := $ContentControl/LeftColumn/LabelTotalExpData as Label;
@onready var lbl_next_exp := $ContentControl/LeftColumn/LabelNextExpData as Label;
@onready var exp_bar := $ContentControl/LeftColumn/ExpBar as TextureProgressBar;
@onready var hp_disp := $ContentControl/MiddleColumn/HpDisplay as HpSpDisplay;
@onready var sp_disp := $ContentControl/MiddleColumn/SpDisplay as HpSpDisplay;
@onready var stat_disps: Array[StatDisplay] = [
	$ContentControl/MiddleColumn/StatDisplay1 as StatDisplay,
	$ContentControl/MiddleColumn/StatDisplay2 as StatDisplay,
	$ContentControl/MiddleColumn/StatDisplay3 as StatDisplay,
	$ContentControl/MiddleColumn/StatDisplay4 as StatDisplay,
	$ContentControl/MiddleColumn/StatDisplay5 as StatDisplay,
	$ContentControl/MiddleColumn/StatDisplay6 as StatDisplay];
@onready var ult_disp := $ContentControl/RightColumn/BattleArtDisplayUlt as ArtDisplay;
@onready var art_disps: Array[ArtDisplay] = [
	$ContentControl/RightColumn/BattleArtDisplay1 as ArtDisplay,
	$ContentControl/RightColumn/BattleArtDisplay2 as ArtDisplay,
	$ContentControl/RightColumn/BattleArtDisplay3 as ArtDisplay,
	$ContentControl/RightColumn/BattleArtDisplay4 as ArtDisplay,
	$ContentControl/RightColumn/BattleArtDisplay5 as ArtDisplay,
	$ContentControl/RightColumn/BattleArtDisplay6 as ArtDisplay,
	$ContentControl/RightColumn/BattleArtDisplay7 as ArtDisplay];

var tab_index: int = 0;
var max_tab_index: int = 7;
var characters: Array[CharacterData] = [];
var cur_displayed_ult: BattleArt;
var cur_displayed_arts: Array[BattleArt] = [];

# Handles inputs, returns true if this UI should be closed by parents
func input_event(event: InputEvent) -> bool:
	if event.is_action_pressed("Btn_B"):
		characters.clear();
		return true;
	
	if event.is_action_pressed("Btn_Y") or event.is_action_pressed("Btn_A"):
		print("TODO IN CHARACTERS");
	
	if event.is_action_pressed("L"):
		tab_btns[tab_index].clear_hovered();
		tab_index = maxi(tab_index - 1, 0);
		tab_btns[tab_index].set_hovered();
		load_character_data(tab_index);
	
	if event.is_action_pressed("R"):
		tab_btns[tab_index].clear_hovered();
		tab_index = mini(tab_index + 1, max_tab_index);
		tab_btns[tab_index].set_hovered();
		load_character_data(tab_index);
	return false


func prepare_view() -> void:
	GameData.get_characters_only(characters);
	max_tab_index = characters.size() - 1;
	
	for i in range(tab_btns.size()):
		if i <= max_tab_index:
			tab_btns[i].visible = true;
			tab_btns[i].text = characters[i].name;
		else:
			tab_btns[i].visible = false;
	
	tab_btns[tab_index].clear_hovered();
	tab_index = 0;
	tab_btns[tab_index].set_hovered();
	
	load_character_data(tab_index);
	return


func load_character_data(index: int) -> void:
	var chd := characters[index];
	char_portrait.texture = ResourceManager.get_hero_portrait(chd.id);
	lbl_level.text = str(chd.level);
	lbl_tot_exp.text = str(chd.total_exp);
	exp_bar.max_value = Calculations.get_exp_to_next_level(chd.level);
	exp_bar.value = chd.exp_to_lvl;
	lbl_next_exp.text = str(int(exp_bar.max_value) - chd.exp_to_lvl);
	
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
	
	cur_displayed_ult = BattleArt.new(chd.ult_id) if chd.ult_id >= 0 else null;
	ult_disp.fill_data(cur_displayed_ult);
	return
