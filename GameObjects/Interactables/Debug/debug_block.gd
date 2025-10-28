extends StaticBody3D
# TODO: FULL HEAL INTERACTION!!!!
enum INTERACTION {TEXT, TELEPORT, ITEMGET, GIVEQUEST, EVENT}

@onready var interact_comp := $InteractionComponent as InteractionComponent;

@export var interaction_type := INTERACTION.TEXT;
@export var interaction_id := -1;
@export var interaction_text := "Debug Block";


func _on_interaction_component_interaction() -> void:
	match interaction_type:
		INTERACTION.TEXT:
			print("Debug Block: Interaction Text");
		INTERACTION.TELEPORT:
			if interaction_id >= 0:
				GameData.main_scene.load_world(interaction_id);
				interact_comp.block_interaction = true;
		INTERACTION.ITEMGET:
			var category: int = floori(interaction_id / 1000.0);
			if category >= 0 and category < 4:
				var item_id := interaction_id - category * 1000;
				GameData.recieve_items(category, item_id, 1);
		INTERACTION.GIVEQUEST:
			GameData.quest_manager.add_new_quest(interaction_id);
		INTERACTION.EVENT:
			GameData.quest_manager.event_check(QuestManager.EVENTTYPE.INTERACT, interaction_id, 1);
	return


func _ready() -> void:
	interact_comp.interaction_text = interaction_text;
	return
