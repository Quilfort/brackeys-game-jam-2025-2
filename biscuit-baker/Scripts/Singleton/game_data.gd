extends Node

# Game score
var score: int = 0
signal score_changed(new_score)

# Game timer
var game_time: float = 0.0
signal game_time_changed(new_time)

# Game difficulty progression
var difficulty_level: int = 1
signal difficulty_changed(new_level)

# Game statistics
var stats = {
	"max_customers": 0,
	"total_customers_served": 0,
	"total_cookies_made": 0,
	"total_cookies_burned": 0,
	"cookies_in_oven": 0,
	"cookies_fully_cooked": 0,
	"max_concurrent_customers": 0,
	"game_duration": 0.0
}

# Add points to the score
func add_score(points: int) -> void:
	score += points
	emit_signal("score_changed", score)

# Set score to a specific value
func set_score(new_score: int) -> void:
	score = new_score
	emit_signal("score_changed", score)

# Get the current score
func get_score() -> int:
	return score

# Reset score to zero
func reset_score() -> void:
	score = 0
	emit_signal("score_changed", score)

# Update game timer
func update_timer(delta: float) -> void:
	game_time += delta
	emit_signal("game_time_changed", game_time)
	
	# Update game duration statistic
	stats.game_duration = game_time

# Reset game timer
func reset_timer() -> void:
	game_time = 0.0
	emit_signal("game_time_changed", game_time)

# Set difficulty level
func set_difficulty(level: int) -> void:
	difficulty_level = level
	emit_signal("difficulty_changed", level)

# Get current difficulty level
func get_difficulty() -> int:
	return difficulty_level

# Update customer statistics
func update_customer_stats(current_customers: int, customer_served: bool = false) -> void:
	# Track maximum concurrent customers
	if current_customers > stats.max_concurrent_customers:
		stats.max_concurrent_customers = current_customers
	
	# Track total customers served
	if customer_served:
		stats.total_customers_served += 1
		# Add score when customer is served
		add_score(1)

# Update cookie statistics
func cookie_placed_in_oven() -> void:
	stats.cookies_in_oven += 1
	stats.total_cookies_made += 1

func cookie_removed_from_oven(cookie_state) -> void:
	# Check if cookie was fully cooked
	if cookie_state == 1:  # Assuming 1 is the COOKED state
		stats.cookies_fully_cooked += 1

func cookie_burned() -> void:
	stats.total_cookies_burned += 1

# Reset all game statistics
func reset_stats() -> void:
	stats = {
		"max_customers": 0,
		"total_customers_served": 0,
		"total_cookies_made": 0,
		"total_cookies_burned": 0,
		"cookies_in_oven": 0,
		"cookies_fully_cooked": 0,
		"max_concurrent_customers": 0,
		"game_duration": 0.0
	}
	
# Reset everything for a new game
func reset_game() -> void:
	reset_score()
	reset_timer()
	reset_stats()
	difficulty_level = 1

# Connect signals from game objects
func connect_signals() -> void:
	# This function should be called from the main scene when it's loaded
	# Connect to all ovens in the scene
	var ovens = get_tree().get_nodes_in_group("ovens")
	for oven in ovens:
		if not oven.is_connected("cookie_placed_in_oven", Callable(self, "cookie_placed_in_oven")):
			oven.connect("cookie_placed_in_oven", Callable(self, "cookie_placed_in_oven"))
		if not oven.is_connected("cookie_removed_from_oven", Callable(self, "cookie_removed_from_oven")):
			oven.connect("cookie_removed_from_oven", Callable(self, "cookie_removed_from_oven"))
	
	# Connect to all trash burners in the scene
	var burners = get_tree().get_nodes_in_group("trash_burners")
	for burner in burners:
		if not burner.is_connected("cookie_burned", Callable(self, "cookie_burned")):
			burner.connect("cookie_burned", Callable(self, "cookie_burned"))
