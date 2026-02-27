extends Node2D

#@onready var interact_icon = $art_assets/Interact_Icon

var player_within_range: bool = false
var plyr


func market_opening():
	print("Store opening")
	var load_store = load("res://Scenes/Levels/general_store/general_store.tscn").instantiate()
	add_child(load_store)

func market_closing():
	print("Store closing")


func _on_market_interactor_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		$interact_icon.visible = true
		player_within_range = true
		plyr = body



func _on_market_interactor_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		$interact_icon.visible = false
		player_within_range = false
		plyr = body
