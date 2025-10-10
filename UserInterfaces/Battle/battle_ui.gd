class_name BattleUI
extends Control

signal close_analyze();

const BattleActionMain = preload("uid://bmwt4jiw4oreg")

const HeroDisplay := preload("res://UserInterfaces/Battle/Displays/battle_hero_display.gd");
const OppoDisplay := preload("res://UserInterfaces/Battle/Displays/battle_opponent_display.gd");
const ArtsMenu := preload("res://UserInterfaces/Battle/ActionMenu/battle_action_arts.gd");
const ItemsMenu := preload("res://UserInterfaces/Battle/ActionMenu/battle_action_items.gd");
const TacticsMenu := preload("res://UserInterfaces/Battle/ActionMenu/battle_action_tactics.gd");
const InspectMenu := preload("res://UserInterfaces/Battle/ActionMenu/battle_character_inspect.gd");
const DmgNumber := preload("res://UserInterfaces/Battle/Displays/damage_number_label.gd");

const tactic_decriptions: Array[StringName] = [
	"Inspect characters on the field",
	"Analyze an opponent to gain information about them",
	"Switch an active Partymember with a Backup",
	"Run from Battle"];

enum MENUSTATE {OFF, MAIN, ARTS, ITEMS, TACTICS, TARGETING, INSPECT}

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
@onready var battle_menu_main := $BattleActionMain as BattleActionMain;
@onready var battle_menu_arts := $BattleActionArts as ArtsMenu;
@onready var battle_menu_items := $BattleActionItems as ItemsMenu;
@onready var battle_menu_tactics := $BattleActionTactics as TacticsMenu;
@onready var battle_menu_inspect := $BattleCharacterInspect as InspectMenu;
@onready var lbl_description := $LabelDescription as Label;
@onready var lbl_action_name := $LabelActionName as Label;
@onready var dmg_numbers := $DamageNumbers as Control;

var battle_scene: BattleScene;
var cur_action: ActionData = null;
var menu_state := MENUSTATE.OFF;
var prev_menu_state := MENUSTATE.OFF;
var accept_inputs: bool = false;

var index_main: int = 0;
var index_arts: int = 0;
var index_items: int = 0;
var index_tactics: int = 0;

var inspect_as_analyze: bool = false;


func _ready() -> void:
	change_menu_state(MENUSTATE.OFF);
	return


func _input(event: InputEvent) -> void:
	if !accept_inputs:
		return
	
	match menu_state:
		MENUSTATE.MAIN:
			input_main(event);
		MENUSTATE.ARTS:
			input_arts(event);
		MENUSTATE.ITEMS:
			input_items(event);
		MENUSTATE.TACTICS:
			input_tactics(event);
		MENUSTATE.TARGETING:
			input_targeting(event);
		MENUSTATE.INSPECT:
			input_inspect(event);
		_:
			input_targeting(event); # TEMP
	return


func input_main(event: InputEvent) -> void:
	if event.is_action_pressed("D_Pad_Up"):
		index_main = maxi(index_main - 1, 0);
		battle_menu_main.change_rotation(index_main);
		update_description(battle_menu_main.get_description_text(index_main));
	
	if event.is_action_pressed("D_Pad_Down"):
		index_main = mini(index_main + 1, 5);
		battle_menu_main.change_rotation(index_main);
		update_description(battle_menu_main.get_description_text(index_main));
	
	
	if event.is_action_pressed("Btn_Y"):
		match index_main:
			0: # ATTACK
				cur_action = ActionData.new(ActionData.ACTIONTYPE.ATTACK, battle_scene);
				cur_action.set_targettype_from_art(battle_scene.cur_actor.default_attack);
				update_description(battle_scene.cur_actor.default_attack.description);
				change_menu_state(MENUSTATE.TARGETING);
			
			1: # ARTS
				change_menu_state(MENUSTATE.ARTS);
			
			2: # ULT
				if battle_scene.cur_actor.ult_points < 100:
					print("Not enough ult points!");
					return
				if battle_scene.cur_actor.ailment == Ailments.SHACKLED:
					print(battle_scene.cur_actor.name, " is shackled -> Ult cannot be used!");
					return
				cur_action = ActionData.new(ActionData.ACTIONTYPE.ULT, battle_scene);
				cur_action.set_targettype_from_art(battle_scene.cur_actor.ult_art);
				update_description(battle_scene.cur_actor.ult_art.description);
				change_menu_state(MENUSTATE.TARGETING);
			
			3: # BLOCK
				cur_action = ActionData.new(ActionData.ACTIONTYPE.BLOCK, battle_scene);
				cur_action.set_targettype(ActionData.TARGETTYPE.SELF_ONLY);
				update_description("Reduce damage until next turn");
				change_menu_state(MENUSTATE.TARGETING);
				return
			
			4: # ITEMS
				if battle_menu_items.consumables.size() > 0:
					change_menu_state(MENUSTATE.ITEMS);
				else:
					print("NO ITEMS AVAILABLE...");
			
			5: # TACTICS
				change_menu_state(MENUSTATE.TACTICS);
	return


