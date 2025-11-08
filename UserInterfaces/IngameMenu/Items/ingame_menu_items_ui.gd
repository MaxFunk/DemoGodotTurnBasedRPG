extends Control

const item_li_scene := preload("res://UserInterfaces/IngameMenu/Items/item_listitem.tscn") as PackedScene;
const ItemLI := preload("res://UserInterfaces/IngameMenu/Items/item_listitem.gd");
const DeleteUI := preload("res://UserInterfaces/IngameMenu/Items/item_delete_ui.gd");
const UseUI := preload("res://UserInterfaces/IngameMenu/Items/item_use_ui.gd");

enum MENUSTATE {DEFAULT, DETAIL, DELETE, USE}

@onready var lblbtn_head_consum := $Header/LabelButtonConsumables as LabelButton;
@onready var lblbtn_head_mat := $Header/LabelButtonMaterials as LabelButton;
@onready var lblbtn_head_ingr := $Header/LabelButtonIngredients as LabelButton;
@onready var lblbtn_head_key := $Header/LabelButtonKeyitems as LabelButton;

@onready var scroll_ctrl := $ScrollControl as ScrollControl;
@onready var lbl_no_items := $LabelNoItems as Label;

@onready var detail_ctrl := $DetailControl as Control;
@onready var lbl_item_name := $DetailControl/LabelItemName as Label;
@onready var lbl_item_amount := $DetailControl/LabelItemAmount as Label;
@onready var lbl_subcategory := $DetailControl/LabelSubcategory as Label;
@onready var lbl_description := $DetailControl/LabelDescription as Label;
@onready var lblbtn_use := $DetailControl/LabelButtonUse as LabelButton;
@onready var lblbtn_delete := $DetailControl/LabelButtonDelete as LabelButton;

@onready var delete_ui := $ItemDeleteUI as DeleteUI;
@onready var use_ui := $ItemUseUI as UseUI;
@onready var cd_dir := $CooldownDirectional as Timer;

var consumables: Array[ItemConsumable] = [];
var materials: Array[ItemMaterial] = [];
var ingredients: Array[ItemIngredient] = [];
var keyitems: Array[ItemKeyitem] = [];

#var item_lis: Array[ItemLI] = [];
var item_type_idx: int = 0;
var menu_state := MENUSTATE.DEFAULT;
var idx_detail: int = 0;


func input_event(event: InputEvent) -> bool:
	match menu_state:
		MENUSTATE.DEFAULT: return input_event_default(event);
		MENUSTATE.DETAIL: return input_event_detail(event);
		MENUSTATE.DELETE:
			var res := delete_ui.input_event(event);
			if res < 0:
				switch_to_default();
			if res > 0:
				delete_items(res);
		MENUSTATE.USE:
			var res := use_ui.input_event(event);
			if res >= 0:
				delete_items(res);
				switch_to_default();
	return false


func input_event_default(event: InputEvent) -> bool:
	if event.is_action_pressed("Btn_B"):
		return true
	
	if event.is_action_pressed("Btn_Y"):
		switch_to_detail();
		return false
	
	if event.is_action_pressed("L") and item_type_idx > 0:
		item_type_idx -= 1;
		set_header_labels();
		load_item_lis();
		load_detail_ui();
	
	if event.is_action_pressed("R") and item_type_idx < 3:
		item_type_idx += 1;
		set_header_labels();
		load_item_lis();
		load_detail_ui();
	return false


func input_event_detail(event: InputEvent) -> bool:
	if event.is_action_pressed("Btn_B"):
		switch_to_default();
	
	if event.is_action_pressed("Btn_Y"):
		if idx_detail == 0:
			if item_type_idx == 0:
				switch_to_use();
		else:
			switch_to_delete();
	return false


