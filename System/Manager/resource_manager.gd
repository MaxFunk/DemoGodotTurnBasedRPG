extends Node

const dates_table := preload("res://Resources/DataTables/dates.csv");


func get_hero_model(id: int) -> PackedScene:
	match id:
		0: return preload("res://Resources/Models/Heros/hero_m.glb");
		1: return preload("res://Resources/Models/Heros/hero_a.glb");
		_: return preload("res://Resources/Models/Heros/hero_e.glb");


func get_hero_portrait(id: int) -> CompressedTexture2D:
	match id:
		0: return preload("res://Resources/Images/CharacterPortraits/character_portrait_hero_0.png");
		1: return preload("res://Resources/Images/CharacterPortraits/character_portrait_hero_1.png");
		2: return preload("res://Resources/Images/CharacterPortraits/character_portrait_hero_2.png");
		3: return preload("res://Resources/Images/CharacterPortraits/character_portrait_hero_3.png");
		4: return preload("res://Resources/Images/CharacterPortraits/character_portrait_hero_4.png");
		5: return preload("res://Resources/Images/CharacterPortraits/character_portrait_hero_5.png");
		6: return preload("res://Resources/Images/CharacterPortraits/character_portrait_hero_6.png");
		_: return preload("res://Resources/Images/CharacterPortraits/character_portrait_hero_7.png");


func get_art_category_icon(id: int) -> CompressedTexture2D:
	match id:
		0: return preload("res://Resources/Images/ArtIcons/icon_spell_physical.png");
		1: return preload("res://Resources/Images/ArtIcons/icon_spell_ether.png");
		2: return preload("res://Resources/Images/ArtIcons/icon_spell_heal.png");
		3: return preload("res://Resources/Images/ArtIcons/icon_spell_strategy.png");
		4: return preload("res://Resources/Images/ArtIcons/icon_spell_ailment.png");
		5: return preload("res://Resources/Images/ArtIcons/icon_spell_field.png");
		6: return preload("res://Resources/Images/ArtIcons/icon_spell_soulpower.png");
		7: return preload("res://Resources/Images/ArtIcons/icon_spell_passive.png");
		_: return preload("res://Resources/Images/ArtIcons/icon_spell_none.png");


func get_opponent_data(id: int) -> Dictionary:
	const opponent_dt := preload("res://Resources/DataTables/opponents_battle_data.csv");
	if id >= 0 and id < opponent_dt.records.size():
		return opponent_dt.records[id];
	return {}


func get_textbox_data(id: int) -> TextboxData:
	const textbox_csv := preload("res://Resources/DataTables/textbox_data.csv");
	if id < 0 or id >= textbox_csv.records.size():
		return null
	
	var textbox_row := textbox_csv.records[id] as Dictionary;
	var td := TextboxData.new();
	
	td.id = textbox_row["id"];
	var next_id_str: String = textbox_row["next_id_1"];
	td.next_id_1 = int(next_id_str) if next_id_str != "" else -1;
	next_id_str = textbox_row["next_id_2"];
	td.next_id_2 = int(next_id_str) if next_id_str != "" else -1;
	
	td.is_question = true if (textbox_row["is_question"] as String) == "1" else false;
	
	td.speaker_name = textbox_row["speaker"];
	td.text = textbox_row["text"];
	td.speaker_icon = textbox_row["icon"];
	td.answer_1 = textbox_row["answer_1"];
	td.answer_2 = textbox_row["answer_2"];
	
	td.next_td_1 = get_textbox_data(td.next_id_1);
	td.next_td_2 = get_textbox_data(td.next_id_2);
	return td
