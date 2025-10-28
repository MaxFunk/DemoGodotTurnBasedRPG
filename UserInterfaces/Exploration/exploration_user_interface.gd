class_name ExplorationUI extends Control

const ExplorationHeroOverview = preload("uid://me80g7f5ttfm");
const ItemView = preload("uid://con5ugiscqvps");
const QuestView = preload("uid://dnj8127vyphh2");
const Minimap = preload("uid://hrq8hdjwddus");
const EXPLORATION_ITEM_VIEW = preload("uid://ddjtcd5p6uyw4");

@onready var label_date := $ControlDate/LabelDate as Label;
@onready var label_day := $ControlDate/LabelDay as Label;
@onready var icon_weather := $ControlDate/IconWeather as ColorRect;
@onready var label_story := $ControlStory/RightPanel/LabelStoryQuest as Label;

@onready var hero_overview_1 := $ControlHeros/ExplorationHeroOverview1 as ExplorationHeroOverview;
@onready var hero_overview_2 := $ControlHeros/ExplorationHeroOverview2 as ExplorationHeroOverview;
@onready var hero_overview_3 := $ControlHeros/ExplorationHeroOverview3 as ExplorationHeroOverview;
@onready var quest_view_1 := $ControlQuests/ExplorationQuestView1 as QuestView;
@onready var quest_view_2 := $ControlQuests/ExplorationQuestView2 as QuestView;
@onready var quest_view_3 := $ControlQuests/ExplorationQuestView3 as QuestView;

@onready var ctrl_items := $ControlItems as Control;
@onready var minimap := $ExplorationMinimap as Minimap;
@onready var anim_player := $AnimationPlayer as AnimationPlayer;
@onready var label_interaction := $LabelInteraction as Label;

@onready var quest_update_ctrl := $ControlQuestUpdate as Control;
@onready var quest_update_header := $ControlQuestUpdate/LabelQuestHeader as Label;
@onready var quest_update_name := $ControlQuestUpdate/LabelQuestName as Label;
@onready var quest_update_timer := $ControlQuestUpdate/QuestUpdateTimer as Timer;

var current_world_scene: WorldScene = null;

var item_queue: Array[Item] = [];
var quest_queue: Array[Quest] = [];
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
	
	update_quest_view();
	return


func update_quest_view() -> void:
	quest_view_1.write_data(GameData.quest_manager.get_marked_quest(0));
	quest_view_2.write_data(GameData.quest_manager.get_marked_quest(1));
	quest_view_3.write_data(GameData.quest_manager.get_marked_quest(2));
	return


func minimap_update(player: PlayerCharacter) -> void:
	minimap.update_minimap(player.global_position, player.global_rotation);
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


func update_interaction_text(show_text: bool, txt: String) -> void:
	label_interaction.visible = show_text;
	label_interaction.text = txt;
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


func add_quest_to_queue(quest: Quest) -> void:
	if quest == null:
		return
	
	quest_queue.append(quest);
	fetch_quest_update();
	return


func fetch_quest_update() -> void:
	if quest_update_timer.is_stopped():
		if quest_queue.size() <= 0:
			return
		
		var fetched_quest := quest_queue[0];
		quest_queue.remove_at(0);
		if fetched_quest:
			quest_update_header.text = "Quest Completed!" if fetched_quest.completed else "New Quest!";
			quest_update_name.text = fetched_quest.quest_name;
			quest_update_ctrl.visible = true;
			quest_update_timer.start();
	return


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	fading_in = false;
	fading_out = false;
	return


func _on_quest_update_timer_timeout() -> void:
	quest_update_ctrl.visible = false;
	fetch_quest_update();
	return
