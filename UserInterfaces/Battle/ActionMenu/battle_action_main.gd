extends Control

@onready var labels: Array[Label] = [
	$LabelCopyItems as Label,
	$LabelCopyTactics as Label,
	$LabelAttack as Label,
	$LabelArts as Label,
	$LabelBlock as Label,
	$LabelItems as Label,
	$LabelTactics as Label,
	$LabelCopyAttack as Label,
	$LabelCopyArts as Label];

var rotation_per_elem: float = 22.5; # in degree


func change_rotation(input_index: int) -> void:
	rotation_degrees = -input_index * rotation_per_elem;
	
	for i in labels.size():
		labels[i].modulate.a = get_alpha_from_distance(absi(i - input_index - 2));
		labels[i].show_behind_parent = i != input_index + 2;
	return


func get_alpha_from_distance(dist: int) -> float:
	match dist:
		0: return 1.0
		1: return 0.4
		2: return 0.2
		_: return 0.0


func get_description_text(index: int) -> String:
	match index:
		0: return "Default Attack"
		1: return "Use Arts"
		2: return "Half damage of the next incoming attack"
		3: return "Use Items"
		4: return "Use Tactics such as Analyze"
		_: return "???"
