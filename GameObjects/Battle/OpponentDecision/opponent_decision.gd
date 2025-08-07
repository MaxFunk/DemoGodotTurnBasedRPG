class_name OpponentDecision


static func decide_action_standard(opponent: BattleData, scene: BattleScene) -> ActionData:
	var action := ActionData.new(ActionData.ACTIONTYPE.ATTACK, scene);
	
	if opponent.ult_points >= 100 and opponent.ult_art:
		action.action_type = ActionData.ACTIONTYPE.ULT;
		action.set_targettype_from_art(opponent.ult_art);
		action.select_random_target_as_opponent();
		return action
	
	if randf() < 0.05:
		action.action_type = ActionData.ACTIONTYPE.ATTACK;
		action.set_targettype_from_art(opponent.default_attack);
		action.select_random_target_as_opponent();
		return action
	
	var valid_indicies: PackedInt32Array = [];
	for i in 7:
		if opponent.arts[i] != null and !opponent.arts[i].is_passive_art():
			valid_indicies.append(i);
	
	var random_index: int = randi_range(0, valid_indicies.size() - 1);
	action.action_type = ActionData.ACTIONTYPE.ART;
	action.set_targettype_from_art(opponent.arts[random_index]);
	action.select_random_target_as_opponent();
	return action
