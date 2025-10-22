extends StaticBody3D
# TODO: FULL HEAL INTERACTION!!!!
enum INTERACTION {TEXT, TELEPORT, ITEMGET}

@export var interaction_type := INTERACTION.TEXT;
@export var interaction_id := -1;


func _on_interaction_component_interaction() -> void:
	match interaction_type:
		INTERACTION.TEXT:
			print("Debug Block: Interaction Text");
		INTERACTION.TELEPORT:
			if interaction_id >= 0:
				GameData.main_scene.load_world(interaction_id);
		INTERACTION.ITEMGET:
			GameData.recieve_items(1, interaction_id, 1);
	return


func _ready() -> void:
	return
