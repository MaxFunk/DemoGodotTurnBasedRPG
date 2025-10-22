extends Node3D

@export var interact_btn2_activator: InteractionComponent = null;

@onready var pillars: Array[AnimatableBody3D] = [
	$Pillar1 as AnimatableBody3D,
	$Pillar2 as AnimatableBody3D,
	$Pillar3 as AnimatableBody3D,
	$Pillar4 as AnimatableBody3D,
	$Pillar5 as AnimatableBody3D];

@onready var mesh_btn_1 := $InteractionComponent1/MeshButton1 as MeshInstance3D;
@onready var mesh_btn_2 := $InteractionComponent2/MeshButton2 as MeshInstance3D;
@onready var mesh_btn_3 := $InteractionComponent3/MeshButton3 as MeshInstance3D;
@onready var interact_comp_1 := $InteractionComponent1 as InteractionComponent;
@onready var interact_comp_2 := $InteractionComponent2 as InteractionComponent;
@onready var interact_comp_3 := $InteractionComponent3 as InteractionComponent;

const pillar_amount: int = 5;

var btn_1_active: bool = true;
var btn_2_active: bool = false;
var btn_3_active: bool = true;
var wait_for_move: bool = false;

var btn_1_state: int = 0;
var btn_2_state: int = 0;
var btn_3_state: int = 0;

var target_pos: PackedFloat32Array = [-4.9, -4.9, -4.9, -4.9, -4.9];
var pillar_dir: PackedFloat32Array = [0, 0, 0, 0, 0];


func _ready() -> void:
	var mat_1 := mesh_btn_1.get_surface_override_material(0) as ShaderMaterial;
	mat_1.set_shader_parameter("ButtonActive", btn_1_active);
	var mat_2 := mesh_btn_2.get_surface_override_material(0) as ShaderMaterial;
	mat_2.set_shader_parameter("ButtonActive", btn_2_active);
	var mat_3 := mesh_btn_3.get_surface_override_material(0) as ShaderMaterial;
	mat_3.set_shader_parameter("ButtonActive", btn_3_active);
	
	interact_comp_1.block_interaction = !btn_1_active;
	interact_comp_2.block_interaction = !btn_2_active;
	interact_comp_3.block_interaction = !btn_3_active;
	if interact_btn2_activator:
		interact_btn2_activator.interaction.connect(on_interaction_btn2_activation);
	return


func _physics_process(delta: float) -> void:
	if wait_for_move:
		var pillars_finished: int = 0;
		for i in pillar_amount:
			if is_equal_approx(pillars[i].position.y, target_pos[i]):
				pillars_finished += 1;
			else:
				var motion := Vector3(0, pillar_dir[i] * delta, 0);
				pillars[i].move_and_collide(motion);
		
		if pillars_finished >= pillar_amount:
			interact_comp_1.block_interaction = !btn_1_active;
			interact_comp_2.block_interaction = !btn_2_active;
			interact_comp_3.block_interaction = !btn_3_active;
			wait_for_move = false;
	return


func change_pillars() -> void:
	var new_states: PackedInt32Array = [0, 0, 0, 0, 0];
	
	if btn_1_state == 1:
		new_states[0] += 1;
		new_states[2] += 1;
		new_states[4] += 2;
	elif btn_1_state == 2:
		new_states[0] += 3;
		new_states[4] += 2;
	
	if btn_2_state == 1:
		new_states[1] += 3;
		new_states[3] += 2;
	elif btn_2_state == 2:
		new_states[2] += 2;
		new_states[3] += 4;
	
	if btn_3_state == 1:
		new_states[1] += 2;
		new_states[4] += 1;
	elif btn_3_state == 2:
		new_states[1] += 2;
		new_states[4] += 3;
	
	for i in pillar_amount:
		target_pos[i] = -4.9 + new_states[i];
		pillar_dir[i] = target_pos[i] - pillars[i].position.y;
	
	interact_comp_1.block_interaction = true;
	interact_comp_2.block_interaction = true;
	interact_comp_3.block_interaction = true;
	wait_for_move = true;
	return


func change_button_activity(btn_num: int, value: bool) -> void:
	if btn_num == 1:
		btn_1_active = value;
		var mat_1 := mesh_btn_1.get_surface_override_material(0) as ShaderMaterial;
		mat_1.set_shader_parameter("ButtonActive", btn_1_active);
	elif btn_num == 2:
		btn_2_active = value;
		var mat_2 := mesh_btn_2.get_surface_override_material(0) as ShaderMaterial;
		mat_2.set_shader_parameter("ButtonActive", btn_2_active);
	elif btn_num == 3:
		btn_3_active = value;
		var mat_3 := mesh_btn_3.get_surface_override_material(0) as ShaderMaterial;
		mat_3.set_shader_parameter("ButtonActive", btn_3_active);
	return


func _on_interaction_component_1_interaction() -> void:
	if btn_1_active and not wait_for_move:
		btn_1_state += 1;
		if btn_1_state > 2:
			btn_1_state = 0;
		change_pillars();
		var mat_1 := mesh_btn_1.get_surface_override_material(0) as ShaderMaterial;
		mat_1.set_shader_parameter("ButtonMode", btn_1_state);
	return


func _on_interaction_component_2_interaction() -> void:
	if btn_2_active and not wait_for_move:
		btn_2_state += 1;
		if btn_2_state > 2:
			btn_2_state = 0;
		change_pillars();
		var mat_2 := mesh_btn_2.get_surface_override_material(0) as ShaderMaterial;
		mat_2.set_shader_parameter("ButtonMode", btn_2_state);
	return


func _on_interaction_component_3_interaction() -> void:
	if btn_3_active and not wait_for_move:
		btn_3_state += 1;
		if btn_3_state > 2:
			btn_3_state = 0;
		change_pillars();
		var mat_3 := mesh_btn_3.get_surface_override_material(0) as ShaderMaterial;
		mat_3.set_shader_parameter("ButtonMode", btn_3_state);
	return


func on_interaction_btn2_activation() -> void:
	if btn_2_active == false:
		change_button_activity(2, true);
	interact_comp_2.block_interaction = !btn_2_active;
	return
