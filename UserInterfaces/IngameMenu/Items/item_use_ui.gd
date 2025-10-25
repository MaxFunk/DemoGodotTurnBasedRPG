extends Control

const EffectDisp := preload("res://UserInterfaces/IngameMenu/Items/item_use_effect_display.gd");

@onready var lbl_item_name := $LabelItemName as Label;
@onready var lbl_item_amount := $LabelItemAmount as Label;
@onready var lblbtn_names: Array[LabelButton] = [
	$CharNames/LabelButtonName1 as LabelButton,
	$CharNames/LabelButtonName2 as LabelButton,
	$CharNames/LabelButtonName3 as LabelButton,
	$CharNames/LabelButtonName4 as LabelButton,
	$CharNames/LabelButtonName5 as LabelButton,
	$CharNames/LabelButtonName6 as LabelButton,
	$CharNames/LabelButtonName7 as LabelButton,
	$CharNames/LabelButtonName8 as LabelButton];
@onready var effect_disps: Array[EffectDisp] = [
	$CharDisplays/ItemUseEffectDisplay1 as EffectDisp,
	$CharDisplays/ItemUseEffectDisplay2 as EffectDisp,
	$CharDisplays/ItemUseEffectDisplay3 as EffectDisp,
	$CharDisplays/ItemUseEffectDisplay4 as EffectDisp,
	$CharDisplays/ItemUseEffectDisplay5 as EffectDisp,
	$CharDisplays/ItemUseEffectDisplay6 as EffectDisp,
	$CharDisplays/ItemUseEffectDisplay7 as EffectDisp,
	$CharDisplays/ItemUseEffectDisplay8 as EffectDisp];

var char_ids: PackedInt32Array = [];
var max_index: int = -1;
var cur_index: int = 0;

var cur_consumable: ItemConsumable = null;
var times_used: int = 0;

# TODO: for Arts: probably something like extra ui where arts are listed
#       and can be selected to be replaced

# -1 == nothing happens, 0 or larger -> deletes x amount of current items and closes this view
func input_event(event: InputEvent) -> int:
	if event.is_action_pressed("Btn_B"):
		return times_used
	
	if event.is_action_pressed("Btn_Y"):
		if times_used == cur_consumable.amount:
			return times_used
		call_use_item();
		return -1
	
	return -1


func _process(_delta: float) -> void:
	if cur_consumable == null or cur_consumable.used_on_all:
		return
	
	if Input.is_action_just_pressed("D_Pad_Down") or Input.is_action_just_pressed("L_Stick_Down"):
		cur_index = mini(cur_index + 1, max_index);
		update_selection();
	elif Input.is_action_just_pressed("D_Pad_Up") or Input.is_action_just_pressed("L_Stick_Up"):
		cur_index = maxi(cur_index - 1, 0);
		update_selection();
	return


func prepare_view(consumable: ItemConsumable) -> void:
	char_ids.clear();
	max_index = -1;
	cur_index = 0;
	times_used = 0;
	
	cur_consumable = consumable;
	lbl_item_name.text = cur_consumable.name;
	lbl_item_amount.text = str(cur_consumable.amount - times_used);
	
	for id in GameData.active_party:
		if id >= 0:
			max_index += 1;
			char_ids.append(id);
	for id in GameData.backup_party:
		max_index += 1;
		char_ids.append(id);
	char_ids.sort();
	
	for i in 8:
		if i <= max_index:
			var char_data := GameData.characters[char_ids[i]];
			lblbtn_names[i].visible = true;
			lblbtn_names[i].text = char_data.name;
			effect_disps[i].visible = true;
			effect_disps[i].update_view(char_data, consumable);
		else:
			lblbtn_names[i].visible = false;
			effect_disps[i].visible = false;
	
	update_selection();
	return


func call_use_item() -> void:
	var item_used: bool = false;
	
	if cur_consumable.used_on_all:
		for i in (max_index + 1):
			var res := use_item(i);
			if !item_used and res:
				item_used = true;
	else:
		item_used = use_item(cur_index);
	
	if item_used:
		times_used += 1;
		lbl_item_amount.text = str(cur_consumable.amount - times_used);
	return


# returns true if item was actually used
func use_item(use_idx: int) -> bool:
	var cd := GameData.characters[char_ids[use_idx]];
	var item := cur_consumable; # alias for less text in code
	
	var eff_id := item.effects[0];
	var eff_val := item.effect_values[0];
	
	match item.type:
		item.TYPE.RESTORE_HP:
			if cd.cur_health == cd.accum_stats[0]:
				return false
			if eff_id == EffectIDs.ITEM_RESTORE_PERCENT:
				eff_val = ceili(cd.accum_stats[0] * eff_val / 100.0);
			cd.cur_health = mini(cd.cur_health + eff_val, cd.accum_stats[0]);
		
		item.TYPE.RESTORE_SP:
			if cd.cur_stamina == cd.accum_stats[1]:
				return false
			if eff_id == EffectIDs.ITEM_RESTORE_PERCENT:
				eff_val = ceili(cd.accum_stats[1] * eff_val / 100.0);
			cd.cur_stamina = mini(cd.cur_stamina + eff_val, cd.accum_stats[1]);
		
		item.TYPE.DISHES:
			# if true, item not used + abort
			if use_dish(cd, eff_id, eff_val):
				return false
		
		item.TYPE.STAT_SHARD:
			if eff_id < 0 or eff_id >= 8:
				assert(str("INVALID STAT ID ", eff_id));
				return false
			if cd.bonus_stats[eff_id] >= 999:
				return false
			cd.recieve_bonus_stat(eff_id, eff_val);
		
		item.TYPE.ART_SHARD:
			if cd.art_ids.has(eff_id):
				return false
			var num_arts := cd.get_number_of_arts();
			if num_arts >= 7:
				cd.learned_art_ids.append(eff_id);
			else:
				cd.learn_art(eff_id, num_arts)
	
	effect_disps[use_idx].update_view(cd, cur_consumable);
	return true


func use_dish(cd: CharacterData, eff_id: int, eff_val: int) -> bool:
	var dish_id := eff_id;
	var actual_eff_id := eff_val;
	match dish_id:
		EffectIDs.ITEM_DISH_HEALTH:
			if cd.cur_health == cd.accum_stats[0]:
				return true
			cd.cur_health = mini(cd.cur_health + eff_val, cd.accum_stats[0]);
		
		EffectIDs.ITEM_DISH_STAMINA:
			if cd.cur_stamina == cd.accum_stats[1]:
				return true
			cd.cur_stamina = mini(cd.cur_stamina + eff_val, cd.accum_stats[1]);
		
		_:
			if actual_eff_id < 0 or actual_eff_id >= 8:
				assert(str("INVALID STAT ID ", actual_eff_id));
				return true
			if cd.bonus_stats[actual_eff_id] >= 999:
				return true
			cd.recieve_bonus_stat(actual_eff_id, 1);
	return false


func update_selection() -> void:
	for i in 8:
		lblbtn_names[i].set_hovered_value(cur_consumable.used_on_all or i == cur_index);
	return
