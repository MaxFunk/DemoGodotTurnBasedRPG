extends Control

@onready var selector := $BackPanel/Selector as ColorRect;
@onready var lbls: Array[Label] = [
	$BackPanel/LabelInspect as Label,
	$BackPanel/LabelAnalyze as Label,
	$BackPanel/LabelSwitch as Label,
	$BackPanel/LabelRun as Label];


func update_selector(index: int) -> void:
	var idx: int = clampi(index, 0, 3);
	selector.position.y = lbls[idx].position.y;
	return
