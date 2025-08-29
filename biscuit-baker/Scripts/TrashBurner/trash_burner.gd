extends Node2D

# Animation
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# Interaction/Collision
@onready var interaction_area: Area2D = $InteractionArea

# State
var trash_burner_on: bool = false
var player_in_range: bool = false
var player_ref: Node = null

# Burning properties
var burning_time: float = 0.0
var burning_time_required: float = 5.0  # 5 seconds to burn a cookie
var is_burning: bool = false

# Progress Indicator
@onready var progress_indicator = $ProgressIndicator

# Signal for statistics tracking
signal cookie_burned

func _ready() -> void:
	interaction_area.connect("body_entered", Callable(self, "_on_body_entered"))
	interaction_area.connect("body_exited", Callable(self, "_on_body_exited"))
	
	# Add to trash_burners group for statistics tracking
	add_to_group("trash_burners")

	# Set z-index so Trash Burner is always Background
	sprite.z_index = 0

	# Set burner to off by default
	trash_burner_on = false
	sprite.play("off")
	
	# Reset progress indicator
	if progress_indicator:
		progress_indicator.set_progress(0.0)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and player_in_range:
		handle_interaction()
	
	# Update burning progress
	if trash_burner_on:
		burning_time += delta
		
		# Update progress indicator
		if progress_indicator:
			progress_indicator.set_progress(burning_time / burning_time_required)
		
		# Check if burning is complete
		if burning_time >= burning_time_required:
			# Burning complete, turn off burner
			trash_burner_on = false
			burning_time = 0.0
			sprite.play("off")
			
			# Reset progress indicator
			if progress_indicator:
				progress_indicator.set_progress(0.0)
			# Emit signal for statistics after burning is complete
			emit_signal("cookie_burned")

func handle_interaction() -> void:
	if player_ref == null:
		return
	
	# Only allow interaction if the burner is not already on
	if not trash_burner_on:
		# Check if player has a cookie
		if player_ref.carried_cookie != null:
			# Get the cookie
			var cookie = player_ref.carried_cookie
			
			# Remove cookie from player
			player_ref.carry_point.remove_child(cookie)
			player_ref.carried_cookie = null
			
			# Destroy the cookie (it's being burned)
			cookie.queue_free()
			
			# Turn on the burner
			trash_burner_on = true
			burning_time = 0.0
			SoundManager.play_gameplay_sound("cookie_in_trash_burner")
			sprite.play("on")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		player_ref = body

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		player_ref = null
