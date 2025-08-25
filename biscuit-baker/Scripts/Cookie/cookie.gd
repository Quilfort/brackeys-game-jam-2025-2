extends Area2D

enum CookieState { DOUGH, COOKED, OVERCOOKED }

var state: CookieState = CookieState.DOUGH

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	set_state(CookieState.DOUGH) 

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
