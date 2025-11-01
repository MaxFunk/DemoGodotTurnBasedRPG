extends Label

const color_physical := Color(1.0, 0.435, 0.298);
const color_ether := Color(0.404, 0.89, 1.0);
const color_soul := Color(0.753, 0.961, 0.851);
const color_heal := Color(0.541, 0.847, 0.263);
const color_ailment := Color(1.0, 0.718, 0.835);

var max_time_alive: float = 0.5;
var time_alive: float = 0.0;


func _process(delta: float) -> void:
	time_alive += delta;
	if time_alive > max_time_alive:
		queue_free();
	return


func set_text_data(action_result: ActionResult, screen_pos: Vector2, art: BattleArt) -> void:
	# Damage, missed, is_crit, attr_behav
	position = screen_pos;
	
	match art.category:
		art.CATEGORY.PHYSICAL: modulate = color_physical;
		art.CATEGORY.ETHER: modulate = color_ether;
		art.CATEGORY.SOULPOWER: modulate = color_soul;
		art.CATEGORY.HEAL: modulate = color_heal;
		art.CATEGORY.AILMENT: modulate = color_ailment;
		_: modulate = Color.WHITE;
	
	if action_result.is_missed:
		text = "MISS";
		return
	
	if action_result.attribute_multiplier == 0.0:
		text = "BLOCK"
		return
	
	if art.category == art.CATEGORY.HEAL and action_result.healing > 0:
		text = str(action_result.healing);
		return
	elif art.category == art.CATEGORY.AILMENT:
		text = Ailments.get_ailment_text(action_result.ailment);
		return
	else:
		text = str(action_result.damage);
	
	if action_result.attribute_multiplier > 1.0:
		text += "+";
	elif action_result.attribute_multiplier < 1.0:
		text += "-";
	
	if action_result.is_crit:
		text += "!";
	return
