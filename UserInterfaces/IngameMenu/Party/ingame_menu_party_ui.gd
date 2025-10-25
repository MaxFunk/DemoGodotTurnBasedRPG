extends Control

const PartyPanelBig := preload("uid://bufc0fl4sknlm");
const PartyPanelSmall := preload("uid://co5bbvp70kvwh");

@onready var panels_big: Array[PartyPanelBig] = [
	$PartyPanelBig1 as PartyPanelBig,
	$PartyPanelBig2 as PartyPanelBig,
	$PartyPanelBig3 as PartyPanelBig];
@onready var panels_small: Array[PartyPanelSmall] = [
	$PartyPanelSmall1 as PartyPanelSmall,
	$PartyPanelSmall2 as PartyPanelSmall,
	$PartyPanelSmall3 as PartyPanelSmall,
	$PartyPanelSmall4 as PartyPanelSmall,
	$PartyPanelSmall5 as PartyPanelSmall,
	$PartyPanelSmall6 as PartyPanelSmall,
	$PartyPanelSmall7 as PartyPanelSmall];
@onready var lbl_btn_x := $LabelButtonX as Label;
@onready var lbl_btn_y := $LabelButtonY as Label;
@onready var lbl_btn_b := $LabelButtonB as Label;

var upper_row_index: int = 0;
var lower_row_index: int = 0;
var is_upper_row: bool = true;


func input_event(event: InputEvent) -> bool:
	if event.is_action_pressed("Btn_B"):
		if is_upper_row:
			return true
		else:
			is_upper_row = true;
			panels_small[lower_row_index].deselect();
			update_button_info();
			return false
	
	if event.is_action_pressed("Btn_X"):
		if is_upper_row:
			remove_from_active();
		return false
	
	if event.is_action_pressed("Btn_Y") or event.is_action_pressed("Btn_A"):
		if is_upper_row:
			is_upper_row = false;
			panels_small[lower_row_index].select();
			update_button_info();
		else:
			swap_party();
			is_upper_row = true;
			panels_small[lower_row_index].deselect();
			update_button_info();
	return false


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("D_Pad_Left") or Input.is_action_just_pressed("L_Stick_Left"):
		if is_upper_row:
			input_left_upper_row();
		else:
			panels_small[lower_row_index].deselect();
			lower_row_index = maxi(lower_row_index - 1, 0);
			panels_small[lower_row_index].select();
	
	if Input.is_action_just_pressed("D_Pad_Right") or Input.is_action_just_pressed("L_Stick_Right"):
		if is_upper_row:
			input_right_upper_row();
		else:
			panels_small[lower_row_index].deselect();
			lower_row_index = mini(lower_row_index + 1, GameData.backup_party.size() - 1);
			panels_small[lower_row_index].select();
	return


func input_left_upper_row() -> void:
	panels_big[upper_row_index].deselect();
	match upper_row_index:
		0: upper_row_index = 1;
		2: upper_row_index = 0;
	panels_big[upper_row_index].select();
	return


func input_right_upper_row() -> void:
	panels_big[upper_row_index].deselect();
	match upper_row_index:
		0: upper_row_index = 2;
		1: upper_row_index = 0;
	panels_big[upper_row_index].select();
	return


func prepare_view() -> void:
	for i in range(3):
		var index: int = GameData.active_party[i];
		if index < 0:
			panels_big[i].fill_with_data(null);
		else:
			panels_big[i].fill_with_data(GameData.characters[index]);
	
	for i in range(7):
		if i < GameData.backup_party.size():
			var index: int = GameData.backup_party[i];
			panels_small[i].fill_with_data(GameData.characters[index]);
			panels_small[i].visible = true;
		else:
			panels_small[i].visible = false;
	
	for pnl in panels_big:
		pnl.deselect();
	for pnl in panels_small:
		pnl.deselect();
	
	upper_row_index = 0;
	lower_row_index = 0;
	is_upper_row = true;
	panels_big[upper_row_index].select();
	update_button_info();
	return


func remove_from_active() -> void:
	if upper_row_index == 0:
		var left_index: int = GameData.active_party[1];
		var right_index: int = GameData.active_party[2];
		if left_index >= 0:
			GameData.backup_party.append(GameData.active_party[0]);
			GameData.backup_party.sort();
			GameData.active_party[0] = left_index;
			GameData.active_party[1] = -1;
			prepare_view();
		elif right_index >= 0:
			GameData.backup_party.append(GameData.active_party[0]);
			GameData.backup_party.sort();
			GameData.active_party[0] = right_index;
			GameData.active_party[2] = -1;
			prepare_view();
		else:
			print("ACTION NOT POSSIBLE, CANNOT HAVE EMPTY PARTY!");
	else:
		if GameData.active_party[upper_row_index] >= 0:
			GameData.backup_party.append(GameData.active_party[upper_row_index]);
			GameData.backup_party.sort();
			GameData.active_party[upper_row_index] = -1;
			prepare_view();
		else:
			print("ACTION NOT POSSIBLE, EMPTY SLOT!");
	return


func swap_party() -> void:
	if GameData.backup_party.size() <= 0:
		print("ACTION NOT POSSIBLE, EMPTY BACKUP!")
		return
	
	var active_index: int = GameData.active_party[upper_row_index];
	var backup_index: int = GameData.backup_party[lower_row_index];
	
	GameData.active_party[upper_row_index] = backup_index;
	GameData.backup_party.remove_at(lower_row_index);
	if active_index >= 0:
		GameData.backup_party.append(active_index);
		GameData.backup_party.sort();
	prepare_view();
	return


func update_button_info() -> void:
	if is_upper_row:
		lbl_btn_x.text = "X: Move to Backup";
		lbl_btn_y.text = "Y: Select";
		lbl_btn_b.text = "B: Return";
	else:
		lbl_btn_x.text = "";
		lbl_btn_y.text = "Y: Swap";
		lbl_btn_b.text = "B: Cancel";
	return
