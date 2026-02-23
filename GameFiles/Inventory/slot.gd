class_name custom_slot
extends Panel

enum SlotType {
	INVENTORY,
	STORAGE,
	HOTBAR
}

@export var default_texture : Texture
@export var empty_texture : Texture
@export var selected_tex : Texture
@export var disabled_tex : Texture
@export_enum("INVENTORY","STORAGE","HOTBAR") var slotType

var default_style: StyleBoxTexture = null
var empty_style: StyleBoxTexture = null
var selected_style: StyleBoxTexture = null
var disabled_style: StyleBoxTexture = null
#var slotType = null
var item = null
var slot_index





func _ready() -> void:
	default_style = StyleBoxTexture.new()
	empty_style = StyleBoxTexture.new()
	selected_style = StyleBoxTexture.new()
	disabled_style = StyleBoxTexture.new()
	default_style.texture = default_texture
	empty_style.texture = empty_texture
	selected_style.texture = selected_tex
	disabled_style.texture = disabled_tex



func refresh_style() -> void:
	if slot_index == null: 
		return
	if slot_index >= 0:
		var enabled_status = Inventory.slots[slot_index].enabled
		var itm_tmp = Inventory.slots[slot_index]
		var test_is_blank: bool = false
		
		if !enabled_status:   #The slot was disabled
			set("theme_override_styles/panel", disabled_style) 
			return
		
		match slotType:
			0:  #Inventory
				if itm_tmp.item == null:
					test_is_blank = true
				else:
					if itm_tmp.item.resource_path == "res://Scenes/StandaloneInventory/Inventory//ItemResources/blank_item.tres":
						test_is_blank = true
				if enabled_status  and !test_is_blank:
					set("theme_override_styles/panel", default_style)
				elif test_is_blank:   #There is no item in the slot
					set('theme_override_styles/panel', empty_style)
				else:
					set("theme_override_styles/panel", default_style)
			1:  #Storage
				if self.get_child_count() == 0:
					set('theme_override_styles/panel', empty_style)
				else:
					set("theme_override_styles/panel", default_style)
			2: #Other
				pass

func refresh_style_NotInitialized() -> void:
	# Refresh regardless if inventory is initialized or not
	
	if slot_index == null: 
		return
	if slot_index >= 0:
		#var itm_tmp = Inventory.slots[slot_index]
		var test_is_blank: bool = false
		
		if item == null:
			test_is_blank = true
		else:
			if item.resource_path == "res://Scenes/StandaloneInventory/Inventory//ItemResources/blank_item.tres":
				test_is_blank = true
		if !test_is_blank:
			set("theme_override_styles/panel", default_style)
		elif test_is_blank:   #There is no item in the slot
			set('theme_override_styles/panel', empty_style)
		else:
			set("theme_override_styles/panel", default_style)


func _get_resource_path(_itm):
	return item.resource_path

func _set_resource_path(_respath):
	if item == null:
		set("theme_override_styles/panel", empty_style)
