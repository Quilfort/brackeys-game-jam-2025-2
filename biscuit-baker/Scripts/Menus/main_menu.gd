extends Node2D


func _on_start_button_pressed() -> void:
	# Play start button sound and wait for it to finish before changing scene
	SoundManager.play_sound_and_wait("start", func():
		get_tree().change_scene_to_file("res://Scenes/Kitchen/kitchen_stage.tscn")
	)


func _on_quit_button_pressed() -> void:
	# Play quit button sound and wait for it to finish before quitting
	SoundManager.play_sound_and_wait("quit", func():
		get_tree().quit()
	)
