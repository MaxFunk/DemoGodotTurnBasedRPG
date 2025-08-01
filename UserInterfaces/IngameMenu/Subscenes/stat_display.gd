extends Control

const texture_stat := preload("res://Resources/Images/ProgressBars/progbar_fill_stats.png");
const texture_statfull := preload("res://Resources/Images/ProgressBars/progbar_fill_statsfull.png");

enum DISPLAYTYPE {PHYATT, PHYDEF, ETHATT, ETHDEF, LUCK, AGIL}

@onready var lbl_stat_name := $LabelStatName as Label;
@onready var lbl_stat_value := $LabelStatValue as Label;
@onready var prog_bar := $TextureProgressBar as TextureProgressBar;

@export var display_type := DISPLAYTYPE.PHYATT;


func _ready() -> void:
	match display_type:
		DISPLAYTYPE.PHYATT: lbl_stat_name.text = "PhyAtt";
		DISPLAYTYPE.PHYDEF: lbl_stat_name.text = "PhyDef";
		DISPLAYTYPE.ETHATT: lbl_stat_name.text = "EthAtt";
		DISPLAYTYPE.ETHDEF: lbl_stat_name.text = "EthDef";
		DISPLAYTYPE.LUCK: lbl_stat_name.text = "Luck";
		DISPLAYTYPE.AGIL: lbl_stat_name.text = "Agility";
	return


func update_bar(chd: CharacterData) -> void:
	var value: int = 0;
	match display_type:
		DISPLAYTYPE.PHYATT: value = chd.accum_stats[2];
		DISPLAYTYPE.PHYDEF: value = chd.accum_stats[3];
		DISPLAYTYPE.ETHATT: value = chd.accum_stats[4];
		DISPLAYTYPE.ETHDEF: value = chd.accum_stats[5];
		DISPLAYTYPE.LUCK: value = chd.accum_stats[6];
		DISPLAYTYPE.AGIL: value = chd.accum_stats[7];
	
	lbl_stat_value.text = str(value);
	if value >= 100:
		prog_bar.texture_progress = texture_statfull;
		prog_bar.value = 100;
	else:
		prog_bar.texture_progress = texture_stat;
		prog_bar.value = value;
	return


func update_inspect(bd: BattleData, show_data: bool) -> void:
	var value: int = 0;
	match display_type:
		DISPLAYTYPE.PHYATT: value = bd.stats[0];
		DISPLAYTYPE.PHYDEF: value = bd.stats[1];
		DISPLAYTYPE.ETHATT: value = bd.stats[2];
		DISPLAYTYPE.ETHDEF: value = bd.stats[3];
		DISPLAYTYPE.LUCK: value = bd.stats[4];
		DISPLAYTYPE.AGIL: value = bd.stats[5];
	
	lbl_stat_value.text = str(value) if show_data else "??";
	
	if !show_data:
		prog_bar.value = 0;
		return
	
	if value >= 100:
		prog_bar.texture_progress = texture_statfull;
		prog_bar.value = 100;
	else:
		prog_bar.texture_progress = texture_stat;
		prog_bar.value = value;
	return
