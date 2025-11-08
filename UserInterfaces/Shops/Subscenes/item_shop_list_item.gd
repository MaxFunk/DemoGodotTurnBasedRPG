extends Control

const color_unselected := Color(1.0, 1.0, 1.0, 1.0);
const color_selected := Color(0.863, 0.078, 0.235, 1.0);

@onready var lbl_name := $LabelName as Label;
@onready var lbl_amount := $LabelAmount as Label;
@onready var lbl_cost := $LabelCost as Label;


func write_data(item: Item, buy_mode: bool) -> void:
	lbl_name.text = item.name;
	lbl_amount.text = str(item.amount, "x");
	
	var cost: int = item.buy_value if buy_mode else item.sell_value;
	var left_part := floori(cost / 100.0);
	var right_part := str(cost - left_part * 100).lpad(2, "0");
	lbl_cost.text = str(left_part, ".", right_part, " €");
	modulate.a = 1.0 if item.amount > 0 else 0.5;
	return


func set_selection(value: bool) -> void:
	lbl_name.modulate = color_selected if value else color_unselected;
	return
