extends ShopUI

const ItemLI := preload("uid://dsw4yuoeijkf8");
const item_listitem_scene := preload("uid://ccxdk1tdbw1qk");

enum VIEWSTATE {FRONT, BUY, SELL, POPUP}

@onready var front_view := $FrontView as Control;
@onready var lblbtns_front: Array[LabelButton] = [
	$FrontView/LabelButtonBuy as LabelButton,
	$FrontView/LabelButtonSell as LabelButton,
	$FrontView/LabelButtonClose as LabelButton];

@onready var buy_view := $BuyView as Control;
@onready var sell_view := $SellView as Control;
@onready var money_view := $MoneyView as Control;
@onready var lbl_money := $MoneyView/LabelMoney as Label;
@onready var scroll_ctrl := $ScrollControl as ScrollControl;
@onready var detail_view := $DetailView as Control;
@onready var lbl_item_name := $DetailView/LabelItemName as Label;
@onready var lbl_subcategory := $DetailView/LabelSubcategory as Label;
@onready var lbl_description := $DetailView/LabelDescription as Label;

@onready var popup_view := $PopupView as Control;
@onready var lbl_popup_header := $PopupView/LabelHeader as Label;
@onready var lbl_popup_name := $PopupView/LabelItemName as Label;
@onready var lbl_popup_amount := $PopupView/LabelAmount as Label;
@onready var lbl_popup_cost := $PopupView/LabelCost as Label;


var view_state := VIEWSTATE.FRONT;
var index_front: int = 0;
var popup_value: int = 0;
var buy_mode: bool = true;
var no_reload: bool = false;

var buy_items: Array[Item] = [];
var sell_items: Array[Item] = [];


func custom_ready() -> void:
	var item_ids: PackedInt32Array = [0, 1, 2, 3, 4, 5, 6, 7, 8, 0, 0, 0, 0];
	var item_amounts: PackedInt32Array = [5, 5, 5, 3, 3, 3, 2, 2, 1, 99, 99, 99, 99];
	for i in item_ids.size():
		var new_items := ItemConsumable.new(item_ids[i], item_amounts[i]);
		buy_items.append(new_items);
	
	for i in GameData.item_consumables.size():
		if GameData.item_consumables[i] > 0:
			sell_items.append(ItemConsumable.new(i, GameData.item_consumables[i]));
	
	change_viewstate(VIEWSTATE.FRONT);
	return


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Btn_B"):
		input_cancel();
		return
	
	if event.is_action_pressed("Btn_Y") or event.is_action_pressed("Btn_A"):
		input_accept();
	return


func input_down() -> void:
	match view_state:
		VIEWSTATE.FRONT:
			index_front = mini(index_front + 1, lblbtns_front.size() - 1);
			update_front_view();
		VIEWSTATE.BUY, VIEWSTATE.SELL:
			(scroll_ctrl.get_current_element() as ItemLI).set_selection(false);
			scroll_ctrl.change_index(1);
			(scroll_ctrl.get_current_element() as ItemLI).set_selection(true);
			update_detail_view();
		VIEWSTATE.POPUP:
			update_popup(-1);
	return


func input_up() -> void:
	match view_state:
		VIEWSTATE.FRONT:
			index_front = maxi(index_front - 1, 0);
			update_front_view();
		VIEWSTATE.BUY, VIEWSTATE.SELL:
			(scroll_ctrl.get_current_element() as ItemLI).set_selection(false);
			scroll_ctrl.change_index(-1);
			(scroll_ctrl.get_current_element() as ItemLI).set_selection(true);
			update_detail_view();
		VIEWSTATE.POPUP:
			update_popup(1);
	return


func input_left() -> void:
	return


func input_right() -> void:
	return


func input_accept() -> void:
	match view_state:
		VIEWSTATE.FRONT:
			match index_front:
				0: change_viewstate(VIEWSTATE.BUY);
				1: change_viewstate(VIEWSTATE.SELL);
				_: GameData.main_scene.close_user_interface();
		VIEWSTATE.BUY:
			var item := buy_items[scroll_ctrl.idx_selected];
			if item.amount > 0 and GameData.money >= item.buy_value:
				change_viewstate(VIEWSTATE.POPUP);
		VIEWSTATE.SELL:
			if sell_items[scroll_ctrl.idx_selected].amount > 0:
				change_viewstate(VIEWSTATE.POPUP);
		VIEWSTATE.POPUP:
			if buy_mode:
				confirm_buy();
				change_viewstate(VIEWSTATE.BUY);
			else:
				confirm_sell();
				change_viewstate(VIEWSTATE.SELL);
	return


