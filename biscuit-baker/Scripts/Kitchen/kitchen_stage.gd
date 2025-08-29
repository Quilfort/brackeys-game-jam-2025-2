extends Node2D

func _ready() -> void:
	# Reset game data for a fresh start
	GameData.reset_game()
	
	# Connect all statistics signals
	connect_statistics_signals()
	
	# Start game timer
	GameData.reset_timer()
	
	# Play kitchen background music with 5-second fade-in and reduced volume (-10dB)
	SoundManager.play_music("kitchen", true, 5.0, -10.0)

# Connect all signals for statistics tracking
func connect_statistics_signals() -> void:
	# Call the connect_signals function in GameData
	GameData.connect_signals()
	
	# Additional game-specific connections can be added here
	
	print("Statistics tracking initialized")