func input_targeting(event: InputEvent) -> void:
	if event.is_action_pressed("Btn_Y"):
		if cur_action.is_inspect_action():
			change_menu_state(MENUSTATE.INSPECT);
			return
		change_menu_state(MENUSTATE.OFF);
		battle_scene.commit_action(cur_action);
		return
	
	if event.is_action_pressed("Btn_B"):
		cur_action = null;
		change_menu_state(prev_menu_state);
		return
	
	if event.is_action_pressed("D_Pad_Left") or event.is_action_pressed("D_Pad_Up"):
		cur_action.previous_target();
		set_display_selection();
		battle_scene.update_camera_targeting(cur_action);
		return
	
	if event.is_action_pressed("D_Pad_Right") or event.is_action_pressed("D_Pad_Down"):
		cur_action.next_target();
		set_display_selection();
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
		update_description(battle_scene.cur_actor.arts[index_arts].description);
		battle_menu_arts.update_selector(index_arts);
		return
	
	if event.is_action_pressed("D_Pad_Down"):
		index_arts = mini(index_arts + 1, battle_scene.cur_actor.get_max_arts() - 1);
		update_description(battle_scene.cur_actor.arts[index_arts].description);
		battle_menu_arts.update_selector(index_arts);
	return


func input_items(event: InputEvent) -> void:
	if event.is_action_pressed("Btn_B"):
		cur_action = null;
		change_menu_state(MENUSTATE.MAIN);
		return
	
	if event.is_action_pressed("Btn_Y"):
		cur_action = ActionData.new(ActionData.ACTIONTYPE.ITEM, battle_scene);
		cur_action.set_targettype_from_item(battle_menu_items.get_item_obj(index_items));
		change_menu_state(MENUSTATE.TARGETING);
		return
	
	if event.is_action_pressed("D_Pad_Up"):
		index_items = maxi(index_items - 1, 0);
		update_description(battle_menu_items.get_item_description(index_items));
		battle_menu_items.set_index(index_items);
		return
	
	if event.is_action_pressed("D_Pad_Down"):
		index_items = mini(index_items + 1, battle_menu_items.consumables.size() - 1);
		update_description(battle_menu_items.get_item_description(index_items));
		battle_menu_items.set_index(index_items);
	return


func input_tactics(event: InputEvent) -> void:
	if event.is_action_pressed("Btn_B"):
		change_menu_state(MENUSTATE.MAIN);
		return
	
	if event.is_action_pressed("Btn_Y"):
		match index_tactics:
			0:
				cur_action = ActionData.new(ActionData.ACTIONTYPE.INSPECT, battle_scene);
				cur_action.set_targettype(ActionData.TARGETTYPE.SINGLE_EVERYONE);
				change_menu_state(MENUSTATE.TARGETING);
			1:
				cur_action = ActionData.new(ActionData.ACTIONTYPE.ANALYZE, battle_scene);
				cur_action.set_targettype(ActionData.TARGETTYPE.SINGLE_OPPONENT);
				change_menu_state(MENUSTATE.TARGETING);
			3:
				for hero in battle_scene.active_heros:
					hero.write_back_character_data();
				GameData.main_scene.end_battle_scene();
			_:
				print("TODO")
		return
	
	if event.is_action_pressed("D_Pad_Up"):
		index_tactics = maxi(index_tactics - 1, 0);
		update_description(tactic_decriptions[index_tactics]);
		battle_menu_tactics.update_selector(index_tactics);
		return
	
	if event.is_action_pressed("D_Pad_Down"):
		index_tactics = mini(index_tactics + 1, 3);
		update_description(tactic_decriptions[index_tactics]);
		battle_menu_tactics.update_selector(index_tactics);
	return


