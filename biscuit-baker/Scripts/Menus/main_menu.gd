extends Node2D


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Kitchen/kitchen_stage.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
