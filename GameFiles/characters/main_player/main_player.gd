extends CharacterBody2D

signal tool_use(tool: Enum.Tool, pos: Vector2)
signal build(current_machine: Enum.Machine)
signal machine_change(current_machine: Enum.Machine)
signal day_change

@onready var txt_debug_1: Label = $Camera2D2/txtDebug1
@onready var txt_debug_2: Label = $Camera2D2/txtDebug2



@onready var anim_player: AnimationPlayer = $anim_player
@onready var currentFacingDir = Vector2.DOWN
var raining: bool:
	set(value):
		raining = value
		$Layers/RainFloorParticles.emitting = value
		$Overlay/RainDropsParticles.emitting = value
		$Music/Rain.playing = value

var direction: Vector2
var last_direction: Vector2
var speed := 50
var can_move: bool = true
@onready var move_state_machine = $anim_tree.get("parameters/MoveStateMachine/playback")
@onready var tool_state_machine = $anim_tree.get("parameters/ToolStateMachine/playback")
var current_tool: Enum.Tool = Enum.Tool.SEED
var current_machine: Enum.Machine
var current_machine_index: int
var state = Enum.State.DEFAULT
var current_seed: Enum.Seed
@onready var tool_sounds = {
	Enum.Tool.AXE: $Sounds/Axe,
	Enum.Tool.SWING: $Sounds/Swing,
	Enum.Tool.HOE: $Sounds/Hoe,
	Enum.Tool.SEED: $Sounds/Seed,
	Enum.Tool.WATER: $Sounds/Water,
	Enum.Tool.FISH: $Sounds/Fish
}



func _ready() -> void:
	randomize()
	anim_player.active = true


func _physics_process(delta: float) -> void:
	match state:
		Enum.State.DEFAULT:
			if can_move:
				get_basic_input(delta)
				move_action(delta)
				animate()
		Enum.State.FISHING:
			get_fishing_input()
		Enum.State.BUILDING:
			get_building_input()
			move_action(delta)
			animate()
	if direction:
		last_direction = direction
		var ray_y = int(direction.y) if not direction.x else 0
		$RayCast2D.target_position = Vector2(direction.x,ray_y).normalized() * 20
		$weapon_hit_box.rotation = direction.angle() - PI/2


func get_basic_input(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if Global.ACTIVE_MENU == Enum.MenuStates.DEFAULT:
			GameManager.show_inventory()
		else:
			GameManager.hide_inventory()
	
	if Input.is_action_just_pressed("day_change"):
		day_change_emit()
	
	if Input.is_action_just_pressed("tool_forward") or Input.is_action_just_pressed("tool_backward"):
		var dir = Input.get_axis("tool_backward", "tool_forward")
		current_tool = posmod(current_tool + int(dir), Enum.Tool.size()) as Enum.Tool
		$ToolUI.reveal(true)
		get_tree().get_first_node_in_group("ResourceUI").visible = current_tool == Enum.Tool.SEED
	
	if Input.is_action_just_pressed("seed_forward"):
		current_seed = posmod(current_seed + 1, Enum.Seed.size()) as Enum.Seed
		$ToolUI.reveal(false)
	
	if Input.is_action_just_pressed("ui_accept"):
		tool_state_machine.travel("swing")
		set_swing_speed(5)
		init_swing_animation()
	
	if Input.is_action_just_pressed("build"):
		state = Enum.State.BUILDING
		current_machine = Data.unlocked_machines[current_machine_index] as Enum.Machine


func animate():
	if direction:
		move_state_machine.travel("walk")
		var direction_animation = Vector2(round(direction.x),round(direction.y))
		$anim_tree.set("parameters/MoveStateMachine/idle/blend_position", direction_animation)
		$anim_tree.set("parameters/MoveStateMachine/walk/blend_position", direction_animation)
		$anim_tree.set("parameters/FishBlendSpace2D/blend_position", direction_animation)
		for animation in Data.TOOL_STATE_ANIMATIONS.values():
			var animation_name: String = "parameters/ToolStateMachine/"+ animation +"/blend_position"
			$anim_tree.set(animation_name, direction_animation)
	else:
		move_state_machine.travel('idle')


func get_building_input():
	if Input.is_action_just_pressed("build"):
		state = Enum.State.DEFAULT
	
	if Input.is_action_just_pressed("tool_forward") or Input.is_action_just_pressed("tool_backward"):
		var dir = Input.get_axis("tool_backward", "tool_forward")
		current_machine_index = posmod(current_machine_index + int(dir), Data.unlocked_machines.size())
		current_machine = Data.unlocked_machines[current_machine_index] as Enum.Machine
		machine_change.emit(current_machine)

	if Input.is_action_just_pressed("action"):
		build.emit(current_machine)


func get_fishing_input():
	if Input.is_action_just_pressed("action"):
		$FishingGame.action()


func start_fishing():
	$FishingGame.reveal()
	state = Enum.State.FISHING
	$anim_tree.set("parameters/FishBlend/blend_amount", 1)


func stop_fishing():
	can_move = true
	state = Enum.State.DEFAULT
	$anim_tree.set("parameters/FishBlend/blend_amount", 0)



func move_action(_delta):
	direction = Input.get_vector("mapped_move_left", "mapped_move_right", "mapped_move_up", "mapped_move_down")
	velocity = direction * 150  # speed = 50
	move_and_slide()


func tool_use_emit():
	## Add method call to the animation player to call this
	tool_use.emit(current_tool,position + last_direction * 16 + Vector2(0,4))
	#tool_sounds[current_tool].play()


func _weapon_visible(val: bool)-> void:
	if current_tool == Enum.Tool.SWING:
		$weapon_hit_box.visible = val


func _loadAbility(abilName) -> Node:
	var scene = load("res://characters/abilities/" + abilName + ".tscn")
	var sceneNode = scene.instantiate()
	add_child(sceneNode)
	return sceneNode


func _on_anim_tree_animation_started(_anim_name: StringName) -> void:
	#can_move = false
	pass


func _on_anim_tree_animation_finished(_anim_name: StringName) -> void:
	can_move = true
	_weapon_visible(false)


func day_change_emit():
	day_change.emit()


func get_machine_coord() -> Vector2i:
#	This function is not working when crossing y axis
	var pos = position + last_direction * 20 + Vector2(0,8)
	var coord = Vector2i(pos.x / Data.TILE_SIZE, pos.y / Data.TILE_SIZE)
	coord.x += -1 if pos.x < 0 else 0
	coord.y += -1 if pos.y < 0 else 0
	return coord * Data.TILE_SIZE + Vector2i(8,8)



# SWING animation functions
func set_swing_speed(multiplier: float) -> void:
	$anim_tree.set("parameters/ToolTimeScale/scale", multiplier)

func init_swing_animation() -> void:
	can_move = false
	_weapon_visible(true)
	$anim_tree.set("parameters/ToolOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func _swing_animation_finished():
	pass
