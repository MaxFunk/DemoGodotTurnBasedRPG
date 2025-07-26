class_name BattleUI
extends Control

const HeroDisplay := preload("res://UserInterfaces/Battle/Displays/battle_hero_display.gd");
const OppoDisplay := preload("res://UserInterfaces/Battle/Displays/battle_opponent_display.gd");
const ArtsMenu := preload("res://UserInterfaces/Battle/ActionMenu/battle_action_arts.gd");
enum MENUSTATE {OFF, MAIN, ARTS, ITEMS, TACTICS, TARGETING}

@onready var hero_displays: Array[HeroDisplay] = [
	$DataDisplays/BattleHeroDisplay1 as HeroDisplay,
	$DataDisplays/BattleHeroDisplay2 as HeroDisplay,
	$DataDisplays/BattleHeroDisplay3 as HeroDisplay];
@onready var oppo_displays: Array[OppoDisplay] = [
	$DataDisplays/BattleOpponentDisplay1 as OppoDisplay,
	$DataDisplays/BattleOpponentDisplay2 as OppoDisplay,
	$DataDisplays/BattleOpponentDisplay3 as OppoDisplay,
	$DataDisplays/BattleOpponentDisplay4 as OppoDisplay,
	$DataDisplays/BattleOpponentDisplay5 as OppoDisplay];
@onready var battle_menu_main := $BattleActionMain as Control;
@onready var battle_menu_arts := $BattleActionArts as ArtsMenu;

var battle_scene: BattleScene;
var cur_action: ActionData = null;
var menu_state := MENUSTATE.OFF;
var prev_menu_state := MENUSTATE.OFF;
var accept_inputs: bool = false;

var index_arts: int = 0;
var index_items: int = 0;
var index_tactics: int = 0;


func _input(event: InputEvent) -> void:
	if !accept_inputs:
		return
	
	match menu_state:
		MENUSTATE.MAIN:
			input_main(event);
		MENUSTATE.ARTS:
			input_arts(event);
		MENUSTATE.TARGETING:
			input_targeting(event);
		_:
			input_targeting(event); # TEMP
	return


func input_main(event: InputEvent) -> void:
	if event.is_action_pressed("Btn_Y"):
		cur_action = ActionData.new(ActionData.ACTIONTYPE.ATTACK, battle_scene);
		cur_action.set_targettype_from_art(battle_scene.cur_actor.default_attack);
		change_menu_state(MENUSTATE.TARGETING);
		return
	
	if event.is_action_pressed("Btn_X"):
		change_menu_state(MENUSTATE.ARTS);
		return
	
	if event.is_action_pressed("Btn_B"):
		cur_action = ActionData.new(ActionData.ACTIONTYPE.BLOCK, battle_scene);
		cur_action.set_targettype(ActionData.TARGETTYPE.SELF_ONLY);
		change_menu_state(MENUSTATE.TARGETING);
		return
	
	if event.is_action_pressed("Btn_A"):
		if battle_scene.cur_actor.ult_points < 100:
			print("Not enough ult points!");
			return
		if battle_scene.cur_actor.ailment == Ailments.SHACKLED:
			print(battle_scene.cur_actor.name, " is shackled -> Ult cannot be used!");
			return
		cur_action = ActionData.new(ActionData.ACTIONTYPE.ULT, battle_scene);
		cur_action.set_targettype_from_art(battle_scene.cur_actor.ult_art);
		change_menu_state(MENUSTATE.TARGETING);
		return
	
	if event.is_action_pressed("Start"):
		#var action := ActionData.new(ActionData.ACTIONTYPE.ITEM);
		#action.target_type = ActionData.TARGETTYPE.SINGLE_OPPONENT; # TODO
		#battle_scene.cur_action = action;
		change_menu_state(MENUSTATE.ITEMS);
		return
	
	if event.is_action_pressed("Select"):
		#var action := ActionData.new(ActionData.ACTIONTYPE.TACTIC);
		#action.target_type = ActionData.TARGETTYPE.SELF_ONLY;
		#battle_scene.cur_action = action;
		change_menu_state(MENUSTATE.TACTICS);
	return


func input_targeting(event: InputEvent) -> void:
	if event.is_action_pressed("Btn_Y"):
		change_menu_state(MENUSTATE.OFF);
		battle_scene.commit_action(cur_action);
		cur_action = null; # optional?
		return
	
	if event.is_action_pressed("Btn_B"):
		cur_action = null;
		change_menu_state(prev_menu_state);
		return
	
	if event.is_action_pressed("D_Pad_Left") or event.is_action_pressed("D_Pad_Up"):
		cur_action.previous_target();
		set_target_arrows();
		battle_scene.update_camera_targeting(cur_action);
		return
	
	if event.is_action_pressed("D_Pad_Right") or event.is_action_pressed("D_Pad_Down"):
		cur_action.next_target();
		set_target_arrows();
		battle_scene.update_camera_targeting(cur_action);
	return


