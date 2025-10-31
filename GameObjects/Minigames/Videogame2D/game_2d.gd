extends Node2D

@onready var player := $PlayerChar2D as CharacterBody2D;


func _process(delta: float) -> void:
	var input_x := Input.get_axis("D_Pad_Left", "D_Pad_Right");
	var input_factor: float = 1.0 if player.is_on_floor() else 0.667;
	player.velocity.x = input_x * input_factor * delta * 10000.0;
	player.velocity.y += 150.0 * delta;
	if Input.is_action_just_pressed("Btn_B") and player.is_on_floor():
		player.velocity.y = -150.0;
	
	player.move_and_slide();
	
	if player.position.y > 550:
		player.position = Vector2(20.0, 450.0);
		player.velocity = Vector2.ZERO;
	return
