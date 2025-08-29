extends Node2D

@export var heartbeat_volume: float = -0.0  
@export var music_volume: float = -15.0  

func _ready() -> void:
	# Reset game data for a fresh start
	GameData.reset_game()
	SoundManager.play_gameplay_sound("heartbeat", heartbeat_volume)
	
	# Connect all statistics signals
	connect_statistics_signals()
	
	# Start game timer
	GameData.reset_timer()
	
	# Play kitchen background music with 9-second fade-in and reduced volume
	SoundManager.play_music("kitchen", true, 9.0, music_volume)

# Connect all signals for statistics tracking
func connect_statistics_signals() -> void:
	# Call the connect_signals function in GameData
	GameData.connect_signals()
	
	# Additional game-specific connections can be added here

	print("Statistics tracking initialized")
