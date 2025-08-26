extends CharacterBody2D

# Animation
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# Interaction/Collision
@onready var interaction_area: Area2D = $InteractionArea

# Movement
var move_speed: float = 50.0
var target_position: Vector2
var is_moving: bool = true

# States
enum CustomerState { ENTERING, WAITING, SATISFIED, LEAVING, ANGRY }
var current_state: CustomerState = CustomerState.ENTERING

# Waiting properties
var patience_time: float = 15.0  
var patience_remaining: float = 15.0
var is_waiting: bool = false

# Happy animation properties
var happy_animation_count: int = 0
var happy_animation_target: int = 2  
var happy_animation_timer: float = 0.0
var happy_animation_duration: float = 1.0  

# Score
var points_value: int = 1  
var score_added: bool = false 

# Interaction
var player_in_range: bool = false
var player_ref: Node = null

# Progress Bar
@onready var patience_bar = $PatienceBar

func _ready() -> void:
	interaction_area.connect("body_entered", Callable(self, "_on_body_entered"))
	interaction_area.connect("body_exited", Callable(self, "_on_body_exited"))
	
	# Set initial state
	set_state(CustomerState.ENTERING)
	
	# Initialize patience bar
	if patience_bar:
		patience_bar.set_max_value(patience_time)
		patience_bar.set_value(patience_remaining)
		patience_bar.visible = false
	
	# Print debug info
	print("Customer initialized with target: ", target_position)

func _physics_process(delta: float) -> void:
	match current_state:
		CustomerState.ENTERING:
			process_movement(delta)
		CustomerState.WAITING:
			process_waiting(delta)
		CustomerState.SATISFIED:
			process_satisfied(delta)
		CustomerState.LEAVING:
			process_leaving(delta)
		CustomerState.ANGRY:
			process_leaving(delta)

func process_movement(_delta: float) -> void:
	if is_moving:
		var direction = (target_position - global_position).normalized()
		velocity = direction * move_speed
		
		# Update sprite direction and animation
		update_animation(direction)
			
		# Move the character
		move_and_slide()
		
		# Check if we've reached the target
		if global_position.distance_to(target_position) < 5.0:
			# Arrived at counter
			is_moving = false
			set_state(CustomerState.WAITING)

func process_waiting(delta: float) -> void:
	# Decrease patience over time
	patience_remaining -= delta
	
	# Update patience bar
	if patience_bar:
		patience_bar.set_value(patience_remaining)
	
	# Check if patience has run out
	if patience_remaining <= 0:
		set_state(CustomerState.ANGRY)

func process_satisfied(delta: float) -> void:
	# Add score when customer is first satisfied (only once)
	if not score_added:
		GameData.add_score(points_value)
		score_added = true
	
	# Count how many times we've played the happy animation
	happy_animation_timer += delta
	
	# Check if it's time to play the next animation or move to leaving state
	if happy_animation_timer >= happy_animation_duration:
		happy_animation_timer = 0.0
		happy_animation_count += 1
		
		# Play the happy animation again
		sprite.play("happy")
		
		# If we've played it enough times, start leaving
		if happy_animation_count >= happy_animation_target:
			set_state(CustomerState.LEAVING)

func process_leaving(_delta: float) -> void:
	if is_moving:
		var exit_position = Vector2(global_position.x, 300)  # Move down off screen
		var direction = (exit_position - global_position).normalized()
		velocity = direction * move_speed
		
		# Update sprite direction and animation
		update_animation(direction)
		
		# Move the character
		move_and_slide()
		
		# Check if we've left the screen
		if global_position.y > 300:
			queue_free()  # Remove customer when they leave

func set_state(new_state: CustomerState) -> void:
	if current_state == new_state:
		return
		
	var previous_state = current_state
	current_state = new_state
	
	match current_state:
		CustomerState.ENTERING:
			sprite.play("walk_up")
			is_moving = true
			if patience_bar:
				patience_bar.visible = false
		CustomerState.WAITING:
			sprite.play("idle")
			is_moving = false
			is_waiting = true
			if patience_bar:
				patience_bar.visible = true
			# Only reset patience if coming from ENTERING state
			if previous_state == CustomerState.ENTERING:
				patience_remaining = patience_time
				if patience_bar:
					patience_bar.set_value(patience_remaining)
		CustomerState.SATISFIED:
			sprite.play("happy")
			is_moving = false  # Don't move while playing happy animation
			is_waiting = false
			if patience_bar:
				patience_bar.visible = false
			# Reset happy animation counters
			happy_animation_count = 0
			happy_animation_timer = 0.0
			score_added = false  # Reset score flag when entering state
		CustomerState.LEAVING:
			sprite.play("walk_down")
			is_moving = true
			is_waiting = false
			if patience_bar:
				patience_bar.visible = false
		CustomerState.ANGRY:
			sprite.play("angry")
			is_moving = true
			is_waiting = false
			if patience_bar:
				patience_bar.visible = false

func handle_interaction() -> void:
	if player_ref == null or not is_waiting:
		return
	
	# Check if player has a cookie
	if player_ref.carried_cookie != null:
		var cookie = player_ref.carried_cookie
		
		# Check if cookie is properly cooked (not dough or overcooked)
		if cookie.state == cookie.CookieState.COOKED:
			# Take cookie from player
			player_ref.carry_point.remove_child(cookie)
			player_ref.carried_cookie = null
			
			# Cookie is accepted, destroy it
			cookie.queue_free()
			
			# Customer is satisfied
			set_state(CustomerState.SATISFIED)
		else:
			# Wrong cookie state, show some feedback
			# This could be a speech bubble or animation
			print("Customer wants a properly cooked cookie!")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		player_ref = body

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		player_ref = null

# This function would be called when player presses interact near the customer
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player_in_range:
		handle_interaction()

# Helper function to update animation based on movement direction
func update_animation(direction: Vector2) -> void:
	# Determine the dominant direction (horizontal or vertical)
	if abs(direction.x) > abs(direction.y):
		# Horizontal movement is dominant
		if direction.x < 0:
			sprite.play("walk_left")
			sprite.flip_h = false
		else:
			sprite.play("walk_right") 
			sprite.flip_h = false
	else:
		# Vertical movement is dominant
		if direction.y < 0:
			sprite.play("walk_up")
			sprite.flip_h = false
		else:
			sprite.play("walk_down")
			sprite.flip_h = false
