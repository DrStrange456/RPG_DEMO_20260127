extends Panel

@onready var nm: String
@onready var qty: int
@onready var typ: String

const ItemClass = preload("res://GameData/NewInventory/item.gd")

func _physics_process(_delta):
	$TextureRect.texture = load("res://ArtAssets/Items/" + typ + ".png")
