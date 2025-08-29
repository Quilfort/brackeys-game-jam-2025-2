extends Node2D

func _ready() -> void:
	# Start playing background music with fade in
	SoundManager.play_music("main_menu")

func _on_start_button_pressed() -> void:
	SoundManager.play_sound_and_wait("start", func():
		SoundManager.fade_out_music(func():
			get_tree().change_scene_to_file("res://Scenes/Kitchen/kitchen_stage.tscn")
		)
	)

func _on_quit_button_pressed() -> void:
	SoundManager.play_sound_and_wait("quit", func():
		SoundManager.fade_out_music(func():
			get_tree().quit()
		)
	)
