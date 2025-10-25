extends Control

const HpSpDisplay := preload("uid://dudprjba6ha0n");
const StatDisplay := preload("uid://ct3qrk8k2otmi");
const ArtDisplay := preload("uid://dfs2yk165bs6o");
const art_disp_scene := preload("uid://bywy76777k33t");

enum VIEWMODE {MAIN, ARTS, ABILITY}

@onready var cd_dir := $CooldownDirectional as Timer;
@onready var tab_btns: Array[LabelButton] = [
	$TabBar/LabelButtonTab0 as LabelButton,
	$TabBar/LabelButtonTab1 as LabelButton,
	$TabBar/LabelButtonTab2 as LabelButton,
	$TabBar/LabelButtonTab3 as LabelButton,
	$TabBar/LabelButtonTab4 as LabelButton,
	$TabBar/LabelButtonTab5 as LabelButton,
	$TabBar/LabelButtonTab6 as LabelButton,
	$TabBar/LabelButtonTab7 as LabelButton];

@onready var main_view := $MainView as Control;
@onready var char_portrait := $MainView/LeftColumn/CharPortrait as TextureRect;
@onready var lbl_level := $MainView/LeftColumn/LabelLevelData as Label;
@onready var lbl_tot_exp := $MainView/LeftColumn/LabelTotalExpData as Label;
@onready var lbl_next_exp := $MainView/LeftColumn/LabelNextExpData as Label;
@onready var exp_bar := $MainView/LeftColumn/ExpBar as TextureProgressBar;
@onready var hp_disp := $MainView/MiddleColumn/HpDisplay as HpSpDisplay;
@onready var sp_disp := $MainView/MiddleColumn/SpDisplay as HpSpDisplay;
@onready var stat_disps: Array[StatDisplay] = [
	$MainView/MiddleColumn/StatDisplay1 as StatDisplay,
	$MainView/MiddleColumn/StatDisplay2 as StatDisplay,
	$MainView/MiddleColumn/StatDisplay3 as StatDisplay,
	$MainView/MiddleColumn/StatDisplay4 as StatDisplay,
	$MainView/MiddleColumn/StatDisplay5 as StatDisplay,
	$MainView/MiddleColumn/StatDisplay6 as StatDisplay];
@onready var art_disps: Array[ArtDisplay] = [
	$MainView/RightColumn/BattleArtDisplay1 as ArtDisplay,
	$MainView/RightColumn/BattleArtDisplay2 as ArtDisplay,
	$MainView/RightColumn/BattleArtDisplay3 as ArtDisplay,
	$MainView/RightColumn/BattleArtDisplay4 as ArtDisplay,
	$MainView/RightColumn/BattleArtDisplay5 as ArtDisplay,
	$MainView/RightColumn/BattleArtDisplay6 as ArtDisplay,
	$MainView/RightColumn/BattleArtDisplay7 as ArtDisplay,
	$MainView/RightColumn/BattleArtDisplay8 as ArtDisplay];
@onready var marker_attr_icons: Array[Control] = [
	$MainView/BottomRow/MarkerIconsWeak as Control,
	$MainView/BottomRow/MarkerIconsResist as Control,
	$MainView/BottomRow/MarkerIconsBlock as Control];

@onready var arts_view := $ArtsView as Control;
@onready var arts_list: Array[ArtDisplay] = [
	$ArtsView/LeftColumn/BattleArtDisplay1 as ArtDisplay,
	$ArtsView/LeftColumn/BattleArtDisplay2 as ArtDisplay,
	$ArtsView/LeftColumn/BattleArtDisplay3 as ArtDisplay,
	$ArtsView/LeftColumn/BattleArtDisplay4 as ArtDisplay,
	$ArtsView/LeftColumn/BattleArtDisplay5 as ArtDisplay,
	$ArtsView/LeftColumn/BattleArtDisplay6 as ArtDisplay,
	$ArtsView/LeftColumn/BattleArtDisplay7 as ArtDisplay,
	$ArtsView/LeftColumn/BattleArtDisplay8 as ArtDisplay];
@onready var arts_selector := $ArtsView/LeftColumn/Selection as Panel;
@onready var arts_selector_swap := $ArtsView/LeftColumn/SelectionSwap as Panel;
@onready var detail_ctrl := $ArtsView/DetailControl as Control;
@onready var arts_name := $ArtsView/DetailControl/ArtName as Label;
@onready var arts_category := $ArtsView/DetailControl/ArtCategory as Label;
@onready var arts_icon_category := $ArtsView/DetailControl/IconCategory as TextureRect;
@onready var arts_icon_attr_1 := $ArtsView/DetailControl/IconAttribute1 as TextureRect;
@onready var arts_icon_attr_2 := $ArtsView/DetailControl/IconAttribute2 as TextureRect;
@onready var arts_strength := $ArtsView/DetailControl/ArtStrengthValue as Label;
@onready var arts_amounts := $ArtsView/DetailControl/ArtStrengthAmount as Label;
@onready var arts_cost := $ArtsView/DetailControl/ArtCostValue as Label;
@onready var arts_cost_type := $ArtsView/DetailControl/ArtCostType as Label;
@onready var arts_description := $ArtsView/DetailControl/Description as Label;
@onready var relearn_ctrl := $ArtsView/RightColumn as Control;
@onready var relearn_selection := $ArtsView/RightColumn/Selection as Panel;
@onready var relearn_scroll_ctrl := $ArtsView/RightColumn/ScrollControl as ScrollControl;

