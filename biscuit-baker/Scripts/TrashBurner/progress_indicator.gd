extends Node2D

@export var radius: float = 8.0
@export var thickness: float = 2.0
@export var color_burning: Color = Color.GREEN

var progress: float = 0.0 # 0.0 → 1.0

func _draw() -> void:
	var angle_from = -PI / 2
	var angle_to = angle_from + (progress * TAU)
	
	draw_arc(Vector2.ZERO, radius, angle_from, angle_to, 64, color_burning, thickness)

func set_progress(value: float) -> void:
	progress = clamp(value, 0.0, 1.0)
	queue_redraw()
