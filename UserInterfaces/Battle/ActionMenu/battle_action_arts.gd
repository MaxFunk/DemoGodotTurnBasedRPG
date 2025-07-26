extends Control

const ArtDisplay := preload("res://UserInterfaces/Battle/ActionMenu/art_display.gd");

@onready var selector := $Selector as ColorRect;
@onready var art_disps: Array[ArtDisplay] = [
	$BackPanel/ArtDisplay1 as ArtDisplay,
	$BackPanel/ArtDisplay2 as ArtDisplay,
	$BackPanel/ArtDisplay3 as ArtDisplay,
	$BackPanel/ArtDisplay4 as ArtDisplay,
	$BackPanel/ArtDisplay5 as ArtDisplay,
	$BackPanel/ArtDisplay6 as ArtDisplay,
	$BackPanel/ArtDisplay7 as ArtDisplay];


func update_ui(chd: BattleData) -> void:
	for i in range(7):
		art_disps[i].update(chd.arts[i], chd);
	return


func update_selector(index: int) -> void:
	var idx: int = clampi(index, 0, 6);
	selector.position.y = art_disps[idx].position.y;
	return
