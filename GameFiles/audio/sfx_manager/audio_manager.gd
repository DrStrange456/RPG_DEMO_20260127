class_name Audio_Controller
extends Node

@onready var sfx_player: AudioStreamPlayer2D = $SFX/sfx_player


func play_sound(val):
	var ac_path = Data.get_sfx_source_by_name(val)
	sfx_player.stream = load(ac_path)
	sfx_player.play()
