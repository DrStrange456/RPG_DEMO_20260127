extends Node2D

var startup_PlayAmbient: bool = true

@onready var player = $Objects/MainPlayer
var used_cells: Array[Vector2i]

var plant_scene = preload("res://scenes/objects/plant.tscn")



func _ready() -> void:
	if startup_PlayAmbient: 
		_play_ambient_music()


func _on_main_player_tool_use(tool: int, pos: Vector2) -> void:
	var grid_coord: Vector2i = Vector2i(int(pos.x / Data.TILE_SIZE),int(pos.y / Data.TILE_SIZE))
	grid_coord.x += -1 if pos.x < 0 else 0
	grid_coord.y += -1 if pos.y < 0 else 0
	var has_soil = grid_coord in $Layers/SoilLayer.get_used_cells()
	
	match tool:
		Enum.Tool.HOE:
			var cell = $Layers/TillableLayer.get_cell_tile_data(grid_coord) as TileData
			if cell and cell.get_custom_data('farmable'):
				$Layers/SoilLayer.set_cells_terrain_connect([grid_coord], 0, 0)
			#if raining:
				#$Layers/SoilWaterLayer.set_cell(grid_coord, 0, Vector2i(randi_range(0,2),0))
		Enum.Tool.WATER:
			if has_soil:
				$Layers/SoilWaterLayer.set_cell(grid_coord, 0, Vector2i(randi_range(0,2), 0))
		Enum.Tool.SEED:
			if has_soil and grid_coord not in used_cells:
				var selected_item = {
					Enum.Seed.TOMATO: Enum.Item.TOMATO,
					Enum.Seed.WHEAT: Enum.Item.WHEAT,
					Enum.Seed.CORN: Enum.Item.CORN,
					Enum.Seed.PUMPKIN: Enum.Item.PUMPKIN,
				}[player.current_seed]
				
				if Data.items[selected_item] > 0:
					var plant_res = PlantResource.new()
					plant_res.setup($Objects/MainPlayer.current_seed, selected_item)
					var plant = plant_scene.instantiate()
					plant.setup(grid_coord, $Objects, plant_res, plant_death)
					used_cells.append(grid_coord)
		Enum.Tool.AXE, Enum.Tool.SWING:
			for object in get_tree().get_nodes_in_group('Objects'):
				if object.position.distance_to(pos) < 30:
					object.hit(tool)
		Enum.Tool.FISH:
			if not grid_coord in $Layers/TillableLayer.get_used_cells():
				$Objects/MainPlayer.start_fishing()



func _on_main_player_build(current_machine: int) -> void:
	pass # Replace with function body.


func _on_main_player_day_change() -> void:
	pass # Replace with function body.


func _on_main_player_machine_change(current_machine: int) -> void:
	pass # Replace with function body.



func plant_death(coord: Vector2i):
	used_cells.erase(coord)

func _play_ambient_music():
	$Sound/Ambient/calm_relaxing.play()