func input_arts(event: InputEvent) -> void:
	if event.is_action_pressed("Btn_Y"):
		var cur_actor := battle_scene.cur_actor;
		if cur_actor.ailment == Ailments.SHACKLED:
			print(battle_scene.cur_actor.name, " is shackled -> No Arts can be used!");
			return
		
		var art := cur_actor.arts[index_arts];
		if art.is_passive_art():
			print("Cannot use passive Art!");
			return
		
		var sp_cost: int = art.sp_cost * 2 if cur_actor.ailment == Ailments.EXHAUSTED else art.sp_cost;
		if art.sp_cost > cur_actor.sp_cur:
			print("Not enough SP to use Art!");
			return
		
		cur_action = ActionData.new(ActionData.ACTIONTYPE.ART, battle_scene);
		cur_action.set_targettype_from_art(art);
		change_menu_state(MENUSTATE.TARGETING);
		return
	
	if event.is_action_pressed("Btn_B"):
		cur_action = null;
		change_menu_state(MENUSTATE.MAIN);
		return
	
	if event.is_action_pressed("D_Pad_Up"):
		index_arts = maxi(index_arts - 1, 0);
		battle_menu_arts.update_selector(index_arts);
		return
	
	if event.is_action_pressed("D_Pad_Down"):
		index_arts = mini(index_arts + 1, battle_scene.cur_actor.get_max_arts() - 1);
		battle_menu_arts.update_selector(index_arts);
	return


func init_battle_ui(battle_sc: BattleScene) -> void:
	battle_scene = battle_sc;
	for i in range(3):
		hero_displays[i].update_init(battle_scene.active_heros[i]);
		hero_displays[i].set_selection(false);
	for i in range(5):
		oppo_displays[i].update_init(battle_scene.opponents[i]);
		oppo_displays[i].set_selection(false);
	return


func change_menu_state(new_state: MENUSTATE) -> void:
	prev_menu_state = menu_state;
	if prev_menu_state == MENUSTATE.TARGETING:
		reset_target_arrows();
		battle_scene.update_camera_targeting(null);
	
	menu_state = new_state;
	match new_state:
		MENUSTATE.OFF:
			reset_target_arrows();
			battle_menu_main.visible = false;
			battle_menu_arts.visible = false;
		MENUSTATE.MAIN:
			battle_menu_main.visible = true;
			battle_menu_arts.visible = false;
		MENUSTATE.ARTS:
			battle_menu_arts.update_ui(battle_scene.cur_actor);
			battle_menu_arts.update_selector(index_arts);
			battle_menu_main.visible = false;
			battle_menu_arts.visible = true;
		MENUSTATE.ITEMS:
			battle_menu_main.visible = false;
			battle_menu_arts.visible = false;
		MENUSTATE.TACTICS:
			battle_menu_main.visible = false;
			battle_menu_arts.visible = false;
		MENUSTATE.TARGETING:
			set_target_arrows();
			battle_scene.update_camera_targeting(cur_action);
			battle_menu_main.visible = false;
			battle_menu_arts.visible = false;
	return


func on_hero_turn_start() -> void:
	change_menu_state(MENUSTATE.MAIN);
	return


func set_target_arrows() -> void:
	if !cur_action:
		return
	
	match cur_action.target_type:
		cur_action.TARGETTYPE.SINGLE_OPPONENT:
			for i in range(oppo_displays.size()):
				oppo_displays[i].set_selection(i == cur_action.index_target);
		
		cur_action.TARGETTYPE.SINGLE_ALLY, cur_action.TARGETTYPE.SELF_ONLY:
			for i in range(hero_displays.size()):
				hero_displays[i].set_selection(i == cur_action.index_target);
		
		cur_action.TARGETTYPE.ALL_OPPONENTS:
			for i in range(oppo_displays.size()):
				oppo_displays[i].set_selection(true);
		
		cur_action.TARGETTYPE.ALL_ALLIES:
			for i in range(hero_displays.size()):
				hero_displays[i].set_selection(true);
		
		cur_action.TARGETTYPE.ALL:
			for i in range(hero_displays.size()):
				hero_displays[i].set_selection(true);
			for i in range(oppo_displays.size()):
				oppo_displays[i].set_selection(true);
		_:
			pass
	return


func reset_target_arrows() -> void:
	for i in range(hero_displays.size()):
		hero_displays[i].set_selection(false);
	for i in range(oppo_displays.size()):
		oppo_displays[i].set_selection(false);
	return


# TODO: Detail Menu + Analyze (Tactic) + Flee Battle (Tactic)
# -> In character menu (out of battle): Show Weak/Res/Block in Menu!
# --> CharacterData needs these attributes ( + save / init data)
# ---> Also copy when loading from characterdata into battledata
