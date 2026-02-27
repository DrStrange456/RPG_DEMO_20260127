class_name ObjectItem
extends Node2D

var GM = load("res://Utilities/Singletons/JSONDATA.gd").new()

@export_category("Main")
@export var item: Resource
@export var item_quantity: int

@export var item_name: String    
@export var item_type: String
@export var water_max: int = 10
@export var water_current: int  = 0
@export var hb_slot: int = -1

@onready var texture_rect = $CenterContainer/TextureRect
@onready var label = $Label

@onready var notify_hb_assignment = $Notify_HB_Assignment
@onready var label_hb_assign = $Notify_HB_Assignment/Label



func _physics_process(_delta):
	$ProgressBar.visible = (water_current > 0)
	_update_water_lvl()

# ProgressBar Functions
func _update_water_lvl()-> void:
	$ProgressBar.max_value = water_max
	if water_current:
		$ProgressBar.value = water_current
	else:
		$ProgressBar.value = 0
func _set_water_max(val)->void:
	water_max = val
func _set_water_current(val)->void:
	water_current = val

# Getter Functions
func getItemName():
	return item_name
func getItemQuantity():
	return item_quantity
func getItemType():
	return item_type
func get_hb_lbl_value()->String:
	return str(label_hb_assign.text)

# Setter Functions
func set_hb_lbl(val)->void:
	label_hb_assign.text = val
	notify_hb_assignment.visible = false if int(label_hb_assign.text) < 0 else true  
func set_item(nm, qt):
	texture_rect = $CenterContainer/TextureRect
	label = $Label
	
	if nm:
		if texture_rect:
			texture_rect.texture = get_ResourceIconImage(nm)
		else:
			print("debug")
		item_quantity = int(qt)
		if label:
			label.text = str(item_quantity)
		
		item_name = str(nm)
		item_type = GM.getItemCategory(item_name)
		$Label.visible = false if item_quantity == 1 else true  
		if label_hb_assign:
			notify_hb_assignment.visible = false if int(label_hb_assign.text) == 0 else true  
func set_texture(tx: Texture)->void:
	$CenterContainer/TextureRect.texture = tx

# Generic Functions
func increment_ItemByAmount(amount_to_add):
	item_quantity += amount_to_add
	$Label.text = str(item_quantity)
func decrease_item_quantity(amount_to_subtract):
	item_quantity -= amount_to_subtract
	$Label.visible = false if item_quantity == 1 else true  
	$Label.text = str(item_quantity)
func refresh_hb_lbl()->void:
	label_hb_assign.text = str(int(hb_slot)+1)
	notify_hb_assignment.visible = false if hb_slot < 0 else true  

func get_ResourceIconImage(itmName: String)->Texture:
	var item_res: inventory_object
	#init resource and qty
	# Sometimes called by name, others by resource id.  Bandaid to cover both cases.
	if ResourceLoader.exists("res://Resources/" + itmName + ".tres"):
		#using resID
		item_res = load("res://Resources/" + itmName + ".tres")
	else:
		#using name
		var nm_to_id = Jsondata.getItemID_from_name(str(itmName))
		item_res = load("res://Resources/" + nm_to_id + ".tres")
	return item_res.itmTexture
