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
var cooking_time: float = 0.0
var cooking_time_required: float = 5.0 

# Progress Indicator
@onready var progress_indicator = $ProgressIndicator

func _ready() -> void:
	interaction_area.connect("body_entered", Callable(self, "_on_body_entered"))
	interaction_area.connect("body_exited", Callable(self, "_on_body_exited"))
	
	oven_on = false
	sprite.play("off")
	
	# Create cookie holder if it doesn't exist
	if has_node("CookieHolder"):
		cookie_holder = $CookieHolder
	else:
		cookie_holder = Node2D.new()
		cookie_holder.name = "CookieHolder"
		add_child(cookie_holder)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and player_in_range:
		handle_interaction()
	
	# Inside _process
	if cookie_in_oven != null and oven_on:
		cooking_time += delta
		
		if cookie_in_oven.state == cookie_in_oven.CookieState.DOUGH:
			progress_indicator.set_progress(cooking_time / cooking_time_required, 0) # phase 0 = cooking
			
			if cooking_time >= cooking_time_required:
				cookie_in_oven.set_state(cookie_in_oven.CookieState.COOKED)
				print("Cookie is cooked!")
				cooking_time = 0.0
		
		elif cookie_in_oven.state == cookie_in_oven.CookieState.COOKED:
			progress_indicator.set_progress(cooking_time / cooking_time_required, 1) # phase 1 = ready
			
			if cooking_time >= cooking_time_required:
				cookie_in_oven.set_state(cookie_in_oven.CookieState.OVERCOOKED)
				print("Cookie is overcooked!")
				progress_indicator.set_progress(1.0, 2) # lock as red
				cooking_time = 0.0

func toggle_oven() -> void:
	oven_on = !oven_on
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
		
		# Turn on the oven if it's not already on
		if not oven_on:
			toggle_oven()
		
		cooking_time = 0.0
		return
	
	# Case 2: Player has no cookie and there's a cookie in the oven
	elif player_ref.carried_cookie == null and cookie_in_oven != null:
		# Take cookie out of the oven
		var cookie = cookie_in_oven
		cookie_holder.remove_child(cookie)
		player_ref.carry_point.add_child(cookie)
		cookie.position = Vector2.ZERO
		player_ref.carried_cookie = cookie
		cookie_in_oven = null
		return
	
	# Case 3: Toggle the oven ONLY if there's a cookie in it
	elif cookie_in_oven != null:
		toggle_oven()
		# Reset cooking time when turning off the oven
		if not oven_on:
			cooking_time = 0.0

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"): # Add player to "player" group in the editor
		player_in_range = true
		player_ref = body

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		player_ref = null
