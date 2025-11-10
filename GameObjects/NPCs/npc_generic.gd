extends StaticBody3D

@onready var interact_comp := $InteractionComponent as InteractionComponent;

@export var first_text_id: int = -1;
@export var model_packed_scene: PackedScene;
@export var interaction_text := "Talk";
@export var event_id: int = -1;
@export var conditional_spawn: bool = false;
@export var main_quest_steps: Array[int] = [];

var model_3d: Model3D = null;


func _ready() -> void:
	interact_comp.interaction_text = interaction_text;
	
	if conditional_spawn and !main_quest_steps.has(GameData.quest_manager.main_quest.step):
		interact_comp.process_mode = Node.PROCESS_MODE_DISABLED;
		queue_free();
		return
	
	if model_packed_scene:
		model_3d = model_packed_scene.instantiate() as Model3D;
		add_child(model_3d);
		if model_3d.play_animation("Idle") == false:
			model_3d.play_animation("IdleStanding");
	return


func _on_interaction_component_interaction() -> void:
	GameData.main_scene.instantiate_talking_ui(first_text_id);
	GameData.quest_manager.event_check(QuestManager.EVENTTYPE.TALK, event_id, 1);
	return
