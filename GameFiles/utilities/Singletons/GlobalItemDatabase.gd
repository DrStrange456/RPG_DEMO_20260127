class_name GlobalItemDatabase
extends Node

# Loads all resource files into dictionary for easy access

var items_by_name: Dictionary = {}

func _ready():
	load_items_from_folder("res://Scenes/StandaloneInventory/Inventory/ItemResources/")

func load_items_from_folder(folder_path: String):
	var dir = DirAccess.open(folder_path)
	if dir == null:
		push_error("Could not open item directory: " + folder_path)
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if file_name.ends_with(".tres"):
			var item_path = folder_path + "/" + file_name
			var item = load(item_path) as Item
			if item:
				items_by_name[item.name] = item
		file_name = dir.get_next()

	dir.list_dir_end()
	#print("Loaded %d Global Resource Items from %s" % items_by_name.size())
	var tmp = items_by_name.size()
	print("Loaded %d Global Resource Items. Path: %s" % [tmp, folder_path])

func get_item_by_name(nm: String) -> Item:
	return items_by_name.get(nm, null)
