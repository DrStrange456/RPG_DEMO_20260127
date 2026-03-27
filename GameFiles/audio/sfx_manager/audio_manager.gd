class_name Audio_Controller
extends Node

@onready var sfx_player: AudioStreamPlayer2D = $SFX/sfx_player
@onready var music_player: AudioStreamPlayer2D = $MUSIC/music_player


func play_music(val):
	var ac_path = Data.get_audio_source_by_name(val)
	music_player.stream = load(ac_path)
	music_player.play()

func play_sound(val):
	var ac_path = Data.get_audio_source_by_name(val)
	sfx_player.stream = load(ac_path)
	sfx_player.play()