func _process(_delta: float) -> void:
	if menu_state == MENUSTATE.DEFAULT:
		var just_pressed: bool = false;
		if Input.is_action_just_pressed("D_Pad_Down") or Input.is_action_just_pressed("L_Stick_Down"):
			update_scroll_view(1);
			cd_dir.start(0.5);
			just_pressed = true;
		elif Input.is_action_just_pressed("D_Pad_Up") or Input.is_action_just_pressed("L_Stick_Up"):
			update_scroll_view(-1);
			cd_dir.start(0.5);
			just_pressed = true;
		
		if cd_dir.is_stopped() and not just_pressed:
			if Input.is_action_pressed("D_Pad_Down") or Input.is_action_pressed("L_Stick_Down"):
				update_scroll_view(1);
				cd_dir.start(0.1);
			elif Input.is_action_pressed("D_Pad_Up") or Input.is_action_pressed("L_Stick_Up"):
				update_scroll_view(-1);
				cd_dir.start(0.1);
	
	if menu_state == MENUSTATE.DETAIL:
		var btn_down := Input.is_action_just_pressed("D_Pad_Down") or Input.is_action_just_pressed("L_Stick_Down");
		var btn_up := Input.is_action_just_pressed("D_Pad_Up") or Input.is_action_just_pressed("L_Stick_Up");
		if idx_detail == 0 and btn_down:
			idx_detail = 1;
			lblbtn_use.clear_hovered();
			lblbtn_delete.set_hovered();
		if idx_detail != 0 and btn_up:
			idx_detail = 0;
			lblbtn_use.set_hovered();
			lblbtn_delete.clear_hovered();
	return


func prepare_view() -> void:
	load_item_objects();
	item_type_idx = 0;
	set_header_labels();
	load_item_lis();
	load_detail_ui();
	return


func update_scroll_view(index_change: int) -> void:
	if scroll_ctrl.elements.size() <= 0:
		return
	(scroll_ctrl.get_current_element() as ItemLI).set_selected(false);
	scroll_ctrl.change_index(index_change);
	load_detail_ui();
	(scroll_ctrl.get_current_element() as ItemLI).set_selected(true);
	return


func set_header_labels() -> void:
	lblbtn_head_consum.set_hovered_value(item_type_idx == 0);
	lblbtn_head_mat.set_hovered_value(item_type_idx == 1);
	lblbtn_head_ingr.set_hovered_value(item_type_idx == 2);
	lblbtn_head_key.set_hovered_value(item_type_idx == 3);
	return


func load_item_objects() -> void:
	consumables.clear();
	materials.clear();
	ingredients.clear();
	keyitems.clear();
	
	for i in GameData.item_consumables.size():
		if GameData.item_consumables[i] > 0:
			var new_item := ItemConsumable.new(i, GameData.item_consumables[i]);
			consumables.append(new_item);
	
	for i in GameData.item_materials.size():
		if GameData.item_materials[i] > 0:
			var new_item := ItemMaterial.new(i, GameData.item_materials[i]);
			materials.append(new_item);
	
	for i in GameData.item_ingredients.size():
		if GameData.item_ingredients[i] > 0:
			var new_item := ItemIngredient.new(i, GameData.item_ingredients[i]);
			ingredients.append(new_item);
	
	for i in GameData.item_keyitems.size():
		if GameData.item_keyitems[i] > 0:
			var new_item := ItemKeyitem.new(i, GameData.item_keyitems[i]);
			if new_item.is_visible:
				keyitems.append(new_item);
	return


func load_item_lis() -> void:
	scroll_ctrl.reset();
	
	match item_type_idx:
		0:
			lbl_no_items.visible = false if consumables.size() > 0 else true;
			for item in consumables:
				var new_li := item_li_scene.instantiate() as ItemLI;
				scroll_ctrl.add_element(new_li);
				new_li.update_from_consumable(item)
		
		1:
			lbl_no_items.visible = false if materials.size() > 0 else true;
			for item in materials:
				var new_li := item_li_scene.instantiate() as ItemLI;
				scroll_ctrl.add_element(new_li);
				new_li.update_from_material(item);
		
		2:
			lbl_no_items.visible = false if ingredients.size() > 0 else true;
			for item in ingredients:
				var new_li := item_li_scene.instantiate() as ItemLI;
				scroll_ctrl.add_element(new_li);
				new_li.update_from_ingredient(item);
		
		3:
			lbl_no_items.visible = false if keyitems.size() > 0 else true;
			for item in keyitems:
				var new_li := item_li_scene.instantiate() as ItemLI;
				scroll_ctrl.add_element(new_li);
				new_li.update_from_keyitems(item);
	
	if scroll_ctrl.elements.size() > 0:
		(scroll_ctrl.get_current_element() as ItemLI).set_selected(true);
	return


