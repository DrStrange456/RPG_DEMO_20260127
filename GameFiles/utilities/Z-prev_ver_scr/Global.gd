extends Node

var scene_handler: SceneHandler

var current_scene = "Small_Nook"
var current_scene_mgr = "SceneMgr_Small_Nook"
#var current_scene = "Beach_Starter"
#var current_scene_mgr = "SceneMgr_Beach_Starter"
var previous_scene = ""

const dir_ArtAssets = "res://ArtAssets"
const dir_Slot_Thumbnails = "res://ArtAssets/Thumbnails/"

const FACING_RIGHT = "RIGHT"
const FACING_LEFT = "LEFT"
const FACING_UP = "UP"
const FACING_DOWN = "DOWN"

const gl_SLOT_CLASS = preload("res://UI/slot_v3.gd")
const gl_ITEM_CLASS = preload("res://GameData/PlayerInventory/item.gd")

# TIME/DATE TRACKING
var gl_TIME: String
var gl_DATE: String

#PLAYER
var PLAYER_MONEY: int = 500
var PLAYER_HEALTH: int = 100
var PLAYER_INV_SLOTS_ENABLED: int = 18
var PLAYER_HB_SLOTS_ENABLED: int = 8
var NUMBER_ACTIVE_INVENTORY_SLOTS: int = PLAYER_INV_SLOTS_ENABLED
var NUMBER_ACTIVE_HOTBAR_SLOTS: int = PLAYER_HB_SLOTS_ENABLED

#HOTBAR
var SELECTED_HB_ITEM_NAME: String = ""
var SELECTED_HB_ITEM_TYPE: String = ""
var hold_preview_active: bool = false

var PLAYER_INVENTORY: Dictionary = {
	#--> slot_index: [item_name, item_quantity]
	
		0: ["3001_SmallTable_Wood", 1],
		1: ["1001_steel_sword", 1],
		#1: ["2007_carrot", 10],
		4: ["2201_seeds_tomato", 30],
		5: ["2202_seeds_turnip", 10],
		6: ["1003_steel_pick", 1],
		7: ["2204_seeds_blueberry", 97],
		8: ["2205_seeds_carrot", 30],
		9: ["1004_steel_hoe", 1],
		10: ["2203_seeds_strawberry", 10],
		#10: ["water_bucket_empty", 1],
		11: ["2007_carrot", 10],
		#12: ["2008_tomato", 10],
		#13: ["2009_turnip", 10],
		#14: ["2010_strawberry", 10],
		#15: ["2011_blueberry", 10],
}

var PLAYER_HOTBAR_NEW: Dictionary = {
	# --> slot_index = {Player Inventory Slot_index}
	0: 1,
	1: 0,
	#2: 4,
	3: 6,
	#4: 8,
	#0: 9,
	#3: 8,
	#4: 4,
	#5: 5,
	#6: 6,
	#7: 7,
}

var PLAYER_INV_FILL_MAPPING: Dictionary = {
	0: 0,
	1: 0,
	2: 0,
	3: 0,
	4: 0,
	5: 0,
	6: 0,
	7: 0,
	8: 0,
	9: 0,
	10: 0,
	11: 0,
	12: 0,
	13: 0,
	14: 0,
	15: 0,
}



var DEV_STORAGE_ITEMS: Dictionary  = {
	0: ["1001_steel_sword", 1],
	1: ["1003_steel_pick", 1],
	2: ["1004_steel_hoe", 1],
	#3: ["water_bucket_empty", 1],
	4: ["2203_seeds_strawberry", 99],
	5: ["2204_seeds_blueberry", 99],
	6: ["2205_seeds_carrot", 99],
	7: ["2202_seeds_turnip", 99],
	8: ["2201_seeds_tomato", 99],
}


func gatherCropData_byName(cropName):
	#TODO: Have this info come from a JSON file based on cropName
	var value = ""
	value = {"prkey": 1,
				 "object_name": cropName, 
				 "phase_days": [0,1,2,2,2,INF],
				 "current_phase": 0,
				 "day_of_current_phase": 0,
				 "crop_age": 0}
	return value

func convDir_to_Vector(dir):
	match dir:
		FACING_RIGHT: return Vector2(1,0)
		FACING_LEFT: return Vector2(-1,0)
		FACING_UP: return Vector2(0,-1)
		FACING_DOWN: return Vector2(0,1)

func convDir_from_Vector(dir):
	match dir:
		Vector2(1,0): return FACING_RIGHT
		Vector2(-1,0): return FACING_LEFT
		Vector2(0,-1): return FACING_UP
		Vector2(0,1): return FACING_DOWN

func get_Handler(nd) -> Node:
	#var tmp = get_parent().find_child("SceneHandler")
	var tmp = scene_handler
	if tmp:
		return tmp.find_child(nd)
	else:
		return tmp
