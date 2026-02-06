extends CharacterBody2D

@export var move_speed: float = 200.0

@onready var anim_tree: AnimationTree = $AnimationTree
@onready var anim_player: AnimationPlayer = $AnimationPlayer

# Stores last valid movement direction for idle facing
var last_dir: Vector2 = Vector2.DOWN


func _ready() -> void:
	anim_player.active = true

func _physics_process(_delta: float) -> void:
	var input_vector := Vector2.ZERO

	input_vector.x = Input.get_action_strength("mapped_move_right") - Input.get_action_strength("mapped_move_left")
	input_vector.y = Input.get_action_strength("mapped_move_down") - Input.get_action_strength("mapped_move_up")

	# --- MOVEMENT (smooth, continuous) ---
	if input_vector.length() > 0.0:
		input_vector = input_vector.normalized()
		velocity = input_vector * move_speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()

	# --- ANIMATION TREE CONTROL ---
	_update_animation_tree(input_vector)


func _update_animation_tree(move: Vector2) -> void:
	var is_moving := move.length() > 0.0

	# Remember last direction only when actually moving
	if is_moving:
		last_dir = move

	# Switch between states (StateMachine) — FIXED SYNTAX
	anim_tree.set(
		"parameters/State/current",
		"walk" if is_moving else "Idle"
	)

	# Drive both BlendSpace2D nodes — FIXED SYNTAX
	anim_tree.set(
		"parameters/walk/blend_position",
		move if is_moving else last_dir
	)

	anim_tree.set(
		"parameters/idle/blend_position",
		last_dir
	)



#extends CharacterBody2D
#
#@export var move_speed: float = 200.0
#
#@onready var anim: AnimationPlayer = $AnimationPlayer
#
#var last_facing: Vector2i = Vector2i.DOWN
#
#
#func _physics_process(_delta: float) -> void:
	#var input_vector := Vector2.ZERO
#
	#input_vector.x = Input.get_action_strength("mapped_move_right") - Input.get_action_strength("mapped_move_left")
	#input_vector.y = Input.get_action_strength("mapped_move_down") - Input.get_action_strength("mapped_move_up")
#
	#var move_dir := Vector2i.ZERO
#
	## Normalize to prevent faster diagonal movement
	#if input_vector.length() > 0.0:
		#input_vector = input_vector.normalized()
		#move_dir = Vector2i(round(input_vector.x), round(input_vector.y))
		#last_facing = move_dir
#
	#velocity = input_vector * move_speed
	#move_and_slide()
#
	#_update_animation(move_dir)
#
#
#func _update_animation(move_dir: Vector2i) -> void:
	#if move_dir == Vector2i.ZERO:
		#_play_idle()
		#return
#
	#match move_dir:
		#Vector2i(1, 0):
			#_play("walk_right")
		#Vector2i(-1, 0):
			#_play("walk_left")
		#Vector2i(0, -1):
			#_play("walk_up")
		#Vector2i(0, 1):
			#_play("walk_down")
		#Vector2i(1, -1):
			#_play("walk_up_right")
		#Vector2i(-1, -1):
			#_play("walk_up_left")
		#Vector2i(1, 1):
			#_play("walk_down_right")
		#Vector2i(-1, 1):
			#_play("walk_down_left")
#
#
#func _play_idle() -> void:
	#match last_facing:
		#Vector2i(1, 0):
			#_play("idle_right")
		#Vector2i(-1, 0):
			#_play("idle_left")
		#Vector2i(0, -1):
			#_play("idle_up")
		#Vector2i(0, 1):
			#_play("idle_down")
		#Vector2i(1, -1):
			#_play("idle_up_right")
		#Vector2i(-1, -1):
			#_play("idle_up_left")
		#Vector2i(1, 1):
			#_play("idle_down_right")
		#Vector2i(-1, 1):
			#_play("idle_down_left")
		#_:
			#_play("idle_down")
#
#
## Prevents animation restart every frame
#func _play(nm: String) -> void:
	#print(nm)
	#if anim.current_animation != nm:
		#anim.play(nm)
