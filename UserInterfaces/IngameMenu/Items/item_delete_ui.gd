extends Control

@onready var lbl_item_name := $LabelItemName as Label;
@onready var lbl_amount := $LabelAmount as Label;

var max_amount: int = 0;
var cur_amount: int = 0;


func input_event(event: InputEvent) -> int:
	if event.is_action_pressed("Btn_B"):
		return -1
	
	if event.is_action_pressed("Btn_Y"):
		return cur_amount
	
	if event.is_action_pressed("D_Pad_Down"):
		change_amount(-1);
	
	if event.is_action_pressed("D_Pad_Up"):
		change_amount(1);
	
	if event.is_action_pressed("D_Pad_Left"):
		change_amount(-10);
	
	if event.is_action_pressed("D_Pad_Right"):
		change_amount(10);
	return 0


func prepare_view(item_name: String, max_val: int) -> void:
	max_amount = max_val;
	cur_amount = 0;
	lbl_amount.text = str(cur_amount);
	lbl_item_name.text = item_name;
	return


func change_amount(val: int) -> void:
	if cur_amount == 0 and val < 0:
		cur_amount = max_amount;
	else:
		cur_amount = clampi(cur_amount + val, 0, max_amount);
	lbl_amount.text = str(cur_amount);
	return
