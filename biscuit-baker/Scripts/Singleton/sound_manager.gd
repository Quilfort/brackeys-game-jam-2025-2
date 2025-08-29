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

# Gameplay sounds
var gameplay_sounds = {
	"walk": preload("res://Assets/Sounds/Player/walk_sound.wav"),
	"customer_satisfied": preload("res://Assets/Sounds/Kitchen/customer_satisfied.wav"),
	"heartbeat": preload("res://Assets/Sounds/Kitchen/start_heartbeat.wav"),
	"cookie_alarm": preload("res://Assets/Sounds/Cookie/cookie_alarm.wav")
}

# Music tracks
var music_tracks = {
	"main_menu": preload("res://Assets/Sounds/Menus/main_menu_sound.wav") as AudioStream,
	"restart_menu": preload("res://Assets/Sounds/Menus/restart_menu_1_sound.wav") as AudioStream,
	"kitchen": preload("res://Assets/Sounds/Kitchen/kitchen_background_music.ogg") as AudioStream
}

# Dictionary to track active audio players
var _active_players = {}

# Music settings
@export var fade_duration: float = 1.0  # Duration of fade in/out in seconds
@export var music_volume_db: float = -5.0  # Default music volume

# Current background music player
var _current_music_player: AudioStreamPlayer = null
var _music_tween: Tween = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS # Make sure sounds work even when game is paused

# Play a button sound and wait for completion before proceeding
# Returns the AudioStreamPlayer instance
func play_button_sound(sound_name: String) -> AudioStreamPlayer:
	if not button_sounds.has(sound_name):
		push_error("Button sound not found: " + sound_name)
		return null
	
	return _play_sound(button_sounds[sound_name], sound_name, SoundType.BUTTON)

# Play a gameplay sound
# Returns the AudioStreamPlayer instance
func play_gameplay_sound(sound_name: String, volume_db: float = 0.0) -> AudioStreamPlayer:
	if not gameplay_sounds.has(sound_name):
		push_error("Gameplay sound not found: " + sound_name)
		return null
	
	var player = _play_sound(gameplay_sounds[sound_name], sound_name, SoundType.GAMEPLAY)
	if player:
		player.volume_db = volume_db
	
	return player

# Play background music with fade in
# If another music track is playing, it will fade out first
func play_music(track_name: String, fade_in: bool = true, custom_fade_duration: float = -1.0, custom_volume_db: float = 0.0) -> AudioStreamPlayer:
	if not music_tracks.has(track_name):
		push_error("Music track not found: " + track_name)
		return null
	
	# If we already have this music playing, don't restart it
	if _active_players.has(track_name) and _active_players[track_name].playing:
		return _active_players[track_name]
	
	# If we have another music track playing, fade it out first
	if _current_music_player != null and _current_music_player.playing:
		fade_out_music()
	
	# Create new music player
	var player = AudioStreamPlayer.new()
	player.stream = music_tracks[track_name]
	player.name = "Music_" + track_name
	
	# Set volume - use custom volume if provided, otherwise use default
	var target_volume_db = music_volume_db
	if custom_volume_db != 0.0:
		target_volume_db = custom_volume_db
	player.volume_db = target_volume_db
	
	player.bus = "Music"  # Assuming you have a Music bus
	
	# Set looping only for specific tracks that need it
	if track_name == "kitchen":
		# Set to loop for kitchen music
		if player.stream is AudioStreamWAV:
			player.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		elif player.stream is AudioStreamOggVorbis:
			player.stream.loop = true
		else:
			# For other audio formats, just try setting the loop property if available
			if player.stream.has_method("set_loop") or player.stream.get("loop") != null:
				player.stream.loop = true
	
	# Add to scene tree
	add_child(player)
	
	# Store reference to the player
	_active_players[track_name] = player
	_current_music_player = player
	
	# Start playing
	player.play()
	
	# Fade in if requested
	if fade_in:
		# Start at silent
		player.volume_db = -80.0
		
		# Use custom fade duration if provided, otherwise use default
		var actual_fade_duration = custom_fade_duration if custom_fade_duration > 0 else fade_duration
		
		# Create tween for fade in
		if _music_tween:
			_music_tween.kill()
		_music_tween = create_tween()
		_music_tween.tween_property(player, "volume_db", target_volume_db, actual_fade_duration)
	
	return player

# Fade out current music
func fade_out_music(callback: Callable = Callable()) -> void:
	if _current_music_player == null or not _current_music_player.playing:
		if callback.is_valid():
			callback.call()
		return
	
	# Create tween for fade out
	if _music_tween:
		_music_tween.kill()
	_music_tween = create_tween()
	_music_tween.tween_property(_current_music_player, "volume_db", -80.0, fade_duration)
	
	# Connect to tween completion to stop and clean up
	_music_tween.finished.connect(func():
		var track_name = _current_music_player.name.replace("Music_", "")
		_active_players.erase(track_name)
		_current_music_player.stop()
		_current_music_player.queue_free()
		_current_music_player = null
		
		if callback.is_valid():
			callback.call()
	)

# Check if a sound is currently playing
func is_sound_playing(sound_name: String) -> bool:
	return _active_players.has(sound_name) and _active_players[sound_name].playing

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
	
	# Remove from active players (except music which loops)
	if not sound_name.begins_with("Music_"):
		_active_players.erase(sound_name)
		
		# Clean up the player
		player.queue_free()

# Play a sound and wait for it to finish before executing the callback
func play_sound_and_wait(sound_name: String, callback: Callable) -> void:
	var player = play_button_sound(sound_name)
	if player:
		# Use CONNECT_ONE_SHOT which automatically disconnects after first trigger
		var on_finished = func(finished_name):
			if finished_name == sound_name:
				callback.call()
		sound_finished.connect(on_finished, CONNECT_ONE_SHOT)
