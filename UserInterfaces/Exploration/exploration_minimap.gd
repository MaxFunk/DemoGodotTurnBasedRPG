extends Control

@onready var minimap_rect := $MinimapRect as ColorRect;
@onready var icon_player := $IconPlayer as TextureRect;

var minimap_shader: ShaderMaterial;


func _ready() -> void:
	minimap_shader = minimap_rect.material as ShaderMaterial;
	return


func update_minimap(glob_pos: Vector3, glob_rot: Vector3) -> void:
	# 500 px == 100 m == 1.0 uv
	var uv_offset := Vector2(glob_pos.x / 100.0, glob_pos.z / 100.0);
	minimap_shader.set_shader_parameter("OffsetUV", uv_offset);
	
	icon_player.rotation = -glob_rot.y;
	return
