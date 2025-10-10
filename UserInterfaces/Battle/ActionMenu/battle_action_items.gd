extends Control

const ItemDisplay := preload("res://UserInterfaces/Battle/Displays/item_display.gd");
const item_disp_scene := preload("res://UserInterfaces/Battle/Displays/item_display.tscn") as PackedScene;

@onready var selector := $BackPanel/Selector as ColorRect;
@onready var scroll_ctrl := $BackPanel/ScrollControl as ScrollControl;

var consumables: Array[ItemConsumable] = [];


func prepare_view() -> void:
	# (Re)Load consumables
	consumables.clear();
	for i in GameData.item_consumables.size():
		if GameData.item_consumables[i] > 0:
			var new_item := ItemConsumable.new(i, GameData.item_consumables[i]);
			if new_item.menu_only == false:
				consumables.append(new_item);
	
	scroll_ctrl.reset();
	for item in consumables:
		var new_li := item_disp_scene.instantiate() as ItemDisplay;
		scroll_ctrl.add_element(new_li);
		new_li.update_itemdata(item);
	return


func set_index(value: int) -> void:
	if value >= 0 and value < consumables.size():
		(scroll_ctrl.get_current_element() as ItemDisplay).set_selected(false);
		scroll_ctrl.set_index(value);
		(scroll_ctrl.get_current_element() as ItemDisplay).set_selected(true);
	return


func get_item_description(item_index: int) -> String:
	if item_index >= 0 and item_index < consumables.size():
		return consumables[item_index].description
	return ""


func get_item_obj(item_index: int) -> ItemConsumable:
	if item_index >= 0 and item_index < consumables.size():
		return consumables[item_index]
	return null
