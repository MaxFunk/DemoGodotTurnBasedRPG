class_name ExplorationUI extends Control

const ExplorationHeroOverview = preload("uid://me80g7f5ttfm");
const ItemView = preload("uid://con5ugiscqvps")
const EXPLORATION_ITEM_VIEW = preload("uid://ddjtcd5p6uyw4")

@onready var label_date := $ControlDate/LabelDate as Label;
@onready var label_day := $ControlDate/LabelDay as Label;
@onready var icon_weather := $ControlDate/IconWeather as ColorRect;
@onready var label_story := $ControlStory/RightPanel/LabelStoryQuest as Label;

@onready var hero_overview_1 := $ControlHeros/ExplorationHeroOverview1 as ExplorationHeroOverview;
@onready var hero_overview_2 := $ControlHeros/ExplorationHeroOverview2 as ExplorationHeroOverview;
@onready var hero_overview_3 := $ControlHeros/ExplorationHeroOverview3 as ExplorationHeroOverview;
@onready var ctrl_items := $ControlItems as Control;
@onready var anim_player := $AnimationPlayer as AnimationPlayer;

var current_world_scene: WorldScene = null;

var item_queue: Array[Item] = [];
var items_displayed: Array[ItemView] = [];
var max_items_displayable: int = 5;
var show_item_view_for: float = 5.0;

var fading_in: bool = false;
var fading_out: bool = false;


func _process(delta: float) -> void:
	for item_view in items_displayed:
		item_view.time_active += delta
		if item_view.time_active > show_item_view_for:
			remove_item_view(item_view);
	
	if item_queue.size() > 0 and items_displayed.size() < max_items_displayable:
		var front_item := item_queue[0];
		item_queue.remove_at(0);
		add_view_item(front_item);
	return


func update_data() -> void:
	label_date.text = ResourceManager.dates_table.records[GameData.date_id]["as_string"];
	label_day.text = ResourceManager.dates_table.records[GameData.date_id]["weekday_short"];
	
	hero_overview_1.update_data(GameData.get_active_party_member(0));
	hero_overview_2.update_data(GameData.get_active_party_member(1));
	hero_overview_3.update_data(GameData.get_active_party_member(2));
	return


func queue_new_item(new_item: Item) -> void:
	item_queue.append(new_item);
	return


func add_view_item(item: Item) -> void:
	var new_item_view := EXPLORATION_ITEM_VIEW.instantiate() as ItemView;
	ctrl_items.add_child(new_item_view);
	new_item_view.update_data(item);
	new_item_view.position.y = items_displayed.size() * new_item_view.size.y;
	items_displayed.append(new_item_view);
	return


func remove_item_view(view: ItemView) -> void:
	items_displayed.erase(view);
	ctrl_items.remove_child(view);
	view.queue_free();
	
	for i in items_displayed.size():
		items_displayed[i].position.y = items_displayed[i].size.y * i;
	return


func detail_fade_in() -> void:
	if fading_out:
		var start_time := anim_player.current_animation_length - anim_player.current_animation_position;
		anim_player.play_section("DetailFadeIn", start_time);
		fading_out = false;
	else:
		anim_player.play("DetailFadeIn");
	fading_in = true;
	return


func detail_fade_out() -> void:
	if fading_in:
		var start_time := anim_player.current_animation_length - anim_player.current_animation_position;
		anim_player.play_section("DetailFadeOut", start_time);
		fading_in = false;
	else:
		anim_player.play("DetailFadeOut");
	fading_out = true;
	return


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	fading_in = false;
	fading_out = false;
	return
