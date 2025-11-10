extends Control

const CharOverview := preload("res://UserInterfaces/Battle/PostBattle/post_battle_character_overview.gd");
const CharLvlup := preload("res://UserInterfaces/Battle/PostBattle/post_battle_character_levelup.gd");

@onready var gameover_ui := $GameOverUI as Control;
@onready var battlewon_ui := $BattleWonUI as Control;

@onready var gameover_lbls: Array[Label] = [
	$GameOverUI/LabelTryAgain as Label,
	$GameOverUI/LabelLoadSave as Label,
	$GameOverUI/LabelTitlescreen as Label];

@onready var exp_overview := $BattleWonUI/ExpOverview as Control;
@onready var lbl_exp_cashout := $BattleWonUI/ExpOverview/LabelExpCashoutValue as Label;
@onready var char_overviews: Array[CharOverview] = [
	$BattleWonUI/ExpOverview/PostBattleCharacterOverview1 as CharOverview,
	$BattleWonUI/ExpOverview/PostBattleCharacterOverview2 as CharOverview,
	$BattleWonUI/ExpOverview/PostBattleCharacterOverview3 as CharOverview,
	$BattleWonUI/ExpOverview/PostBattleCharacterOverview4 as CharOverview,
	$BattleWonUI/ExpOverview/PostBattleCharacterOverview5 as CharOverview,
	$BattleWonUI/ExpOverview/PostBattleCharacterOverview6 as CharOverview,
	$BattleWonUI/ExpOverview/PostBattleCharacterOverview7 as CharOverview,
	$BattleWonUI/ExpOverview/PostBattleCharacterOverview8 as CharOverview];

@onready var lvlup_ui := $BattleWonUI/PostBattleCharacterLevelup as CharLvlup;

var is_gameover: bool = false;
var allow_inputs: bool = false;
var give_exp: bool = false;
var give_exp_finished: bool = false;
var is_showing_overview: bool = true;
var is_learning_art: bool = false;
var allow_art_selection: bool = false;

var idx_gameover: int = 0;
var idx_lvlup: int = 0;
var newart_id: int = -1;
var idx_art_learn: int = 0;

var exp_to_give: int = 0;
var exp_per_second: float = 1;


func _input(event: InputEvent) -> void:
	if !allow_inputs:
		return
	
	if event.is_action_pressed("Btn_Y") or event.is_action_pressed("Btn_A"):
		if is_gameover:
			match idx_gameover:
				0: print("TODO: Retry Battle");
				1: GameData.reload_savefile();
				_: GameData.return_to_titlescreen();
		else:
			if is_showing_overview:
				input_confirm_overview();
			else:
				input_confirm_levelup();
		return
	
	if event.is_action_pressed("Btn_B"):
		if !is_gameover and is_learning_art and allow_art_selection:
			allow_art_selection = false;
			lvlup_ui.update_new_art(newart_id, allow_art_selection);
			GameData.characters[idx_lvlup].learned_art_ids.append(newart_id);
			lvlup_ui.update_view(idx_lvlup, true);
			is_learning_art = false;
		return
	
	if event.is_action_pressed("D_Pad_Up"):
		if is_gameover:
			idx_gameover = maxi(idx_gameover - 1, 0);
			gameover_lbls_selection();
		elif allow_art_selection:
			idx_art_learn = maxi(idx_art_learn - 1, 0);
			lvlup_ui.update_selection_position(idx_art_learn);
		return
	
	if event.is_action_pressed("D_Pad_Down"):
		if is_gameover:
			idx_gameover = mini(idx_gameover + 1, 2);
			gameover_lbls_selection();
		elif allow_art_selection:
			idx_art_learn = mini(idx_art_learn + 1, 7);
			lvlup_ui.update_selection_position(idx_art_learn);
	return


func input_confirm_overview() -> void:
	if give_exp_finished:
		is_showing_overview = false;
		exp_overview.visible = false;
		lvlup_ui.visible = true;
		if get_next_levelup_char() == false:
			GameData.main_scene.end_battle_scene();
		else:
			lvlup_ui.update_view(idx_lvlup, true);
	else:
		give_exp = true;
	return


func input_confirm_levelup() -> void:
	var character := GameData.characters[idx_lvlup];
	
	if is_learning_art:
		allow_art_selection = false;
		lvlup_ui.update_new_art(newart_id, allow_art_selection);
		character.learn_art(newart_id, idx_art_learn);
		lvlup_ui.update_view(idx_lvlup, true);
		is_learning_art = false;
		return
	
	if character.level_up_art_ids.size() > 0:
		newart_id = character.level_up_art_ids[0];
		character.level_up_art_ids.remove_at(0);
		
		is_learning_art = true;
		var num_arts: int = character.get_number_of_arts();
		allow_art_selection = num_arts >= character.art_ids.size();
		idx_art_learn = 0 if allow_art_selection else num_arts;
		
		lvlup_ui.update_new_art(newart_id, allow_art_selection);
		return
	
	if get_next_levelup_char() == false:
		GameData.main_scene.end_battle_scene();
	else:
		lvlup_ui.update_view(idx_lvlup, true);
	return


func _process(delta: float) -> void:
	if give_exp:
		var exp_tick := ceili(exp_per_second * delta);
		exp_give_update(exp_tick);
	return


func init_ui(battle_lost: bool, exp_cashout: int) -> void:
	AudioManager.play_battle_music(-1);
	process_mode = Node.PROCESS_MODE_ALWAYS;
	visible = true;
	allow_inputs = true;
	
	if battle_lost:
		is_gameover = true;
		gameover_ui.visible = true;
		battlewon_ui.visible = false;
		gameover_lbls_selection();
	else:
		gameover_ui.visible = false;
		battlewon_ui.visible = true;
		exp_overview.visible = true;
		lvlup_ui.visible = false;
		
		exp_to_give = exp_cashout;
		exp_per_second = exp_cashout / 2.5;
		lbl_exp_cashout.text = str(exp_to_give);
		for i in GameData.characters.size():
			if GameData.characters[i] == null:
				char_overviews[i].visible = false;
			else:
				char_overviews[i].update_full(GameData.characters[i]);
	return


func gameover_lbls_selection() -> void:
	for i in gameover_lbls.size():
		gameover_lbls[i].modulate = Color.CRIMSON if i == idx_gameover else Color.WHITE;
	return


func exp_give_update(expierence: int) -> void:
	if exp_to_give - expierence < 0:
		expierence = exp_to_give;
	
	exp_to_give -= expierence;
	lbl_exp_cashout.text = str(exp_to_give);
	
	for i in GameData.characters.size():
		var character := GameData.characters[i];
		if character != null:
			var result := character.reciece_exp(expierence);
			if result:
				char_overviews[i].set_level_up();
				char_overviews[i].update_full(GameData.characters[i]);
			else:
				char_overviews[i].update_continous(GameData.characters[i]);
	
	if exp_to_give <= 0:
		give_exp = false;
		give_exp_finished = true;
	return


func get_next_levelup_char() -> bool:
	newart_id = -1;
	
	while idx_lvlup < GameData.characters.size():
		var character := GameData.characters[idx_lvlup];
		if character and character.level_ups > 0:
			character.apply_level_ups();
			return true
		idx_lvlup += 1;
	return false
