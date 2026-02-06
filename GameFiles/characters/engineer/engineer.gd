extends CharacterBody2D

@export var move_speed: float = 200.0

@onready var anim_tree: AnimationTree = $AnimationTree
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var animationState = anim_tree.get("parameters/playback")

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

	## Set direction for both BlendSpaces
	anim_tree.set("parameters/idle/blend_position", last_dir)
	anim_tree.set("parameters/walk/blend_position", last_dir)
	animationState.travel("idle")
	if is_moving:
		animationState.travel("walk")