func input_inspect(event: InputEvent) -> void:
	if event.is_action_pressed("Btn_B"):
		if inspect_as_analyze:
			inspect_as_analyze = false;
			change_menu_state(MENUSTATE.OFF);
			close_analyze.emit();
			return
		
		if cur_action.is_inspect_action():
			change_menu_state(MENUSTATE.MAIN);
		return
	
	if event.is_action_pressed("Btn_Y"):
		print("TODO, INSPECT")
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
	if prev_menu_state == MENUSTATE.TARGETING and new_state != MENUSTATE.INSPECT:
		reset_display_selection();
		battle_scene.update_camera_targeting(null);
	
	menu_state = new_state;
	battle_menu_main.visible = menu_state == MENUSTATE.MAIN;
	battle_menu_arts.visible = menu_state == MENUSTATE.ARTS;
	battle_menu_items.visible = menu_state == MENUSTATE.ITEMS;
	battle_menu_tactics.visible = menu_state == MENUSTATE.TACTICS;
	battle_menu_inspect.visible = menu_state == MENUSTATE.INSPECT;
	lbl_description.visible = menu_state != MENUSTATE.OFF;
	accept_inputs = menu_state != MENUSTATE.OFF;
	
	if menu_state != MENUSTATE.OFF:
		lbl_action_name.visible = false;
	
	match new_state:
		MENUSTATE.OFF:
			reset_display_selection();
		MENUSTATE.MAIN:
			cur_action = null;
			battle_scene.update_camera_targeting(null);
			update_description(battle_menu_main.get_description_text(index_main));
		MENUSTATE.ARTS:
			battle_menu_arts.update_ui(battle_scene.cur_actor);
			battle_menu_arts.update_selector(index_arts);
			update_description(battle_scene.cur_actor.arts[index_arts].description);
		MENUSTATE.ITEMS:
			index_items = 0;
			battle_menu_items.set_index(0);
			update_description(battle_menu_items.get_item_description(index_items));
		MENUSTATE.TACTICS:
			update_description(tactic_decriptions[index_tactics]);
		MENUSTATE.TARGETING:
			set_display_selection();
			battle_scene.update_camera_targeting(cur_action);
		MENUSTATE.INSPECT:
			if inspect_as_analyze:
				battle_menu_inspect.load_character_data(cur_action.targets[0]);
			else:
				battle_menu_inspect.load_character_data(get_battledata_from_idx(cur_action.index_target));
	return


func on_hero_turn_start() -> void:
	index_main = 0;
	index_arts = 0;
	index_items = 0;
	index_tactics = 0;
	
	battle_menu_main.change_rotation(index_main);
	battle_menu_items.prepare_view();
	
	change_menu_state(MENUSTATE.MAIN);
	return


func update_description(text: String) -> void:
	lbl_description.text = text;
	return


func set_display_selection() -> void:
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
		
		cur_action.TARGETTYPE.SINGLE_EVERYONE:
			for i in range(hero_displays.size()):
				hero_displays[i].set_selection(i == cur_action.index_target);
			for i in range(oppo_displays.size()):
				oppo_displays[i].set_selection(i == cur_action.index_target - 3);
		_:
			pass
	return


func reset_display_selection() -> void:
	for i in range(hero_displays.size()):
		hero_displays[i].set_selection(false);
	for i in range(oppo_displays.size()):
		oppo_displays[i].set_selection(false);
	return


func get_battledata_from_idx(index) -> BattleData:
	if index < 3:
		return battle_scene.active_heros[index]
	return battle_scene.opponents[index - 3];
 

func prepare_after_analyze() -> void:
	inspect_as_analyze = true;
	change_menu_state(MENUSTATE.INSPECT);
	return


func create_damage_number(action_result: ActionResult, target: BattleData, art: BattleArt) -> void:
	var world_pos := target.battle_char.global_position + Vector3.UP;
	var cur_camera := get_viewport().get_camera_3d();
	if cur_camera.is_position_behind(world_pos):
		return
	
	var number_node := preload("res://UserInterfaces/Battle/Displays/damage_number_label.tscn").instantiate() as DmgNumber;
	var screen_pos := get_viewport().get_camera_3d().unproject_position(world_pos);
	get_viewport().get_camera_3d()
	dmg_numbers.add_child(number_node);
	number_node.set_text_data(action_result, screen_pos, art);
	return
