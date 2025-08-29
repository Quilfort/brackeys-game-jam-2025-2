extends Node

signal sound_finished(sound_name: String)

# Sound categories
enum SoundType {
	BUTTON,
	GAMEPLAY,
	MUSIC
}

# Button sounds
var button_sounds = {
	"start": preload("res://Assets/Sounds/Menus/start_button.wav"),
	"restart": preload("res://Assets/Sounds/Menus/restart_button.wav"),
	"quit": preload("res://Assets/Sounds/Menus/quit_button.wav")
}

# Dictionary to track active audio players
var _active_players = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS # Make sure sounds work even when game is paused

# Play a button sound and wait for completion before proceeding
# Returns the AudioStreamPlayer instance
func play_button_sound(sound_name: String) -> AudioStreamPlayer:
	if not button_sounds.has(sound_name):
		push_error("Button sound not found: " + sound_name)
		return null
	
	return _play_sound(button_sounds[sound_name], sound_name, SoundType.BUTTON)

# Generic sound player that handles creating and connecting signals
func _play_sound(stream: AudioStream, sound_name: String, _type: int) -> AudioStreamPlayer:
	var player = AudioStreamPlayer.new()
	player.stream = stream
	player.name = "Sound_" + sound_name
	
	# Add to scene tree
	add_child(player)
	
	# Connect finished signal
	player.finished.connect(_on_sound_finished.bind(player, sound_name))
	
	# Store reference to the player
	_active_players[sound_name] = player
	
	# Play the sound
	player.play()
	
	return player

# Handle sound completion
func _on_sound_finished(player: AudioStreamPlayer, sound_name: String) -> void:
	# Emit signal that sound has finished
	sound_finished.emit(sound_name)
	
	# Remove from active players
	_active_players.erase(sound_name)
	
	# Clean up the player
	player.queue_free()

# Play a sound and wait for it to finish before executing the callback
func play_sound_and_wait(sound_name: String, callback: Callable) -> void:
	var player = play_button_sound(sound_name)
	if player:
		# Use CONNECT_ONE_SHOT which automatically disconnects after first trigger
		sound_finished.connect(func(finished_name):
			if finished_name == sound_name:
				callback.call()
		, CONNECT_ONE_SHOT)
