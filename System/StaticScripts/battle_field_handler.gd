class_name BattleFieldHandler

# TODO: give all ids of art, first is field_id, rest is field_effects
static func get_field_scene(field_id: int) -> PackedScene:
	match field_id:
		0: return preload("res://GameObjects/Battle/Fields/battle_field_offense_aura.tscn");
		_: return preload("res://GameObjects/Battle/Fields/battle_field_offense_aura.tscn");


static func field_modifier_damage(scene: BattleScene, user: BattleData) -> float:
	var modifier: float = 1.0;
	#var global_field := scene.battle_fields[0];
	var ally_field := scene.battle_fields[1] if user.is_hero else scene.battle_fields[2];
	#var oppo_field := scene.battle_fields[2] if user.is_hero else scene.battle_fields[1];
	
	if ally_field:
		if ally_field.field_effect == EffectIDs.FIELD_DAMAGE_UP:
			modifier *= 1.25;
		elif ally_field.field_effect == EffectIDs.FIELD_DAMAGE_DOWN:
			modifier *= 0.75;
	
	return modifier
