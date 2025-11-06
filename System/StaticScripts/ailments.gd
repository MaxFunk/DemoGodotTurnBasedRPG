class_name Ailments

enum {
	NONE = 0,
	BURNED = 1,
	STUNNED = 2,
	FROZEN = 3,
	POISONED = 4,
	CONFUSED = 5,
	EXHAUSTED = 6,
	BLINDED = 7,
	SHACKLED = 8,
	CORRUPTED = 9,
	BLESSED = 10
}


static func get_ailment_icon(id: int) -> CompressedTexture2D:
	match id:
		NONE: return preload("res://Resources/Images/AilmentIcons/ailment_icon_0_none.png");
		BURNED: return preload("res://Resources/Images/AilmentIcons/ailment_icon_1_burned.png");
		STUNNED: return preload("res://Resources/Images/AilmentIcons/ailment_icon_2_stunned.png");
		FROZEN: return preload("res://Resources/Images/AilmentIcons/ailment_icon_3_frozen.png");
		POISONED: return preload("res://Resources/Images/AilmentIcons/ailment_icon_4_poisoned.png");
		CONFUSED: return preload("res://Resources/Images/AilmentIcons/ailment_icon_5_confused.png");
		EXHAUSTED: return preload("res://Resources/Images/AilmentIcons/ailment_icon_6_exhausted.png");
		BLINDED: return preload("res://Resources/Images/AilmentIcons/ailment_icon_7_blinded.png");
		SHACKLED: return preload("res://Resources/Images/AilmentIcons/ailment_icon_8_shackled.png");
		CORRUPTED: return preload("res://Resources/Images/AilmentIcons/ailment_icon_9_corrupted.png");
		BLESSED: return preload("res://Resources/Images/AilmentIcons/ailment_icon_10_blessed.png");
		_: return null


static func get_clear_chance(turns: int) -> float:
	match turns:
		0: return 0.05
		1: return 0.33
		2: return 0.55
		3: return 0.7
		4: return 0.8
		_: return 0.99


static func get_ailment_text(id: int) -> StringName:
	match id:
		NONE: return "CLEARED"
		BURNED: return "BURNED"
		STUNNED: return "STUNNED"
		FROZEN: return "FROZEN"
		POISONED: return "POISONED"
		CONFUSED: return "CONFUSED"
		EXHAUSTED: return "EXHAUSTED"
		BLINDED: return "BLINDED"
		SHACKLED: return "SHACKLED"
		CORRUPTED: return "CORRUPTED"
		BLESSED: return "BLESSED"
		_: return ""
