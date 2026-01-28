class_name DataManager
extends Node

var item_data: Dictionary = AssetDictionary.getData()


func _ready():
	pass

func readJSON(json_file_path: String) -> Array:
	var file = FileAccess.open(json_file_path, FileAccess.READ)
	var content = file.get_as_text()
	var finish = JSON.parse_string(content)
	file.close()
	return finish

func LoadData(file_path):
	var json_data
	var file_data = FileAccess.get_file_as_string(file_path)
	
#	file_data.open(file_path, FileAccess.READ)
	json_data = JSON.parse_string(file_data.get_as_text())
	file_data.close()
	return json_data.result

func getItemCategory(key_id) -> String:
	if !item_data.has(key_id): return ""
	if item_data[key_id]:
		return item_data[key_id]["item_category"]
	else:
		return ""
func getItemName(key_id):
	#Sample key_id: ("hoe", 1)
	if item_data[key_id[0]]:
		return item_data[key_id[0]]["name"]
	else:
		return ""
func getItemType(key_id):
	if item_data[key_id[0]]:
		return item_data[key_id[0]]["item_category"]
	else:
		return ""
func getItemSpeed(key_id):
	if item_data[key_id]:
		return item_data[key_id]["speed"]
	else:
		return ""
func getItemCapacity(key_id):
	if item_data[key_id]:
		return item_data[key_id]["capacity"]
	else:
		return ""
func getItemDamageMin(key_id):
	if item_data[key_id]:
		return item_data[key_id]["damage_min"]
	else:
		return ""
func getItemDamageMax(key_id):
	if item_data[key_id]:
		return item_data[key_id]["damage_max"]
	else:
		return ""

func getItemMaxStackSizeByID(key_id):
	var tmp = getItemName_from_id(key_id)
	if item_data.values().has(tmp):
		return item_data.find_key(tmp)
	else:
		return 0
	#if item_data[key_id]:
		#return item_data[key_id]["max_stack_size"]
	#else:
		#return 0
func getItemMaxStackSize(key_id) -> int:
	if item_data[key_id]:
		return item_data[key_id]["max_stack_size"]
	else:
		return 0
func getItemID_from_name(nm: String)->String:
	for m in item_data:
		if item_data[m].has("name"):
			if str(item_data[m]["name"]) == str(nm):
				return str(item_data[m]["idx"])
	return ""
func getItemName_from_id(key_id: String):
	for m in item_data:
		if item_data[m].has("idx"):
			if str(item_data[m]["idx"]) == str(key_id):
				return item_data[m]["name"]
	return ""
	##Sample key_id: ("hoe", 1)
	#if item_data[key_id[0]]:
		#return item_data[key_id[0]]["idx"]
	#else:
		#return ""
func getItemType_from_name(nm: String)->String:
	for m in item_data:
		if item_data[m].has("name"):
			if str(item_data[m]["name"]) == str(nm):
				return str(item_data[m]["item_category"])
	return ""
func getItemObject_fromID(key_id: String):
	for m in item_data:
		if item_data[m].has("idx"):
			if str(item_data[m]["idx"]) == str(key_id):
				return item_data[m]


# OLD CODE
#
#func getItemSpeed(key_id):
	#if item_data[key_id[0]]:
		#return item_data[key_id[0]]["Speed"]
	#else:
		#return ""
#func getItemCapacity(key_id):
	#if item_data[key_id[0]]:
		#return item_data[key_id[0]]["Capacity"]
	#else:
		#return ""
#func getItemDamageMin(key_id):
	#if item_data[key_id[0]]:
		#return item_data[key_id[0]]["Damage_Min"]
	#else:
		#return ""
#func getItemDamageMax(key_id):
	#if item_data[key_id[0]]:
		#return item_data[key_id[0]]["Damage_Max"]
	#else:
		#return ""




#func getItemData(key_id):
	#if item_data[key_id]:
		#return item_data[key_id]
	#else:
		#return ""
#func getAllowedSlotTypes(key_id):
	#if item_data[key_id].has('AllowedSlotTypes') and item_data[key_id]:
		#return item_data[key_id]["AllowedSlotTypes"]
	#else:
		## Default allowed is only Inventory
		#return { "INVENTORY": 0, "HOTBAR": 1  }
#func getItemMaxCapacity(item_name) -> int:
	#for m in item_data:
		#if item_data[m]["Name"] == item_name:
			#return item_data[m]["Capacity"]
	#return 0
