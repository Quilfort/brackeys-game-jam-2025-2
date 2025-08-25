extends Node2D

@export var radius: float = 8.0
@export var thickness: float = 2.0
@export var color_cooking: Color = Color.GREEN
@export var color_ready: Color = Color.YELLOW
@export var color_overcooked: Color = Color.RED

var progress: float = 0.0 # 0.0 → 1.0
var phase: int = 0 # 0 = cooking, 1 = ready, 2 = overcooked

func _draw() -> void:
	var angle_from = -PI / 2
	var angle_to = angle_from + (progress * TAU)
	
	var col := color_cooking
	if phase == 1:
		col = color_ready
	elif phase == 2:
		col = color_overcooked
	
	draw_arc(Vector2.ZERO, radius, angle_from, angle_to, 64, col, thickness)

func set_progress(value: float, _phase: int) -> void:
	progress = clamp(value, 0.0, 1.0)
	phase = _phase
	queue_redraw()
