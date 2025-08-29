extends TileMapLayer

@onready var mute_button: Button = $MuteButton

# Preload the mute/unmute icons
const MUTE_ICON = preload("res://Assets/UI/GUI/mute.png")
const UNMUTE_ICON = preload("res://Assets/UI/GUI/unmute.png")

# Icon size
const ICON_SIZE = Vector2(25, 25)

func _ready() -> void:
	# Connect to the mute state changed signal from SoundManager
	SoundManager.mute_state_changed.connect(_on_mute_state_changed)
	
	# Update button appearance based on initial mute state
	_update_mute_button_appearance(SoundManager.is_muted())
	
	# Make button flat (no background)
	mute_button.flat = true
	
	# Remove focus outline
	mute_button.focus_mode = Control.FOCUS_NONE
	
	# Remove hover effect
	var empty_style = StyleBoxEmpty.new()
	mute_button.add_theme_stylebox_override("normal", empty_style)
	mute_button.add_theme_stylebox_override("hover", empty_style)
	mute_button.add_theme_stylebox_override("pressed", empty_style)
	mute_button.add_theme_stylebox_override("focus", empty_style)
	
	# Clear text since we're using icons
	mute_button.text = ""
	
	# Configure icon sizing
	mute_button.expand_icon = true
	mute_button.custom_minimum_size = ICON_SIZE
	mute_button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _on_mute_button_pressed() -> void:
	# Toggle mute state using SoundManager
	var is_muted = SoundManager.toggle_mute()
	
	# Update button appearance
	_update_mute_button_appearance(is_muted)

# Update the mute button appearance based on mute state
func _update_mute_button_appearance(is_muted: bool) -> void:
	if is_muted:
		mute_button.icon = MUTE_ICON
	else:
		mute_button.icon = UNMUTE_ICON

# Handle mute state changes from elsewhere in the game
func _on_mute_state_changed(is_muted: bool) -> void:
	_update_mute_button_appearance(is_muted)
