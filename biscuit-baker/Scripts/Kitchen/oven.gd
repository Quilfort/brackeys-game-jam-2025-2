extends Node2D

# Animation
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# Interaction/Collision
@onready var interaction_area: Area2D = $InteractionArea

# State
var oven_on: bool = false
var player_in_range: bool = false
var player_ref: Node = null

# Cookie
var cookie_holder: Node2D
var cookie_in_oven: Node = null

# Progress Indicator
@onready var progress_indicator = $ProgressIndicator

# Signals for statistics tracking
signal cookie_placed_in_oven
signal cookie_removed_from_oven(cookie_state)

func _ready() -> void:
	interaction_area.connect("body_entered", Callable(self, "_on_body_entered"))
	interaction_area.connect("body_exited", Callable(self, "_on_body_exited"))
	
	# Add to ovens group for statistics tracking
	add_to_group("ovens")
	
	# Set z-index so Oven is always Background
	sprite.z_index = 0

	# Set oven to off by default
	oven_on = false
	sprite.play("off")
	
	# Create cookie holder if it doesn't exist
	if has_node("CookieHolder"):
		cookie_holder = $CookieHolder
	else:
		cookie_holder = Node2D.new()
		cookie_holder.name = "CookieHolder"
		add_child(cookie_holder)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and player_in_range:
		handle_interaction()
	
	# Update progress indicator based on cookie's cooking state
	if cookie_in_oven != null and oven_on:
		# Cookie handles its own cooking in its _process method
		
		# Update progress indicator based on cookie state
		if cookie_in_oven.state == cookie_in_oven.CookieState.DOUGH:
			progress_indicator.set_progress(cookie_in_oven.get_cooking_progress(), 0) # phase 0 = cooking
		elif cookie_in_oven.state == cookie_in_oven.CookieState.COOKED:
			progress_indicator.set_progress(cookie_in_oven.get_cooking_progress(), 1) # phase 1 = ready
		elif cookie_in_oven.state == cookie_in_oven.CookieState.OVERCOOKED:
			progress_indicator.set_progress(1.0, 2) # phase 2 = overcooked
	elif progress_indicator:
		# No cookie or oven off, reset progress indicator
		progress_indicator.set_progress(0.0, 0)

func toggle_oven() -> void:
	oven_on = !oven_on
	
	# Update cookie cooking state
	if cookie_in_oven != null:
		cookie_in_oven.set_cooking(oven_on)
	
	if oven_on:
		sprite.play("on")   
	else:
		sprite.play("off")

func handle_interaction() -> void:
	if player_ref == null:
		return

	# Case 1: Player has a cookie and there's no cookie in the oven
	if player_ref.carried_cookie != null and cookie_in_oven == null:
		# Put cookie in the oven
		var cookie = player_ref.carried_cookie
		player_ref.carry_point.remove_child(cookie)
		cookie_holder.add_child(cookie)
		cookie.position = Vector2.ZERO
		cookie_in_oven = cookie
		player_ref.carried_cookie = null
		
		# Emit signal for statistics
		emit_signal("cookie_placed_in_oven")
		
		# Turn on the oven if it's not already on
		if not oven_on:
			toggle_oven()
		else:
			# If oven is already on, we need to explicitly set the cookie to cooking
			cookie_in_oven.set_cooking(true)
		
		return
	
	# Case 2: Player has no cookie and there's a cookie in the oven
	elif player_ref.carried_cookie == null and cookie_in_oven != null:
		# Take cookie out of the oven
		var cookie = cookie_in_oven
		var cookie_state = cookie.state
		cookie.set_cooking(false)  # Stop cooking when removed
		cookie_holder.remove_child(cookie)
		player_ref.carry_point.add_child(cookie)
		cookie.position = Vector2.ZERO
		player_ref.carried_cookie = cookie
		
		# Emit signal for statistics with cookie state
		emit_signal("cookie_removed_from_oven", cookie_state)
		
		cookie_in_oven = null
		
		# Turn off the oven when cookie is removed
		if oven_on:
			toggle_oven()
			
		return
	
	# Case 3: Toggle the oven ONLY if there's a cookie in it
	elif cookie_in_oven != null:
		toggle_oven()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		player_ref = body

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		player_ref = null
