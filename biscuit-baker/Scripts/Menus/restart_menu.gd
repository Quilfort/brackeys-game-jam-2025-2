extends Node2D

# UI references
var stats_container: VBoxContainer
var title_label: Label
var score_label: Label
var time_label: Label
var customers_label: Label
var cookies_label: Label
var burned_label: Label
var rush_label: Label

func _ready() -> void:
	# Start playing background music with fade in
	SoundManager.play_music("restart_menu")
	
	# Find UI elements with error handling
	var control_node = find_child("Control")
	if control_node:
		var panel_node = control_node.find_child("Panel")
		if panel_node:
			title_label = panel_node.find_child("TitleLabel")
			stats_container = panel_node.find_child("StatsContainer")
			
			# Find all labels within the stats container
			if stats_container:
				score_label = stats_container.find_child("ScoreLabel")
				time_label = stats_container.find_child("TimeLabel")
				customers_label = stats_container.find_child("CustomersLabel")
				cookies_label = stats_container.find_child("CookiesLabel")
				burned_label = stats_container.find_child("BurnedLabel")
				rush_label = stats_container.find_child("RushLabel")
			else:
				push_error("StatsContainer not found in Panel")
		else:
			push_error("Panel not found in Control")
	else:
		push_error("Control not found in Restart Menu")
	
	# Display the final stats
	display_game_stats()
	log_game_stats() 

# Display the final game statistics in a concise, readable format
func display_game_stats() -> void:
	var stats = GameData.stats
	var score = GameData.get_score()
	
	# Format time as minutes:seconds
	var minutes = int(stats.game_duration / 60)
	var seconds = int(stats.game_duration) % 60
	var time_str = "%d:%02d" % [minutes, seconds]
	
	# Set up all the stat labels with concise descriptions
	if score_label:
		score_label.text = "FINAL SCORE: %d" % score
	
	if time_label:
		time_label.text = "You survived for %s!" % time_str
	
	if customers_label:
		var customer_text = "• Customers: %d served" % GameData.score
		
		# Add brief comment based on customers served
		if GameData.score >= 15:
			customer_text += " - Legend!"
		elif GameData.score >= 10:
			customer_text += " - Great job!"
		elif GameData.score >= 5:
			customer_text += " - Not bad!"
		else:
			customer_text += " - Keep practicing!"
			
		customers_label.text = customer_text
	
	if cookies_label:
		var cookies_text = "• Cookies: %d baked (%d perfect)" % [stats.total_cookies_made, stats.cookies_fully_cooked]
		
		# Calculate cooking success rate
		var success_rate = 0
		if stats.total_cookies_made > 0:
			success_rate = int((float(stats.cookies_fully_cooked) / float(stats.total_cookies_made)) * 100)
		
		# Add brief comment based on cooking success
		if success_rate >= 90:
			cookies_text += " - Master baker!"
		elif success_rate >= 70:
			cookies_text += " - Great skills!"
		elif success_rate >= 50:
			cookies_text += " - Getting there!"
		else:
			cookies_text += " - Practice makes perfect!"
			
		cookies_label.text = cookies_text
	
	if burned_label:
		var burned_ratio = 0
		if stats.total_cookies_made > 0:
			burned_ratio = float(stats.total_cookies_burned) / float(stats.total_cookies_made)
		
		var burned_text = "• Burned: %d cookies" % stats.total_cookies_burned
		
		# Add brief comment based on burn ratio
		if burned_ratio == 0 and stats.total_cookies_made > 5:
			burned_text += " - Flawless!"
		elif burned_ratio < 0.1:
			burned_text += " - Careful baker!"
		elif burned_ratio < 0.3:
			burned_text += " - Not too shabby!"
		else:
			burned_text += " - Watch that timer!"
			
		burned_label.text = burned_text
	
	if rush_label:
		var rush_text = "• Busiest: %d customers at once" % stats.max_concurrent_customers
		
		# Add brief comment based on max concurrent customers
		if stats.max_concurrent_customers >= 6:
			rush_text += " - Madness!"
		elif stats.max_concurrent_customers >= 4:
			rush_text += " - Rush hour!"
		elif stats.max_concurrent_customers >= 2:
			rush_text += " - Well handled!"
		else:
			rush_text += " - Calm day!"
			
		rush_label.text = rush_text

func log_game_stats() -> void:
	var stats = GameData.stats
	print("Game Stats:")
	print("  Score: %d" % GameData.score)
	print("  Time: %d seconds" % stats.game_duration)
	print("  Customers Served: %d" % stats.total_customers_served)
	print("  Cookies Made: %d" % stats.total_cookies_made)
	print("  Cookies Fully Cooked: %d" % stats.cookies_fully_cooked)
	print("  Cookies Burned: %d" % stats.total_cookies_burned)
	print("  Max Concurrent Customers: %d" % stats.max_concurrent_customers)

# Restart button handler
func _on_restart_button_pressed() -> void:
	# Fade out music and play restart button sound
	SoundManager.play_sound_and_wait("restart", func():
		# Reset the game
		SoundManager.fade_out_music(func():
			GameData.reset_game()
			# Load the main game scene
			get_tree().change_scene_to_file("res://Scenes/kitchen/kitchen_stage.tscn")
		)
	)

func _on_quit_button_pressed() -> void:
	# Fade out music and play quit button sound
	SoundManager.play_sound_and_wait("quit", func():
		SoundManager.fade_out_music(func():
			get_tree().quit()
		)
	)
