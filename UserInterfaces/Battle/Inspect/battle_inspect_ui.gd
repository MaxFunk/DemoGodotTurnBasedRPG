extends Control

const HeroPanel = preload("uid://bwycxo8x0hguv");
const EnemyPanel = preload("uid://bepj5ks3emqh6");

@onready var hero_panels: Array[HeroPanel] = [
	$BattleInspectHeroPanel1 as HeroPanel,
	$BattleInspectHeroPanel2 as HeroPanel,
	$BattleInspectHeroPanel3 as HeroPanel];
@onready var enemy_panels: Array[EnemyPanel] = [
	$BattleInspectEnemyPanel1 as EnemyPanel,
	$BattleInspectEnemyPanel2 as EnemyPanel,
	$BattleInspectEnemyPanel3 as EnemyPanel,
	$BattleInspectEnemyPanel4 as EnemyPanel,
	$BattleInspectEnemyPanel5 as EnemyPanel];
@onready var field_labels: Array[Label] = [
	$ControlFieldEffects/LabelGlobalField as Label,
	$ControlFieldEffects/LabelHeroField as Label,
	$ControlFieldEffects/LabelOppoField as Label
];

var selection_index: int = 0;
var hero_row: bool = true;


func update_view(battle_scene: BattleScene) -> void:
	for i in battle_scene.active_heros.size():
		hero_panels[i].update_view(battle_scene.active_heros[i]);
	
	for i in battle_scene.opponents.size():
		enemy_panels[i].update_view(battle_scene.opponents[i]);
	
	for i in battle_scene.battle_fields.size():
		var field := battle_scene.battle_fields[i];
		if field:
			field_labels[i].text = field.name;
		else:
			field_labels[i].text = "-";
	return


func update_selection() -> void:
	var index: int = 0;
	match selection_index:
		-2: index = 3;
		-1: index = 2 if hero_row else 1;
		1: index = 1 if hero_row else 2;
		2: index = 4;
		_: pass
	
	for i in hero_panels.size():
		hero_panels[i].set_selection(hero_row and index == i);
	
	for i in enemy_panels.size():
		enemy_panels[i].set_selection(!hero_row and index == i);
	return


func change_row() -> void:
	hero_row = !hero_row;
	if hero_row:
		selection_index = clampi(selection_index, -1, 1);
	update_selection();
	return


func change_selection(dir: int) -> void:
	if hero_row:
		selection_index = clampi(selection_index + dir, -1, 1);
	else:
		selection_index = clampi(selection_index + dir, -2, 2);
	update_selection()
	return


func reset_selection(hero_pos: int = 0) -> void:
	match hero_pos:
		1: selection_index = 1;
		2: selection_index = -1;
		_: selection_index = 0;
	hero_row = true;
	update_selection();
	return


func return_selection() -> int:
	match selection_index:
		-2: return 3;
		-1: return 2 if hero_row else 1;
		1: return 1 if hero_row else 2;
		2: return 4;
		_: return 0;
