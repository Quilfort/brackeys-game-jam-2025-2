extends Node

# Game score
var score: int = 0
signal score_changed(new_score)

# Add points to the score
func add_score(points: int) -> void:
	score += points
	emit_signal("score_changed", score)

# Set score to a specific value
func set_score(new_score: int) -> void:
	score = new_score
	emit_signal("score_changed", score)

# Get the current score
func get_score() -> int:
	return score

# Reset score to zero
func reset_score() -> void:
	score = 0
	emit_signal("score_changed", score)
