class_name LoadingScreen extends ColorRect

signal fade_finished;

@onready var icon := $LoadIcon as ColorRect;

var is_fading_in: bool = false;
var is_fading_out: bool = false;


func _process(delta: float) -> void:
	if visible:
		icon.rotation += delta;
	
	if is_fading_in:
		fade_color(1, delta);
	if is_fading_out:
		fade_color(-1, delta);
	return


func start_fade_in() -> void:
	visible = true;
	is_fading_in = true;
	is_fading_out = false;
	modulate.a = 0.0;
	icon.rotation = 0.0;
	return


func start_fade_out() -> void:
	visible = true;
	is_fading_in = false;
	is_fading_out = true;
	modulate.a = 1.0;
	return


func set_active() -> void:
	visible = true;
	is_fading_in = false;
	is_fading_out = false;
	modulate.a = 1.0;
	icon.rotation = 0.0;
	return


func fade_color(dir: float, delta: float) -> void:
	modulate.a += dir * delta * 4.0;
	
	if dir > 0 and modulate.a >= 1.0: # fade in
		modulate.a = 1.0;
		is_fading_in = false;
		fade_finished.emit();
		return
	
	if dir < 0 and modulate.a <= 0.0: # fade out
		modulate.a = 0.0;
		is_fading_out = false;
		visible = false;
		fade_finished.emit();
	return
