extends Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_area: Area2D = $InteractionArea

var oven_on: bool = false
var player_in_range: bool = false

func _ready() -> void:
	# Connect signals for player entering/exiting the interaction area
	interaction_area.connect("body_entered", Callable(self, "_on_body_entered"))
	interaction_area.connect("body_exited", Callable(self, "_on_body_exited"))
	
	# Start with the oven off
	oven_on = false
	sprite.play("off")

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and player_in_range:
		toggle_oven()

func toggle_oven() -> void:
	oven_on = !oven_on
	if oven_on:
		sprite.play("on")   
	else:
		sprite.play("off")

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_in_range = true

func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_in_range = false
