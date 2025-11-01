class_name EffectApply


static func apply(user: BattleData, target: BattleData, art: BattleArt) -> void:
	for i in art.effects.size():
		match art.effects[i]:
			EffectIDs.OFFENSE_UP: apply_stat_modifier(target, 0, art.effect_values[i]);
			EffectIDs.DEFENSE_UP: apply_stat_modifier(target, 1, art.effect_values[i]);
			EffectIDs.ACCURACY_UP: apply_stat_modifier(target, 2, art.effect_values[i]);
			EffectIDs.OFFENSE_DOWN: apply_stat_modifier(target, 0, -art.effect_values[i]);
			EffectIDs.DEFENSE_DOWN: apply_stat_modifier(target, 1, -art.effect_values[i]);
			EffectIDs.ACCURACY_DOWN: apply_stat_modifier(target, 2, -art.effect_values[i]);
			
			EffectIDs.APPLY_AILMENT_ART: continue # called through different function
			EffectIDs.APPLY_BURNED: apply_ailment(user, target, Ailments.BURNED, art.effect_values[i]);
			EffectIDs.APPLY_STUNNED: apply_ailment(user, target, Ailments.STUNNED, art.effect_values[i]);
			EffectIDs.APPLY_FROZEN: apply_ailment(user, target, Ailments.FROZEN, art.effect_values[i]);
			EffectIDs.APPLY_POISONED: apply_ailment(user, target, Ailments.POISONED, art.effect_values[i]);
			EffectIDs.APPLY_CONFUSED: apply_ailment(user, target, Ailments.CONFUSED, art.effect_values[i]);
			EffectIDs.APPLY_EXHAUSTED: apply_ailment(user, target, Ailments.EXHAUSTED, art.effect_values[i]);
			EffectIDs.APPLY_BLINDED: apply_ailment(user, target, Ailments.BLINDED, art.effect_values[i]);
			EffectIDs.APPLY_SHACKLED: apply_ailment(user, target, Ailments.SHACKLED, art.effect_values[i]);
			EffectIDs.APPLY_CORRUPTED: apply_ailment(user, target, Ailments.CORRUPTED, art.effect_values[i]);
			EffectIDs.APPLY_BLESSED: apply_ailment(user, target, Ailments.BLESSED, art.effect_values[i]);
			
			EffectIDs.HEAL_AILMENT: heal_ailment(target);
	return


static func apply_stat_modifier(target: BattleData, index: int, value: int) -> void:
	target.modifier[index] = clampi(target.modifier[index] + value, -2, 2);
	target.modifier_timer[index] = 3;
	target.update_display.emit();
	return


static func apply_ailment(user: BattleData, target: BattleData, ailment_idx: int, ailment_chance: int) -> void:
	var chance: float = ailment_chance * sqrt(user.stats[4] / float(target.stats[4])) / 100.0;
	if randf() > chance:
		return
	if target.ailment != 0:
		return
	target.ailment = ailment_idx;
	target.update_display.emit();
	return


static func apply_ailment_art(user: BattleData, target: BattleData, art: BattleArt) -> ActionResult:
	# include user hit chance boosts?
	# include attributes: block -> miss, resist -> half_chance?
	# do same for apply_ailment!
	var action_res := ActionResult.new();
	
	for i in art.effects.size():
		if art.effects[i] == EffectIDs.APPLY_AILMENT_ART:
			var ailment_idx: int = art.effect_values[i];
			var chance: float = art.accuracy * sqrt(user.stats[4] / float(target.stats[4])) / 100.0;
			chance *= effect_modifier(ailment_idx + EffectIDs.APPLY_AILMENT_ART, user);
			if randf() > chance or target.ailment != 0:
				action_res.is_missed = true;
				return action_res
			target.ailment = ailment_idx;
			action_res.ailment = ailment_idx;
			target.update_display.emit();
	return action_res


static func heal_ailment(target: BattleData) -> void:
	target.ailment = Ailments.NONE;
	target.ailment_turns = 0;
	print(target.name, " was healed from ailment");
	target.update_display.emit();
	return


static func damage_modifier_ailment(_user: BattleData, target: BattleData, art: BattleArt) -> float:
	if target.ailment == Ailments.NONE:
		return 1.0
	
	var modifier_percent: float = 0.0;
	for i in art.effects.size():
		if art.effects[i] < EffectIDs.BOOST_ON_BURNED or art.effects[i] > EffectIDs.BOOST_ON_BLESSED:
			continue
		var ailemt_id := art.effects[i] - EffectIDs.BOOST_ON_BURNED + 1;
		if ailemt_id == target.ailment:
			modifier_percent += art.effect_values[i] / 100.0;
	
	return 1.0 + modifier_percent


static func effect_modifier(effect_id: int, user: BattleData) -> float:
	var modifier_percent: float = 0.0;
	
	for art in user.arts:
		if art and art.is_passive_art():
			for i in art.effects.size():
				if art.effect_values[i] == effect_id:
					if art.effects[i] == EffectIDs.EFFECT_BOOST_25:
						modifier_percent += 0.25;
					elif art.effects[i] == EffectIDs.EFFECT_BOOST_50:
						modifier_percent += 0.5;
					elif art.effects[i] == EffectIDs.EFFECT_BOOST_100:
						modifier_percent += 1.0;
	
	return 1.0 + modifier_percent
