extends Node2D

var startup_PlayAmbient: bool = true

@onready var player = $Objects/MainPlayer
@onready var day_transition_material = $Overlay/CanvasLayer/DayTransitionLayer.material
@export var daytime_color: Gradient
@export var rain_color: Color

var machine_scenes = {
	Enum.Machine.SPRINKLER: preload("res://scenes/machines/sprinkler.tscn"),
	Enum.Machine.SCARECROW: preload("res://scenes/machines/scare_crow.tscn"),
	Enum.Machine.FISHER: preload("res://scenes/machines/fisher.tscn")}
const MACHINE_PREVIEW_TEXTURES = {
	Enum.Machine.SPRINKLER: {'texture':preload("res://assets/plants/icons/sprinkler.png"), 'offset': Vector2i(0,0)},
	Enum.Machine.FISHER: {'texture':preload("res://assets/plants/icons/fisher.png"), 'offset': Vector2i(0,-4)},
	Enum.Machine.SCARECROW: {'texture':preload("res://assets/plants/icons/scarecrow.png"), 'offset': Vector2i(0,-4)},
	Enum.Machine.DELETE: {'texture':preload("res://assets/plants/icons/delete.png"), 'offset': Vector2i(0,0)}}


var used_cells: Array[Vector2i]

var plant_scene = preload("res://scenes/objects/plant.tscn")
var blob_scene = preload("res://scenes/objects/blob.tscn")
var projectile_scene = preload("res://scenes/objects/projectile.tscn")



func _ready() -> void:
	if startup_PlayAmbient: 
		_play_ambient_music()


func _process(_delta: float) -> void:
	var daytime_point = 1 - ($Timers/DayTimer.time_left / $Timers/DayTimer.wait_time)
	var color = daytime_color.sample(daytime_point).lerp(rain_color, 0.5 if raining else 0.0)
	$Overlay/DayTimeColor.color = color
	
	# machine preview 
	$Overlay/MachinePreviewSprite.visible = player.state == Enum.State.BUILDING
	$Overlay/MachinePreviewSprite.position = player.get_machine_coord() + MACHINE_PREVIEW_TEXTURES[player.current_machine]['offset']



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
					Enum.Seed.STRAWBERRY: Enum.Item.STRAWBERRY,
					Enum.Seed.CARROT: Enum.Item.CARROT,
					Enum.Seed.BLUEBERRY: Enum.Item.BLUEBERRY,
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


func _on_main_player_day_change() -> void:
	day_restart()


func _on_main_player_build(current_machine: int) -> void:
	if current_machine != Enum.Machine.DELETE:
		var machine = machine_scenes[current_machine].instantiate()
		machine.setup(player.get_machine_coord(), self, $Objects)
	else:
		for machine in get_tree().get_nodes_in_group('Machines'):
			machine.delete(player.get_machine_coord() / 16)


func _on_main_player_machine_change(current_machine: int) -> void:
	$Overlay/MachinePreviewSprite.texture = MACHINE_PREVIEW_TEXTURES[current_machine]['texture']



func plant_death(coord: Vector2i):
	used_cells.erase(coord)

func _play_ambient_music():
	$Sound/Ambient/calm_relaxing.play()

var raining: bool:
	set(value):
		raining = value
		#$Layers/RainFloorParticles.emitting = value
		$Overlay/RainDropsParticles.emitting = value
		#$Music/Rain.playing = value


func _on_blob_timer_timeout() -> void:
	var count_blobs = get_tree().get_nodes_in_group('Blobs')
	if count_blobs.size() > 10: return
	
	var plants = get_tree().get_nodes_in_group('Plants')
	if plants:
		var blob = blob_scene.instantiate()
		if $BlobSpawnPositions.get_children().size() > 0:
			var pos = $BlobSpawnPositions.get_children().pick_random().position
			blob.setup(pos, plants.pick_random(), $Objects)

func _on_player_day_change() -> void:
	day_restart()

func day_restart():
	var tween = create_tween()
	tween.tween_property(day_transition_material, "shader_parameter/progress", 1.0, 1.0)
	tween.tween_interval(0.5)
	tween.tween_callback(level_reset)
	tween.tween_property(day_transition_material, "shader_parameter/progress", 0.0, 1.0)

func level_reset():
	for plant in get_tree().get_nodes_in_group('Plants'):
		plant.grow(plant.coord in $Layers/SoilWaterLayer.get_used_cells())
	$Layers/SoilWaterLayer.clear()
	#$Overlay/CanvasLayer/PlantInfoContainer.update_all()
	
	$Timers/DayTimer.start()
	for object in get_tree().get_nodes_in_group('Objects'):
		if 'reset' in object:
			object.reset()

	raining = Data.forecast_rain
	Data.forecast_rain = [true, false].pick_random()
	
	if raining:
		for cell in $Layers/SoilLayer.get_used_cells():
			$Layers/SoilWaterLayer.set_cell(cell, 0, Vector2i(randi_range(0,2),0))

func water_plants(coord: Vector2i):
	player.txt_debug_1.text = str(coord)
	const SOIL_DIRECTIONS = [
		Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
		Vector2i(-1,  0),Vector2i(1,0), Vector2i(-1,  1), 
		Vector2i(0,  1), Vector2i(1,  1)]
	for dir in SOIL_DIRECTIONS:
		var offset = Vector2i(1,1)
		if coord.x > 0: offset += Vector2i(-1,0)
		if coord.y > 0: offset += Vector2i(0,-1)
		var cell = coord + dir - offset
		if cell in $Layers/SoilLayer.get_used_cells():
			$Layers/SoilWaterLayer.set_cell(cell, 0, Vector2i(randi_range(0,2),0))

func create_projectile(start_pos: Vector2, dir: Vector2):
	var projectile = projectile_scene.instantiate()
	projectile.setup(start_pos, dir)
	$Objects.add_child(projectile)
