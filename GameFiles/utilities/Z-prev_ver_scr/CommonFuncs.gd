class_name Global_Scene_Functions
extends Node

var tmp

func _ready():
	tmp = get_SceneHdlr()

func get_SceneHdlr():
	var root_children = get_tree().root.get_children()
	for  m in root_children:
		if "scene_name" in m:
			if m.scene_name == "SceneHandler":
				return m

func get_CurrentScene_ScnMgr():
	#print(get_parent())
	#print(get_tree().root)
	#print(get_tree().root.get_children())
	
	tmp = get_SceneHdlr()
	if tmp:
		return tmp.find_child("SceneMgr_*",true,false)
	else:
		return null
func get_CurrentScene_Player_Camera() -> Node:
	return tmp.find_child("PlayerCamera",true,false)
func get_CurrentScene_GUI_PauseMenu() -> Node:
	return tmp.find_child("PauseMenu_GUI",true,false)
func get_CurrentScene_GUI_InventoryMain() -> Node:
	return tmp.find_child("InventoryUI_Main",true,false)
func get_CurrentScene_GUI_Hotbar() -> Node:
	if tmp:
		return tmp.find_child("Hotbar",true,false)
	else:
		return null
func get_CurrentScene_HUD_Manager() -> Node:
	return tmp.find_child("HUD_Manager",true,false)
	#return
func get_CurrentScene_Shop() -> Node:
	return tmp.find_child("MarketUI",true,false)
func get_CurrentScene_Spawns() -> Node:
	return tmp.find_child("Random_Spawns",true,false)


#func close_storage_ui():
	#player_closing_storage_ui.emit()
func hide_Hotbar() -> void:
	tmp = tmp.find_child("HotbarUI",true,false)
	tmp.visible = false
	print("Hotber hidden")
func show_Hotbar() -> void:
	tmp = tmp.find_child("HotbarUI",true,false)
	tmp.visible = true
	print("Hotber visible")
func get_CurrentScene_CropDirectory() -> Node:
	if tmp:
		return tmp.find_child("Crops",true,false)
	else:
		return null
func get_DayNightCycleUI() -> Node:
	return tmp.find_child("DayNightCycleUI",true,false)


func music_play(mfile,audio_plyr) -> void:
	if Settings.CONFIG_SOUND_MUSIC_ENABLED:
		audio_plyr.stream = load(Settings.get_Music_File_Path(mfile))
		audio_plyr.volume_db = -30 + (40 * (Settings.CONFIG_SOUND_MUSIC) / 100)
		audio_plyr.play()
		if !audio_plyr.playing: audio_plyr.play()
		await audio_plyr.finished

func sfx_play(mfile,audio_plyr) -> void:
	if Settings.CONFIG_SOUND_SFX_ENABLED:
		if audio_plyr.is_playing(): audio_plyr.stop()
		#print("playing " + mfile)
		#print("loading " + Settings.get_SFX_File_Path(mfile))
		audio_plyr.stream = load(Settings.get_SFX_File_Path(mfile))
		audio_plyr.volume_db = -30 + (40 * (Settings.CONFIG_SOUND_SFX) / 100)
		audio_plyr.play()
		#if !audio_plyr.playing: 
			#audio_plyr.play()
		await audio_plyr.finished
		#print(mfile + " finished")



# UTILITY FUNCTIONS

func write_log(isEnabled: bool, strTEXT: String, strTYPE: String)->void:
	if isEnabled:
		match strTYPE:
			"info":
				print(strTEXT)
			"warn":
				push_warning(strTEXT)
			"err":
				push_error(strTEXT)

func get_key_from_value(dict: Dictionary, value: Variant)->Variant:
	for key in dict.keys():
		if dict[key] == value:
			return key
	return null
