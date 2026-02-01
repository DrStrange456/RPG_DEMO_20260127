extends Control

var resource_texture_scene = preload("res://scenes/ui/resource_texture.tscn")
const TEXTURES = {
	Enum.Item.STRAWBERRY: preload("res://assets/plants/icons/strawberry.png"),
	Enum.Item.CARROT: preload("res://assets/plants/icons/carrot.png"),
	Enum.Item.BLUEBERRY: preload("res://assets/plants/icons/blueberry.png"),
	Enum.Item.WOOD: preload("res://assets/plants/icons/wood.png"),
	Enum.Item.APPLE: preload("res://assets/plants/icons/apple.png"),
	Enum.Item.FISH: preload("res://assets/plants/icons/goldfish.png"),
	Enum.Item.CORN: preload("res://assets/plants/icons/corn.png"),
	Enum.Item.TOMATO: preload("res://assets/plants/icons/tomato.png"),
	Enum.Item.PUMPKIN: preload("res://assets/plants/icons/pumpkin.png"),
	Enum.Item.WHEAT: preload("res://assets/plants/icons/wheat.png")}
	
func _ready() -> void:
	hide()
	for i: Enum.Item in Data.items.keys():
		var resource_texture = resource_texture_scene.instantiate()
		resource_texture.setup(i, TEXTURES[i])
		$HBoxContainer.add_child(resource_texture)


func reveal(auto_hide: bool = true):
	for i in $HBoxContainer.get_children():
		i.update()
	show()
	if auto_hide:
		$HideTimer.start()
