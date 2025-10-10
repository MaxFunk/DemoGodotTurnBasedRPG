extends Control

@onready var labels: Array[Label] = [
	$LabelAttack as Label,
	$LabelArts as Label,
	$LabelUlt as Label,
	$LabelBlock as Label,
	$LabelItems as Label,
	$LabelTactics as Label];

var rotation_per_elem: float = 18.0; # in degree


func change_rotation(input_index: int) -> void:
	rotation_degrees = -input_index * 18.0;
	
	for i in 6:
		labels[i].modulate.a = get_alpha_from_distance(absi(i - input_index));
		labels[i].show_behind_parent = i != input_index;
	return


func get_alpha_from_distance(dist: int) -> float:
	match dist:
		0: return 1.0
		1: return 0.5
		2: return 0.3
		3: return 0.2
		4: return 0.1
		_: return 0.0


func get_description_text(index: int) -> String:
	match index:
		0: return "Default Attack"
		1: return "Use Arts"
		2: return "TODO: move Ult to Arts"
		3: return "Half damage of the next incoming attack"
		4: return "Use Items"
		_: return "Use Tactics such as Analyze"
