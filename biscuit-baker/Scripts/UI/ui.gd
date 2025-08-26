extends Control

# We'll use a variable to store the reference to the score label
var score_label: Label

func _ready() -> void:
	# Find the ScoreNumber label with error handling
	score_label = find_child("ScoreNumber")
	if not score_label:
		push_error("ScoreNumber label not found in UI scene")
		return
	
	# Connect to the score_changed signal from GameData
	GameData.connect("score_changed", Callable(self, "_on_score_changed"))
	
	# Initialize score display
	update_score_display(GameData.get_score())

# Update the score label when score changes
func _on_score_changed(new_score: int) -> void:
	update_score_display(new_score)

# Update the score display with the given value
func update_score_display(score: int) -> void:
	if score_label:
		score_label.text = str(score)
