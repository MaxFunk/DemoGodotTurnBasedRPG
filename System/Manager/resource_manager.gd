extends Node

const dates_table := preload("res://Resources/DataTables/dates.csv");


func get_hero_model(id: int) -> PackedScene:
	match id:
		0: return preload("res://Resources/Models/Heros/hero_M.glb");
		1: return preload("res://Resources/Models/Heros/hero_A.glb");
		_: return preload("res://Resources/Models/Heros/hero_E.glb");


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
		5: return preload("res://Resources/Images/ArtIcons/icon_spell_soulpower.png");
		6: return preload("res://Resources/Images/ArtIcons/icon_spell_passive.png");
		_: return preload("res://Resources/Images/ArtIcons/icon_spell_none.png");
