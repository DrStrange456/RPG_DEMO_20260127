extends Node

#GLOBAL CONFIGURATION SETTINGS
#VIDEO
var CONFIG_VIDEO_VSYNC: bool = true
var CONFIG_VIDEO_WINDOWMODE = 1
var CONFIG_VIDEO_RESOLUTION = 2

#SOUND
var CONFIG_SOUND_SFX_ENABLED: bool = true
var CONFIG_SOUND_MUSIC_ENABLED: bool = false
var CONFIG_SOUND_SFX = 75
var CONFIG_SOUND_MUSIC = 75

var MUSIC_NAME_TO_FILE: Dictionary  = {
	0: ["Music_Melodic_BG", "res://Audio/Music/ObservingTheStar.ogg"],
	1: ["Sound_Ambient", "res://Audio/Music/wind1.wav"],
}

var SFX_NAME_TO_FILE: Dictionary  = {
	"button_click": "res://Audio/SFX/impactMetal_000.ogg",
	"inventory_ordered": "res://Audio/SFX/ActionFailed.wav",
	"player_chop": "res://Audio/SFX/choppingtree_small.ogg",
	"tree_falling": "res://Audio/SFX/tree_falling_short.ogg",
	"rock_crushed": "res://Audio/SFX/tree_falling_short.ogg",
	"door_opened": "res://Audio/SFX/qubodup-DoorOpen01.mp3",
	"door_closed": "res://Audio/SFX/qubodup-DoorClose01.ogg",
	"pick_clink_1": "res://Audio/SFX/pick_clink1.mp3",
	"sell_item": "res://Audio/SFX/sell_buy_item.wav",
	"action_failed": "res://Audio/SFX/ActionFailed.wav",
	"open_player_inventory": "res://Audio/SFX/snd_use_map.wav",
	"close_player_inventory": "res://Audio/SFX/snd_close_map.wav",
	}


func _ready():
	load_settings_from_config_file()

func load_settings_from_config_file() -> void:
	var config = ConfigFile.new()

	# Load data from a file.
	var err = config.load("user://settings.cfg")

	# If the file didn't load, ignore it.
	if err != OK:
		return

	# Iterate over all sections.
	for Sound in config.get_sections():
		# Fetch the data for each section.
		CONFIG_SOUND_SFX = config.get_value("Sound","FX_Volume", 50)
		CONFIG_SOUND_MUSIC = config.get_value("Sound","Music_Volume", 50)
	for Video in config.get_sections():
		# Fetch the data for each section.
		CONFIG_VIDEO_VSYNC = config.get_value("Video","VSync", 0)
		CONFIG_VIDEO_RESOLUTION = config.get_value("Video","Resolution", 1)
		CONFIG_VIDEO_WINDOWMODE = config.get_value("Video","Window_Mode", 1)
	print("Sound Loaded Globally")

func is_SFX_Enabled() -> bool:
	return CONFIG_SOUND_SFX_ENABLED

func is_Music_Enabled() -> bool:
	return CONFIG_SOUND_MUSIC_ENABLED



func get_Music_File_Path(fName):
	var fname_indeces: Array = MUSIC_NAME_TO_FILE.keys()
	fname_indeces.sort()
	for nm in fname_indeces:
		if MUSIC_NAME_TO_FILE[nm][0] == fName:
			return MUSIC_NAME_TO_FILE[nm][1]
	push_warning("Unable to find matching Music File Name in Dictionary")

#func get_SFX_File_Path(fName):
	#var fname_indeces: Array = SFX_NAME_TO_FILE.keys()
	#fname_indeces.sort()
	#for nm in fname_indeces:
		#if SFX_NAME_TO_FILE[nm][0] == fName:
			#return SFX_NAME_TO_FILE[nm][1]
	#push_warning("Unable to find matching SFX File Name in Dictionary")

func get_SFX_File_Path(fName):
	if SFX_NAME_TO_FILE.has(fName):
		return SFX_NAME_TO_FILE[fName]
	else:
		push_warning("Unable to find matching SFX File Name in Dictionary")
		return ""
