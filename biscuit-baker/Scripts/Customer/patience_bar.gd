extends Node2D

@export var width: float = 32.0
@export var height: float = 4.0
@export var border_width: float = 1.0
@export var color_full: Color = Color.GREEN
@export var color_medium: Color = Color.YELLOW
@export var color_low: Color = Color.RED
@export var border_color: Color = Color.BLACK

var max_value: float = 100.0
var value: float = 100.0

func _draw() -> void:
	# Draw border
	var rect = Rect2(-width/2 - border_width, -height/2 - border_width, 
		width + border_width*2, height + border_width*2)
	draw_rect(rect, border_color)
	
	# Draw background
	rect = Rect2(-width/2, -height/2, width, height)
	draw_rect(rect, Color(0.2, 0.2, 0.2, 0.5))
	
	# Draw fill
	var fill_width = (value / max_value) * width
	if fill_width > 0:
		var fill_color = get_color_for_value()
		rect = Rect2(-width/2, -height/2, fill_width, height)
		draw_rect(rect, fill_color)

func get_color_for_value() -> Color:
	var ratio = value / max_value
	if ratio > 0.6:
		return color_full
	elif ratio > 0.3:
		return color_medium
	else:
		return color_low

func set_value(new_value: float) -> void:
	value = clamp(new_value, 0.0, max_value)
	queue_redraw()

func set_max_value(new_max: float) -> void:
	max_value = max(0.1, new_max)  # Prevent division by zero
	queue_redraw()
