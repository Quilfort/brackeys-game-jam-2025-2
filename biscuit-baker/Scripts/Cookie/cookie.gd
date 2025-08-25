extends Area2D

enum CookieState { DOUGH, COOKED, OVERCOOKED }

var state: CookieState = CookieState.DOUGH

# Cooking properties
var cooking_time: float = 0.0
var cooking_time_required: float = 5.0
var is_cooking: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	set_state(CookieState.DOUGH) 

func _process(delta: float) -> void:
	if is_cooking:
		process_cooking(delta)

func process_cooking(delta: float) -> void:
	cooking_time += delta
	
	if state == CookieState.DOUGH and cooking_time >= cooking_time_required:
		set_state(CookieState.COOKED)
		cooking_time = 0.0
	elif state == CookieState.COOKED and cooking_time >= cooking_time_required:
		set_state(CookieState.OVERCOOKED)
		cooking_time = 0.0

func set_cooking(cooking: bool) -> void:
	is_cooking = cooking
	# Don't reset cooking time when removed from heat
	# This allows cooking to continue from where it left off when placed back

func get_cooking_progress() -> float:
	return cooking_time / cooking_time_required

func set_state(_state: CookieState) -> void:
	if state == _state:
		return

	state = _state

	match state:
		CookieState.DOUGH:
			sprite.play("dough")
		CookieState.COOKED:
			sprite.play("cooked")
		CookieState.OVERCOOKED:
			sprite.play("overcooked")
