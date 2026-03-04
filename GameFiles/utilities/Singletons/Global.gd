extends Node

var PLAYER_INV_SLOTS_ENABLED: int = 18
var NUMBER_ACTIVE_INVENTORY_SLOTS: int = PLAYER_INV_SLOTS_ENABLED


# item must Be define as a resource
# AND in function get_item_from_name in api_inventory
var PLAYER_INVENTORY: Dictionary = {
		0: ["carrot", 10, true],
		1: ["carrot", 1, true],
		2: ["carrot", 1, true],
		3: ["StrawberrySeeds", 10, true],
		4: ["carrot", 65, true],
		5: ["StrawberrySeeds", 10, true],
		6: ["carrot", 1, true],
		7: ["carrot", 1, true],
		8: ["StrawberrySeeds", 90, true],
		9: ["carrot", 1, true],
		10: ["StrawberrySeeds", 10, true],
		11: ["CarrotSeeds", 95, true],
		12: ["StrawberrySeeds", 10, true],
		13: ["TomatoSeeds", 50, true],
		14: ["TurnipSeeds", 10, true],
		15: ["TurnipSeeds", 10, true],
		16: ["carrot", 30, true],
		17: ["carrot", 65, true],
		18: ["", 0, true],
		19: ["", 0, true],
		20: ["", 0, true],
		21: ["", 0, true],
		22: ["", 0, true],
		23: ["", 0, true],
		24: ["", 0, false],
		25: ["", 0, false],
		26: ["", 0, false],
		27: ["", 0, false],
		28: ["", 0, false],
		29: ["", 0, false],
		30: ["", 0, false],
		31: ["", 0, false],
		32: ["", 0, false],
		33: ["", 0, false],
		34: ["", 0, false],
		35: ["", 0, false],
}

var PLAYER_INVENTORY_TEST: Dictionary = {
		0: ["res://Inventory/ItemResources/crop_carrot.tres", 10, true],
		1: ["res://Inventory/ItemResources/crop_tomato.tres", 5, true],
		2: ["res://Inventory/ItemResources/crop_carrot.tres", 25, true],
		3: ["res://Inventory/ItemResources/seeds_strawberry.tres", 10, true],
		4: ["res://Inventory/ItemResources/crop_carrot.tres", 65, true],
		5: ["res://Inventory/ItemResources/seeds_strawberry.tres", 10, true],
		6: ["res://Inventory/ItemResources/crop_carrot.tres", 1, true],
		7: ["res://Inventory/ItemResources/crop_carrot.tres", 1, true],
		8: ["res://Inventory/ItemResources/seeds_strawberry.tres", 90, true],
		9: ["res://Inventory/ItemResources/crop_carrot.tres", 1, true],
}
