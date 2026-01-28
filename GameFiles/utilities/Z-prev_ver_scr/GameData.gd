extends Node

var item_data: Array = readJSON("res://Utilities/Config/item_data.json")

func readJSON(json_file_path: String) -> Array:
	var file = FileAccess.open(json_file_path, FileAccess.READ)
	var content = file.get_as_text()
	var finish = JSON.parse_string(content)
	file.close()
	return finish

func refresh_list():
	item_data = readJSON("res://Utilities/Config/item_data.json")

func getItemValue_String(key_id,colName) -> String:
	refresh_list()
	for itm in item_data:
		if itm["Item Name"] == key_id:
			return str(itm[colName])
	return ""

func getItemValue_Bool(key_id,colName) -> bool:
	refresh_list()
	for itm in item_data:
		if itm["Item Name"] == key_id:
			return bool(itm[colName])
	return false

func getItemValue_int(key_id,colName) -> int:
	refresh_list()
	for itm in item_data:
		if itm["Item Name"] == key_id:
			return int(itm["meta"][colName])
	return 0

func getItemName(itm: Node2D):
	if itm: 
		if itm.itmName:
			return itm.itmName

func getItemType(key_id):
	refresh_list()
	for itm in item_data:
		if itm["Item Name"] == key_id:
			return itm["TemplateType"]
	return ""

func getSpecialItemType(key_id):
	refresh_list()
	for itm in item_data:
		if itm["Item Name"] == key_id:
			return itm["SpecialType"]
	return ""
	
func getItem_isRotatable(key_id):
	refresh_list()
	for itm in item_data:
		if itm["Item Name"] == key_id:
			return itm["Rotatable"]
	return 0

func get_all_keys_fromArray():
	refresh_list()
	var tmpALIST: Array = []
	for itm in item_data:
		tmpALIST.append(itm["Item Name"])
	return tmpALIST

# Generic function to get value from Array using 
#  given values
#func getItemValue_FromArray(arr: Array,item_name: String,key_id: String,colName: String) -> String:
	#for itm in arr:
		#if itm[item_name] == key_id:
			#return itm[colName]
	#return ""


func getItemValue_FromArray(arr: Dictionary,key_id: String,colName: String) -> String:
	for itm in arr:
		if itm == key_id:
			var tmpStr = JSON.parse_string(arr[itm])
			return tmpStr[colName]
	return ""


func getItemValue(key_id) -> int:
	if item_data[key_id]:
		return item_data[key_id]["Value"]
	else:
		return 0
func getItem_Speed(key_id: String):
	refresh_list()
	for itm in item_data:
		if itm["Item Name"] == key_id:
			return itm["meta"]["Speed"]
	return ""
func getItemDamageMin(key_id: String):
	refresh_list()
	for itm in item_data:
		if itm["Item Name"] == key_id:
			return itm["meta"]["Damage_Min"]
	return ""
func getItemDamageMax(key_id: String):
	refresh_list()
	for itm in item_data:
		if itm["Item Name"] == key_id:
			return itm["meta"]["Damage_Max"]
	return ""
	

#OLD CODE BELOW
#
##onready var debug = get_node("/root/InventoryUI/BackgroundTexture2/debugTEXT")
#
#var item_data: Dictionary = AssetDictionary.getData()
#
#func _ready():
	#pass
#
#func LoadData(file_path):
	#var json_data
	#var file_data = FileAccess.get_file_as_string(file_path)
	#
##	file_data.open(file_path, FileAccess.READ)
	#json_data = JSON.parse_string(file_data.get_as_text())
	#file_data.close()
	#return json_data.result
#
#func getItemCategory(key_id) -> String:
	#if item_data[key_id]:
		#return item_data[key_id]["ItemCategory"]
	#else:
		#return ""
#func getItemValue(key_id) -> int:
	#if item_data[key_id]:
		#return item_data[key_id]["Value"]
	#else:
		#return 0
#func getItemMaxStackSize(item_name) -> int:
	#if item_data[item_name]:
		#return item_data[item_name]["max_stack_size"]
	#else:
		#return 0
#func getAllowedSlotTypes(key_id):
	#if item_data[key_id].has('AllowedSlotTypes') and item_data[key_id]:
		#return item_data[key_id]["AllowedSlotTypes"]
	#else:
		## Default allowed is only Inventory
		#return { "INVENTORY": 0, "HOTBAR": 1  }
#
#
#
#
###  NOT USED
#
#func getItemData(key_id):
	#if item_data[key_id]:
		#return item_data[key_id]
	#else:
		#return ""
