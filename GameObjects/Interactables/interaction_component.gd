class_name InteractionComponent
extends Area3D

@export var interaction_counter: int = -1;
@export var interaction_text: String = "";

signal interaction();
signal update_text();

var block_interaction: bool = false;


func emit_interaction() -> void:
	if interaction_counter < 0:
		interaction.emit();
		return
	
	if interaction_counter > 0:
		interaction_counter -= 1;
		interaction.emit();
	return


func is_interactable() -> bool:
	return interaction_counter != 0 and not block_interaction;


func get_interaction_text() -> String:
	update_text.emit();
	return interaction_text