@onready var ability_view := $AbilityView as Control;

var view_mode := VIEWMODE.MAIN;
var tab_index: int = 0;
var max_tab_index: int = 7;
var arts_index: int = 0;
var swap_index: int = -1;
var swap_arts: bool = false;
var relearn_art: bool = false;

var characters: Array[CharacterData] = [];
var displayed_arts: Array[BattleArt] = [];
var learned_arts: Array[BattleArt] = [];
var texture_rects: Array[TextureRect] = [];

# Handles inputs, returns true if this UI should be closed by parents
func input_event(event: InputEvent) -> bool:
	match view_mode:
		VIEWMODE.MAIN:
			return input_event_main(event);
		VIEWMODE.ARTS:
			return input_event_arts(event);
		VIEWMODE.ABILITY:
			return input_event_ability(event);
	return false


func input_event_main(event: InputEvent) -> bool:
	if event.is_action_pressed("Btn_B"):
		characters.clear();
		return true;
	
	if event.is_action_pressed("Btn_Y") or event.is_action_pressed("Btn_A"):
		change_view_mode(VIEWMODE.ARTS);
	
	if event.is_action_pressed("Btn_X"):
		change_view_mode(VIEWMODE.ABILITY);
	
	if event.is_action_pressed("L"):
		change_tab_index(-1);
	
	if event.is_action_pressed("R"):
		change_tab_index(1);
	return false


func input_event_arts(event: InputEvent) -> bool:
	if event.is_action_pressed("Btn_B"):
		if swap_arts:
			change_swap_mode(false, false);
		elif relearn_art:
			change_relearn_mode(false);
		else:
			change_view_mode(VIEWMODE.MAIN);
	
	if event.is_action_pressed("Btn_Y") or event.is_action_pressed("Btn_A"):
		if swap_arts:
			change_swap_mode(false, true);
		elif relearn_art:
			characters[tab_index].relearn_art(arts_index, relearn_scroll_ctrl.idx_selected);
			load_character_data(tab_index);
			change_relearn_mode(false);
		else:
			change_swap_mode(true, false);
	
	if event.is_action_pressed("Btn_X"):
		if swap_arts:
			characters[tab_index].remove_art(arts_index);
			load_character_data(tab_index);
			change_swap_mode(false, false);
		elif relearn_art:
			change_relearn_mode(false);
		else:
			change_relearn_mode(true);
	return false


func input_event_ability(event: InputEvent) -> bool:
	if event.is_action_pressed("Btn_B"):
		change_view_mode(VIEWMODE.MAIN);
	return false


func _process(_delta: float) -> void:
	var just_pressed: bool = false;
	if Input.is_action_just_pressed("D_Pad_Down") or Input.is_action_just_pressed("L_Stick_Down"):
		handle_updown_input(1);
		cd_dir.start(0.5);
		just_pressed = true;
	elif Input.is_action_just_pressed("D_Pad_Up") or Input.is_action_just_pressed("L_Stick_Up"):
		handle_updown_input(-1);
		cd_dir.start(0.5);
		just_pressed = true;
	
	if cd_dir.is_stopped() and not just_pressed:
		if Input.is_action_pressed("D_Pad_Down") or Input.is_action_pressed("L_Stick_Down"):
			handle_updown_input(1);
			cd_dir.start(0.1);
		elif Input.is_action_pressed("D_Pad_Up") or Input.is_action_pressed("L_Stick_Up"):
			handle_updown_input(-1);
			cd_dir.start(0.1);
	return


func handle_updown_input(dir: int) -> void:
	if view_mode == VIEWMODE.ARTS:
		if relearn_art:
			relearn_scroll_ctrl.change_index(dir);
			relearn_selection.global_position = relearn_scroll_ctrl.get_current_element().global_position;
			load_art_details(learned_arts[relearn_scroll_ctrl.idx_selected]);
			return
		
		if swap_arts:
			arts_index = clampi(arts_index + dir, 0, characters[tab_index].get_number_of_arts() - 1);
			arts_selector_swap.position = arts_list[arts_index].position;
		else:
			arts_index = clampi(arts_index + dir, 0, displayed_arts.size() - 1);
			arts_selector.position = arts_list[arts_index].position;
			load_art_details(displayed_arts[arts_index]);
	return


func prepare_view() -> void:
	GameData.get_characters_only(characters);
	max_tab_index = characters.size() - 1;
	view_mode = VIEWMODE.MAIN;
	
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


