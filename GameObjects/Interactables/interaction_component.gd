class_name InteractionComponent
extends Area3D

@export var interaction_counter: int = -1;

signal interaction();


func emit_interaction() -> void:
	if interaction_counter < 0:
		interaction.emit();
		return
	
	if interaction_counter > 0:
		interaction_counter -= 1;
		interaction.emit();
	return
