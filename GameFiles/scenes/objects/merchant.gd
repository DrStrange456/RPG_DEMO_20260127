extends Node2D

var player_within_range: bool = false
var plyr

func _on_market_interactor_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		$interact_icon.visible = true
		player_within_range = true
		plyr = body

func _on_market_interactor_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		$interact_icon.visible = false
		player_within_range = false
		plyr = body
