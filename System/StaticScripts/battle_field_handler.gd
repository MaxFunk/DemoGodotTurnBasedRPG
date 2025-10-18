class_name BattleFieldHandler

# TODO: give all ids of art, first is field_id, rest is field_effects
static func get_field_scene(field_id: int) -> PackedScene:
	match field_id:
		0: return preload("res://GameObjects/Battle/Fields/battle_field_offense_aura.tscn");
		_: return preload("res://GameObjects/Battle/Fields/battle_field_offense_aura.tscn");