func change_view_mode(new_mode: VIEWMODE) -> void:
	view_mode = new_mode;
	main_view.visible = new_mode == VIEWMODE.MAIN;
	arts_view.visible = new_mode == VIEWMODE.ARTS;
	ability_view.visible = new_mode == VIEWMODE.ABILITY;
	
	match new_mode:
		VIEWMODE.MAIN:
			pass
		VIEWMODE.ARTS:
			arts_index = 0;
			arts_selector.position = arts_list[0].position;
			load_art_details(displayed_arts[0]);
			swap_index = -1;
			swap_arts = false;
			arts_selector_swap.visible = false;
			relearn_art = false;
		VIEWMODE.ABILITY:
			pass
	return


func change_tab_index(value: int) -> void:
	tab_btns[tab_index].clear_hovered();
	var new_index = clampi(tab_index + value, 0, max_tab_index);
	if tab_index != new_index:
		tab_index = new_index;
		load_character_data(tab_index);
	tab_btns[tab_index].set_hovered();
	return


func change_swap_mode(make_active: bool, swap: bool) -> void:
	if make_active:
		if arts_list[arts_index].valid_art:
			arts_selector_swap.position = arts_list[arts_index].position;
			arts_selector_swap.visible = true;
			swap_arts = true;
			swap_index = arts_index;
	else:
		if swap:
			if arts_list[arts_index].valid_art:
				characters[tab_index].swap_art_positions(arts_index, swap_index);
				load_character_data(tab_index);
			else:
				return
		arts_selector_swap.visible = false;
		swap_arts = false;
		swap_index = -1;
		arts_selector.position = arts_list[arts_index].position;
		load_art_details(displayed_arts[arts_index]);
	return


func change_relearn_mode(make_active: bool) -> void:
	if make_active and characters[tab_index].learned_art_ids.size() <= 0:
		return
	
	relearn_art = make_active;
	relearn_ctrl.visible = make_active;
	if make_active:
		relearn_scroll_ctrl.set_index(0);
		relearn_selection.global_position = relearn_scroll_ctrl.get_current_element().global_position;
		load_art_details(learned_arts[0]);
	else:
		load_art_details(displayed_arts[arts_index]);
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
	
	displayed_arts.clear();
	for id in chd.art_ids:
		if id >= 0:
			displayed_arts.append(BattleArt.new(id));
		else:
			displayed_arts.append(null);
	for i in displayed_arts.size():
		art_disps[i].fill_data(displayed_arts[i]);
		arts_list[i].fill_data(displayed_arts[i]);
	
	learned_arts.clear();
	relearn_scroll_ctrl.reset();
	for id in chd.learned_art_ids:
		var new_art := BattleArt.new(id);
		var new_li := art_disp_scene.instantiate() as ArtDisplay;
		learned_arts.append(new_art);
		relearn_scroll_ctrl.add_element(new_li);
		new_li.fill_data(new_art);
	
	load_attribute_icons(chd);
	return


func load_attribute_icons(chd: CharacterData) -> void:
	for textrect in texture_rects:
		textrect.queue_free();
	texture_rects.clear();
	
	for i in chd.attribute_weak.size():
		var text_rect := TextureRect.new();
		marker_attr_icons[0].add_child(text_rect);
		text_rect.position.x = marker_attr_icons[0].size.x * i;
		text_rect.size = marker_attr_icons[0].size;
		text_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH;
		text_rect.texture = Attributes.get_attribute_icon(chd.attribute_weak[i]);
		texture_rects.append(text_rect);
	
	for i in chd.attribute_resist.size():
		var text_rect := TextureRect.new();
		marker_attr_icons[1].add_child(text_rect);
		text_rect.position.x = marker_attr_icons[1].size.x * i;
		text_rect.size = marker_attr_icons[1].size;
		text_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH;
		text_rect.texture = Attributes.get_attribute_icon(chd.attribute_resist[i]);
		texture_rects.append(text_rect);
	
	for i in chd.attribute_block.size():
		var text_rect := TextureRect.new();
		marker_attr_icons[2].add_child(text_rect);
		text_rect.position.x = marker_attr_icons[2].size.x * i;
		text_rect.size = marker_attr_icons[2].size;
		text_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH;
		text_rect.texture = Attributes.get_attribute_icon(chd.attribute_block[i]);
		texture_rects.append(text_rect);
	return


func load_art_details(art: BattleArt) -> void:
	if art == null or !art.is_valid_art():
		detail_ctrl.visible = false;
		return
	
	detail_ctrl.visible = true;
	arts_name.text = art.name;
	arts_category.text = art.get_category_name();
	arts_icon_category.texture = ResourceManager.get_art_category_icon(int(art.category));
	arts_icon_attr_1.texture = Attributes.get_attribute_icon(art.attribute_1);
	arts_icon_attr_2.texture = Attributes.get_attribute_icon(art.attribute_2);
	if art.has_no_basepower():
		arts_strength.text = "-";
	else:
		arts_strength.text = str(art.base_power);
	arts_amounts.text = str("x", art.hit_amount);
	arts_amounts.visible = art.hit_amount > 1;
	arts_cost.text = "-" if art.is_passive_art() else str(art.sp_cost);
	arts_cost_type.text = "CP" if art.is_ult else "SP";
	arts_cost_type.visible = !art.is_passive_art();
	arts_description.text = art.description;
	return