func input_cancel() -> void:
	match view_state:
		VIEWSTATE.FRONT:
			GameData.main_scene.close_user_interface();
		VIEWSTATE.BUY:
			change_viewstate(VIEWSTATE.FRONT);
		VIEWSTATE.SELL:
			change_viewstate(VIEWSTATE.FRONT);
		VIEWSTATE.POPUP:
			no_reload = true;
			change_viewstate(VIEWSTATE.BUY if buy_mode else VIEWSTATE.SELL);
	return


func change_viewstate(new_state: VIEWSTATE) -> void:
	front_view.visible = new_state == VIEWSTATE.FRONT;
	buy_view.visible = new_state == VIEWSTATE.BUY or (new_state == VIEWSTATE.POPUP and buy_mode);
	sell_view.visible = new_state == VIEWSTATE.SELL or (new_state == VIEWSTATE.POPUP and not buy_mode);
	money_view.visible = new_state != VIEWSTATE.FRONT;
	detail_view.visible = new_state != VIEWSTATE.FRONT;
	scroll_ctrl.visible = new_state != VIEWSTATE.FRONT;
	popup_view.visible = new_state == VIEWSTATE.POPUP;
	
	view_state = new_state;
	match view_state:
		VIEWSTATE.FRONT:
			update_front_view();
		VIEWSTATE.BUY:
			buy_mode = true;
			update_scroll_ctrl();
			update_money_view();
			update_detail_view();
		VIEWSTATE.SELL:
			buy_mode = false;
			update_scroll_ctrl();
			update_money_view();
			update_detail_view();
		VIEWSTATE.POPUP:
			popup_value = 1;
			update_popup(0);
	return


func update_front_view() -> void:
	for i in lblbtns_front.size():
		lblbtns_front[i].set_hovered_value(i == index_front);
	return


func update_scroll_ctrl() -> void:
	if no_reload:
		no_reload = false;
		return
	
	var index_before := scroll_ctrl.idx_selected;
	scroll_ctrl.reset();
	if buy_mode:
		for item in buy_items:
			var new_li := item_listitem_scene.instantiate() as ItemLI;
			scroll_ctrl.add_element(new_li);
			new_li.write_data(item, true);
	else:
		for item in sell_items:
			var new_li := item_listitem_scene.instantiate() as ItemLI;
			scroll_ctrl.add_element(new_li);
			new_li.write_data(item, false);
	
	scroll_ctrl.set_index(index_before);
	
	var elem := scroll_ctrl.get_current_element() as ItemLI;
	elem.set_selection(true);
	return


func update_money_view() -> void:
	lbl_money.text = int_to_eurotext(GameData.money);
	return


func update_detail_view() -> void:
	var item := buy_items[scroll_ctrl.idx_selected] if buy_mode else sell_items[scroll_ctrl.idx_selected];
	lbl_item_name.text = item.name;
	lbl_subcategory.text = item.category_str;
	lbl_description.text = item.description;
	return


func update_popup(amount_change: int) -> void:
	var item := buy_items[scroll_ctrl.idx_selected] if buy_mode else sell_items[scroll_ctrl.idx_selected];
	
	var max_value: int = 0;
	if buy_mode:
		max_value = mini(floori(GameData.money / float(item.buy_value)), item.amount);
	else:
		max_value = item.amount;
	
	if popup_value == 1 and amount_change < 0:
		popup_value = max_value;
	elif popup_value == max_value and amount_change > 0:
		popup_value = 1;
	else:
		popup_value = clampi(popup_value + amount_change, 1, max_value);
	
	var total_cost: int = (item.buy_value if buy_mode else item.sell_value) * popup_value;
	var total_cost_str: String = "-" if buy_mode else "+";
	total_cost_str += int_to_eurotext(total_cost);
	
	lbl_popup_header.text = "Buy:" if buy_mode else "Sell:";
	lbl_popup_name.text = item.name;
	lbl_popup_amount.text = str(popup_value);
	lbl_popup_cost.text = total_cost_str;
	return


func int_to_eurotext(value: int) -> String:
	var left_part := floori(value / 100.0);
	var right_part := str(value - left_part * 100).lpad(2, "0");
	return str(left_part, ".", right_part, " €");


func confirm_buy() -> void:
	var item := buy_items[scroll_ctrl.idx_selected];
	GameData.money -= popup_value * item.buy_value;
	item.recieve_items(popup_value);
	return


func confirm_sell() -> void:
	var item := sell_items[scroll_ctrl.idx_selected];
	GameData.money += popup_value * item.sell_value;
	var _delete_obj := item.delete_items(popup_value);
	return
