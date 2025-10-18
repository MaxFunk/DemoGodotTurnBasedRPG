class_name BattleField extends Node3D

enum FIELDTYPE {GLOBAL, ALLIED, OPPOSITE}

const anim_field_create: StringName = "FieldCreate";
const anim_field_loop: StringName = "FieldLoop";
const anim_field_fade: StringName = "FieldFade";

@export var field_type := FIELDTYPE.GLOBAL;
@export var field_effect: int = -1;
@export var max_turns_active: int = 3;
@export var anim_player: AnimationPlayer = null;
@export var is_permanent: bool = false;

var turns_active: int = 0;
var caster: BattleData = null;


func increas_turn_timer() -> bool:
	turns_active += 1;
	return turns_active > max_turns_active
