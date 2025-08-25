extends CharacterBody2D

# Animation
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# Movement
@export var movement_speed: float = 100.0

# Cookie
var carried_cookie: Node = null 
@onready var carry_point: Marker2D = $CarryPoint

func _ready() -> void:
	add_to_group("player")

	# Set z-index so Carry Point Cookie is always Foreground
	carry_point.z_index = 10

func _physics_process(_delta: float) -> void:
	var input_vector := Vector2.ZERO
	
	# Input handling (WASD + Arrow keys by default in Godot's InputMap)
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	# Normalize so diagonal isn't faster
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
	
	# Apply velocity
	velocity = input_vector * movement_speed
	move_and_slide()

	# Handle animations
	if input_vector == Vector2.ZERO:
		sprite.play("idle")  # Make sure you have an "idle" anim
	else:
		if abs(input_vector.x) > abs(input_vector.y):
			if input_vector.x > 0:
				sprite.play("right")
			else:
				sprite.play("left")
		else:
			if input_vector.y > 0:
				sprite.play("down")
			else:
				sprite.play("up")
