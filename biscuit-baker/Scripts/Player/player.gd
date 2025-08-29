extends CharacterBody2D

# Animation
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# Movement
@export var movement_speed: float = 120.0
@export var footstep_volume: float = -40.0  
@export var footstep_interval: float = 0.2  

# Sound
var footstep_timer: float = 0.0
var was_moving: bool = false

# Cookie
var carried_cookie: Node = null 
@onready var carry_point: Marker2D = $CarryPoint

func _ready() -> void:
	add_to_group("player")

	# Set z-index so Carry Point Cookie is always Foreground
	carry_point.z_index = 10

func _physics_process(delta: float) -> void:
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
	
	# Handle footstep sounds
	handle_footstep_sound(delta, input_vector)

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

# Handle footstep sounds with timer to prevent overlap
func handle_footstep_sound(delta: float, input_vector: Vector2) -> void:
	var is_moving = input_vector.length() > 0
	
	# Only play footstep sounds when moving
	if is_moving:
		# Increment timer when moving
		footstep_timer += delta
		
		# Check if it's time to play a footstep sound and not already playing
		if footstep_timer >= footstep_interval and not SoundManager.is_sound_playing("walk"):
			# Play footstep sound at reduced volume
			SoundManager.play_gameplay_sound("walk", footstep_volume)
			# Reset timer
			footstep_timer = 0.0
	else:
		# Reset timer when not moving
		footstep_timer = footstep_interval  # Ready to play immediately when movement starts
	
	# Track movement state change
	was_moving = is_moving