func load_detail_ui() -> void:
	var item_idx := scroll_ctrl.idx_selected;
	var item: Item = null;
	
	match item_type_idx:
		0:
			if item_idx < consumables.size():
				item = consumables[item_idx];
		1:
			if item_idx < materials.size():
				item = materials[item_idx];
		2:
			if item_idx < ingredients.size():
				item = ingredients[item_idx];
		3:
			if item_idx < keyitems.size():
				item = keyitems[item_idx];
	
	detail_ctrl.visible = item != null;
	if item != null:
		lbl_item_name.text = item.name;
		lbl_item_amount.text = str(item.amount);
		lbl_subcategory.text = item.category_str;
		lbl_description.text = item.description;
	
	lblbtn_use.clear_hovered();
	lblbtn_delete.clear_hovered();
	lblbtn_use.visible = false;
	lblbtn_delete.visible = false;
	return


func switch_to_detail() -> void:
	if item_type_idx >= 3:
		print("Cannot use or delete Keyitem!");
		return
	
	menu_state = MENUSTATE.DETAIL;
	idx_detail = 0;
	detail_ctrl.visible = true;
	
	lblbtn_use.set_hovered();
	lblbtn_delete.clear_hovered();
	lblbtn_use.visible = true;
	lblbtn_delete.visible = true;
	return


func switch_to_default() -> void:
	menu_state = MENUSTATE.DEFAULT;
	
	delete_ui.visible = false;
	use_ui.visible = false;
	detail_ctrl.visible = true;
	load_detail_ui();
	
	lblbtn_use.clear_hovered();
	lblbtn_delete.clear_hovered();
	lblbtn_use.visible = false;
	lblbtn_delete.visible = false;
	return


func switch_to_delete() -> void:
	var item_idx := scroll_ctrl.idx_selected;
	var max_amount: int = 0;
	var item_name: String = "";
	
	match item_type_idx:
		0:
			max_amount = consumables[item_idx].amount;
			item_name = consumables[item_idx].name;
		1:
			max_amount = materials[item_idx].amount;
			item_name = materials[item_idx].name;
		2:
			max_amount = ingredients[item_idx].amount;
			item_name = ingredients[item_idx].name;
		3:
			return # Keyitems cannot be deleted manually, so additional failsafe
	
	delete_ui.prepare_view(item_name, max_amount);
	menu_state = MENUSTATE.DELETE;
	lblbtn_use.visible = false;
	lblbtn_delete.visible = false;
	delete_ui.visible = true;
	return


func switch_to_use() -> void:
	if consumables[scroll_ctrl.idx_selected].battle_only:
		return;
	
	use_ui.prepare_view(consumables[scroll_ctrl.idx_selected]);
	menu_state = MENUSTATE.USE;
	detail_ctrl.visible = false;
	use_ui.visible = true;
	return


func delete_items(delete_amount: int) -> void:
	var item_idx := scroll_ctrl.idx_selected;
	var reload: bool = false;
	
	match item_type_idx:
		0:
			var item := consumables[item_idx];
			var delete_obj := item.delete_items(delete_amount);
			if delete_obj:
				consumables.remove_at(item_idx);
				reload = true;
			else:
				(scroll_ctrl.get_current_element() as ItemLI).update_from_consumable(item);
		1:
			var item := materials[item_idx];
			var delete_obj := item.delete_items(delete_amount);
			if delete_obj:
				materials.remove_at(item_idx);
				reload = true;
			else:
				(scroll_ctrl.get_current_element() as ItemLI).update_from_material(item);
		2:
			var item := ingredients[item_idx];
			var delete_obj := item.delete_items(delete_amount);
			if delete_obj:
				ingredients.remove_at(item_idx);
				reload = true;
			else:
				(scroll_ctrl.get_current_element() as ItemLI).update_from_ingredient(item);
	
	if reload:
		load_item_lis();
		if lbl_no_items.visible == false:
			(scroll_ctrl.get_current_element() as ItemLI).set_selected(false);
			scroll_ctrl.set_index(item_idx);
			(scroll_ctrl.get_current_element() as ItemLI).set_selected(true);
		load_detail_ui();
	
	switch_to_default();
	return
