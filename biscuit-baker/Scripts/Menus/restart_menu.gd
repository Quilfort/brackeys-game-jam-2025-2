extends Node2D

# We'll use a variable to store the reference to the score label
var score_label: Label

func _ready() -> void:
	# Find the ScoreNumber label with error handling
	score_label = find_child("ScoreNumber")
	if not score_label:
		push_error("ScoreNumber label not found in Restart Menu")
		return
	
	# Display the final score
	display_final_score()

# Display the final score from GameData
func display_final_score() -> void:
	if score_label:
		score_label.text = "Final Score: " + str(GameData.get_score())

# Restart button handler
func _on_restart_button_pressed() -> void:
	# Reset the score
	GameData.reset_score()
	
	# Load the main game scene
	get_tree().change_scene_to_file("res://Scenes/Kitchen/kitchen_stage.tscn")

# Quit button handler
func _on_quit_button_pressed() -> void:
	get_tree().quit()
