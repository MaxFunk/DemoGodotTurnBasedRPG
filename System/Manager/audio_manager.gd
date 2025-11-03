extends Node

const default_volume_db: float = -8.0;
const mute_volume_db: float = -60.0;

var ramp_up_audio_area: bool = false;

var audio_area: AudioStreamPlayer;
var audio_battle: AudioStreamPlayer;
var audio_menu: AudioStreamPlayer;


func _ready() -> void:
	audio_area = AudioStreamPlayer.new();
	audio_battle = AudioStreamPlayer.new();
	audio_menu = AudioStreamPlayer.new();
	
	audio_area.name = "AudioStreamPlayerArea";
	audio_battle.name = "AudioStreamPlayerBattle";
	audio_menu.name = "AudioStreamPlayerMenu";
	
	audio_area.bus = "AreaMusic";
	audio_battle.bus = "BattleMusic";
	audio_menu.bus = "BattleMenu";
	
	audio_area.volume_db = default_volume_db;
	audio_battle.volume_db = default_volume_db;
	
	add_child(audio_area);
	add_child(audio_battle);
	add_child(audio_menu);
	return


func _process(delta: float) -> void:
	if ramp_up_audio_area:
		audio_area.volume_db += delta * 120.0;
		if audio_area.volume_db >= default_volume_db:
			audio_area.volume_db = default_volume_db;
			ramp_up_audio_area = false;
	return


func play_area_music(file_id: int) -> void:
	audio_area.stream = get_music_file(file_id);
	if audio_area.stream:
		audio_area.play();
		audio_area.volume_db = default_volume_db;
	return


func weaken_area_music() -> void:
	if audio_area.playing:
		audio_area.volume_db = mute_volume_db / 3.0;
	return


func resume_area_music() -> void:
	audio_battle.stop();
	audio_area.stream_paused = false;
	ramp_up_audio_area = true;
	return


func play_battle_music(file_id: int) -> void:
	if audio_area.playing:
		audio_area.stream_paused = true;
		audio_area.volume_db = mute_volume_db;
	
	audio_battle.stream = get_music_file(file_id);
	if audio_battle.stream:
		audio_battle.play();
	return


func get_music_file(file_id: int) -> AudioStream:
	match file_id:
		0: return preload("res://Resources/Audio/titlescreen.mp3")
		1: return preload("res://Resources/Audio/debugworld.mp3")
		2: return preload("res://Resources/Audio/temp_battle.mp3")
		10: return preload("res://Resources/Audio/Battle/smtvv_battle_vengence.ogg")
		11: return preload("res://Resources/Audio/Battle/smtvv_battle_gliding.ogg")
		12: return preload("res://Resources/Audio/Battle/smtvv_battle_bounce_and_roll.ogg")
		_: return null
