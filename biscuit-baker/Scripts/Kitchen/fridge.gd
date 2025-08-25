extends Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_area: Area2D = $InteractionArea

@export var cookie_scene: PackedScene

var fridge_open: bool = false
var player_in_range: CharacterBody2D = null

func _ready() -> void:
	interaction_area.connect("body_entered", Callable(self, "_on_body_entered"))
	interaction_area.connect("body_exited", Callable(self, "_on_body_exited"))
	sprite.play("closed")

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and player_in_range:
		interact_with_player(player_in_range)

func interact_with_player(player: CharacterBody2D) -> void:
	# if fridge is closed and player doesn't carry a cookie
	if not fridge_open and player.carried_cookie == null:
		# give the player a cookie
		var cookie = cookie_scene.instantiate()
		player.carry_point.add_child(cookie)
		cookie.position = Vector2.ZERO # snaps to carry point
		
		# Explicitly set the cookie state to DOUGH and ensure sprite updates
		cookie.set_state(cookie.CookieState.DOUGH)
		player.carried_cookie = cookie

		# open fridge animation
		fridge_open = true
		sprite.play("open")

	else:
		# close fridge
		fridge_open = false
		sprite.play("closed")

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_in_range = body

func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D and body == player_in_range:
		player_in_range = null
