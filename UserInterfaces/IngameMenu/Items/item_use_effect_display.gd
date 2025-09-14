extends Control

const bar_health := preload("res://Resources/Images/ProgressBars/progbar_fill_health.png") as CompressedTexture2D;
const bar_stamina := preload("res://Resources/Images/ProgressBars/progbar_fill_stamina.png") as CompressedTexture2D;
const bar_stat := preload("res://Resources/Images/ProgressBars/progbar_fill_stats.png") as CompressedTexture2D;
const bar_full := preload("res://Resources/Images/ProgressBars/progbar_fill_statsfull.png") as CompressedTexture2D;

const txt_art_1: StringName = "Art already learned";
const txt_art_2: StringName = "Art learnable";

@onready var prog_bar := $TextureProgressBar as TextureProgressBar;
@onready var lbl_bar_value := $LabelBarValue as Label;
@onready var lbl_full_text := $LabelFullText as Label;


func update_view(cd: CharacterData, item: ItemConsumable) -> void:
	prog_bar.visible = item.type != item.TYPE.ART_SHARD;
	lbl_bar_value.visible = item.type != item.TYPE.ART_SHARD;
	lbl_full_text.visible = item.type == item.TYPE.ART_SHARD;
	
	match item.type:
		item.TYPE.RESTORE_HP:
			prog_bar.texture_progress = bar_health;
			prog_bar.max_value = cd.accum_stats[0];
			prog_bar.value = cd.cur_health;
			lbl_bar_value.text = str(cd.cur_health);
		
		item.TYPE.RESTORE_SP:
			prog_bar.texture_progress = bar_stamina;
			prog_bar.max_value = cd.accum_stats[1];
			prog_bar.value = cd.cur_stamina;
			lbl_bar_value.text = str(cd.cur_stamina);
		
		item.TYPE.DISHES:
			var dish_id := item.effects[0];
			match dish_id:
				EffectIDs.ITEM_DISH_HEALTH:
					prog_bar.texture_progress = bar_health;
					prog_bar.max_value = cd.accum_stats[0];
					prog_bar.value = cd.cur_health;
					lbl_bar_value.text = str(cd.cur_health);
				EffectIDs.ITEM_DISH_STAMINA:
					prog_bar.texture_progress = bar_stamina;
					prog_bar.max_value = cd.accum_stats[1];
					prog_bar.value = cd.cur_stamina;
					lbl_bar_value.text = str(cd.cur_stamina);
				_:
					update_stat(cd, item.effect_values[0]);
		
		item.TYPE.STAT_SHARD:
			update_stat(cd, item.effects[0]);
		
		item.TYPE.ART_SHARD:
			var new_art_id := item.effects[0];
			lbl_full_text.text = txt_art_1 if cd.art_ids.has(new_art_id) else txt_art_2;
			lbl_full_text.modulate.a = 0.35 if cd.art_ids.has(new_art_id) else 1.0;
	return


func update_stat(cd: CharacterData, stat_id: int) -> void:
	match stat_id:
		0:
			prog_bar.texture_progress = bar_health;
			prog_bar.max_value = cd.accum_stats[0];
			prog_bar.value = cd.cur_health;
			lbl_bar_value.text = str(cd.cur_health);
		1:
			prog_bar.texture_progress = bar_stamina;
			prog_bar.max_value = cd.accum_stats[1];
			prog_bar.value = cd.cur_stamina;
			lbl_bar_value.text = str(cd.cur_stamina);
		_:
			prog_bar.texture_progress = bar_stat if cd.accum_stats[stat_id] < 100 else bar_full;
			prog_bar.max_value = 100;
			prog_bar.value = cd.accum_stats[stat_id];
			lbl_bar_value.text = str(cd.accum_stats[stat_id]);
	return
