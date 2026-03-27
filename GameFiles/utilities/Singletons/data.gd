extends Node

const TILE_SIZE = 16
#const PLANT_DATA = {
	#Enum.Seed.TOMATO: {
		#'texture': "res://assets/plants/tomato.png",
		#'icon_texture': "res://assets/plants/icons/tomato.png",
		#'name':'Tomato',
		#'h_frames': 3,
		#'grow_speed': 0.6,
		#'death_max': 3,
		#'reward': Enum.Item.TOMATO},
	#Enum.Seed.CORN: {
		#'texture': "res://assets/plants/corn.png",
		#'icon_texture': "res://assets/plants/icons/corn.png",
		#'name':'Corn',
		#'h_frames': 3,
		#'grow_speed': 1.0,
		#'death_max': 2,
		#'reward': Enum.Item.CORN},
	#Enum.Seed.PUMPKIN: {
		#'texture': "res://assets/plants/pumpkin.png",
		#'icon_texture': "res://assets/plants/icons/pumpkin.png",
		#'name':'Pumpkin',
		#'h_frames': 3,
		#'grow_speed': 0.3,
		#'death_max': 3,
		#'reward': Enum.Item.PUMPKIN},
	#Enum.Seed.WHEAT: {
		#'texture': "res://assets/plants/wheat.png",
		#'icon_texture': "res://assets/plants/icons/wheat.png",
		#'name':'Wheat',
		#'h_frames': 3,
		#'grow_speed': 1.0,
		#'death_max': 3,
		#'reward': Enum.Item.WHEAT}}
const PLANT_DATA = {
	Enum.Seed.STRAWBERRY: {
		'texture': "res://assets/plants/strawberry.png",
		'icon_texture': "res://assets/plants/icons/strawberry.png",
		'name':'Strawberry',
		'h_frames': 6,
		'grow_speed': 0.6,
		'death_max': 4,
		'reward': Enum.Item.STRAWBERRY},
	Enum.Seed.CARROT: {
		'texture': "res://assets/plants/carrot.png",
		'icon_texture': "res://assets/plants/icons/carrot.png",
		'name':'Carrotss',
		'h_frames': 6,
		'grow_speed': 1.0,
		'death_max': 4,
		'reward': Enum.Item.CARROT},
	Enum.Seed.BLUEBERRY: {
		'texture': "res://assets/plants/blueberry.png",
		'icon_texture': "res://assets/plants/icons/blueberry.png",
		'name':'Blueberry',
		'h_frames': 6,
		'grow_speed': 0.3,
		'death_max': 4,
		'reward': Enum.Item.BLUEBERRY}}

var PLAYER_SKINS = {
	Enum.Style.F_BODY: "res://assets/characters/main_player/body/female.png",
	Enum.Style.M_BODY: "res://assets/characters/main_player/body/male.png",
	Enum.Style.F_HAIR: "res://assets/characters/main_player/hair/female/",
	Enum.Style.M_HAIR: "res://assets/characters/main_player/hair/male/",
	Enum.Style.F_PANTS: "res://assets/characters/main_player/pants/female/",
	Enum.Style.M_PANTS: "res://assets/characters/main_player/pants/male/",
	Enum.Style.F_SHIRT: "res://assets/characters/main_player/shirt/female/",
	Enum.Style.M_SHIRT: "res://assets/characters/main_player/shirt/male/",
	Enum.Style.F_SHOES: "res://assets/characters/main_player/shoes/female/",
	Enum.Style.M_SHOES: "res://assets/characters/main_player/shoes/male/"}
var items = {
	Enum.Item.STRAWBERRY: 5,
	Enum.Item.CARROT: 5,
	Enum.Item.BLUEBERRY: 5,
	Enum.Item.WOOD: 9,
	Enum.Item.APPLE: 8,
	Enum.Item.FISH: 6,
	Enum.Item.CORN: 9,
	Enum.Item.WHEAT: 5,
	Enum.Item.PUMPKIN: 7,
	Enum.Item.TOMATO: 4}
var TOOL_STATE_ANIMATIONS = {
	Enum.Tool.SWING: 'swing',
	Enum.Tool.AXE: 'axe',
	Enum.Tool.HOE: 'hoe',
	}

var AUDIO_TYPE = {
	'music_ambient': "res://audio/music/SoothingPiano.mp3",
	'sfx_slot_pick': "res://audio/sfx/slot_pick.ogg",
	'sfx_slot_drop': "res://audio/sfx/slot_drop.ogg",
	'sfx_slot_swap': "res://audio/sfx/slot_item_swap.wav",
	'sfx_slot_combine': "res://audio/sfx/seed.ogg",
	'sfx_slot_right_click': "res://audio/sfx/slot_right_click.ogg",
	}


var unlocked_machines: Array = [Enum.Machine.DELETE, Enum.Machine.SPRINKLER, Enum.Machine.FISHER, Enum.Machine.SCARECROW]

var forecast_rain: bool

func change_item(item: Enum.Item, amount: int = 1, auto_hide: bool = true):
	items[item] += amount
	get_tree().get_first_node_in_group("ResourceUI").reveal(auto_hide)

func get_audio_source_by_name(nm: String)->String:
	for itm in AUDIO_TYPE.keys():
		if itm == nm:
			return AUDIO_TYPE[nm]
	return ""
