extends Control

const HeroPanel = preload("uid://bwycxo8x0hguv");

@onready var active_hero_panels: Array[HeroPanel] = [
	$BattleHeroPanelActive1 as HeroPanel,
	$BattleHeroPanelActive2 as HeroPanel,
	$BattleHeroPanelActive3 as HeroPanel];
@onready var backup_hero_panels: Array[HeroPanel] = [
	$BattleHeroPanelBackup1 as HeroPanel,
	$BattleHeroPanelBackup2 as HeroPanel,
	$BattleHeroPanelBackup3 as HeroPanel,
	$BattleHeroPanelBackup4 as HeroPanel,
	$BattleHeroPanelBackup5 as HeroPanel,
	$BattleHeroPanelBackup6 as HeroPanel,
	$BattleHeroPanelBackup7 as HeroPanel,
	$BattleHeroPanelBackup8 as HeroPanel];

var index_left: int = 0;
var index_right: int = 0;
var left_side: bool = true;


func input_event(event: InputEvent, battle_ui: BattleUI) -> void:
	if event.is_action_pressed("Btn_B"):
		if left_side:
			battle_ui.change_menu_state(battle_ui.MENUSTATE.TACTICS);
		else:
			left_side = true;
			update_selection(0);
		return
	
	if event.is_action_pressed("Btn_A") or event.is_action_pressed("Btn_Y"):
		if left_side:
			left_side = false;
			update_selection(0);
		else:
			if check_switch_valid():
				battle_ui.write_switch_action(index_left, index_right);
		return
	
	if event.is_action_pressed("D_Pad_Down"):
		update_selection(1);
	if event.is_action_pressed("D_Pad_Up"):
		update_selection(-1);
	if event.is_action_pressed("D_Pad_Left") and not left_side:
		update_selection(-4);
	if event.is_action_pressed("D_Pad_Right") and not left_side:
		update_selection(4);
	return


func update_view(battle_scene: BattleScene) -> void:
	for i in battle_scene.active_heros.size():
		active_hero_panels[i].update_view(battle_scene.active_heros[i]);
	
	for i in battle_scene.backup_heros.size():
		backup_hero_panels[i].update_view(battle_scene.backup_heros[i]);
	
	index_left = 0;
	index_right = 0;
	left_side = true;
	update_selection(0);
	return


func update_selection(change: int) -> void:
	if left_side:
		index_left = clampi(index_left + change, 0, 2);
	else:
		index_right = clampi(index_right + change, 0, 7);
	
	for i in active_hero_panels.size():
		active_hero_panels[i].set_selection(i == index_left);
	
	for i in backup_hero_panels.size():
		backup_hero_panels[i].set_selection(i == index_right and not left_side);
	return


func check_switch_valid() -> bool:
	var battle_scene := GameData.main_scene.battle_scene;
	var active_hero := battle_scene.active_heros[index_left];
	var backup_hero := battle_scene.backup_heros[index_right];
	return active_hero and backup_hero and backup_hero.is_defeated == false
