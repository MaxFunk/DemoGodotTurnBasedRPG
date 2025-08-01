class_name Attributes

enum {
	SLASH = 0,
	STRIKE = 1,
	PIERCE = 2,
	PURE = 3,
	FIRE = 4,
	ELECTRIC = 5,
	ICE = 6,
	POISON = 7,
	EARTH = 8,
	WIND = 9,
	SOUND = 10,
	PSY = 11,
	LIGHT = 12,
	GRAVITY = 13,
	CORRUPTION = 14,
	CELESTIAL = 15
}


static func get_attribute_icon(id: int) -> CompressedTexture2D:
	match id:
		SLASH: return preload("res://Resources/Images/AttributeIcons/attribute_icon_0_slash.png");
		STRIKE: return preload("res://Resources/Images/AttributeIcons/attribute_icon_1_strike.png");
		PIERCE: return preload("res://Resources/Images/AttributeIcons/attribute_icon_2_pierce.png");
		PURE: return preload("res://Resources/Images/AttributeIcons/attribute_icon_3_pure.png");
		FIRE: return preload("res://Resources/Images/AttributeIcons/attribute_icon_4_fire.png");
		ELECTRIC: return preload("res://Resources/Images/AttributeIcons/attribute_icon_5_electric.png");
		ICE: return preload("res://Resources/Images/AttributeIcons/attribute_icon_6_ice.png");
		POISON: return preload("res://Resources/Images/AttributeIcons/attribute_icon_7_poison.png")
		EARTH: return preload("res://Resources/Images/AttributeIcons/attribute_icon_8_earth.png");
		WIND: return preload("res://Resources/Images/AttributeIcons/attribute_icon_9_wind.png");
		SOUND: return preload("res://Resources/Images/AttributeIcons/attribute_icon_10_sound.png");
		PSY: return preload("res://Resources/Images/AttributeIcons/attribute_icon_11_psy.png");
		LIGHT: return preload("res://Resources/Images/AttributeIcons/attribute_icon_12_light.png");
		GRAVITY: return preload("res://Resources/Images/AttributeIcons/attribute_icon_13_gravity.png");
		CORRUPTION: return preload("res://Resources/Images/AttributeIcons/attribute_icon_14_corruption.png");
		CELESTIAL: return preload("res://Resources/Images/AttributeIcons/attribute_icon_15_celestial.png");
		_: return null
