extends Node

# This is a simple test script to verify that our statistics tracking system works correctly
# Attach this to a test scene or run it from the editor

func _ready():
	print("Starting statistics tracking test...")
	
	# Initialize GameData
	GameData.reset_game()
	GameData.connect_signals()
	
	# Print initial stats
	print_stats("Initial stats")
	
	# Simulate some game events
	simulate_game_events()
	
	# Print final stats
	print_stats("Final stats after simulation")

func simulate_game_events():
	print("Simulating game events...")
	
	# Simulate cookies in oven
	print("- Simulating cookies in oven")
	for i in range(5):
		GameData.cookie_placed_in_oven()
		print("  Cookie " + str(i+1) + " placed in oven")
	
	# Simulate fully cooked cookies
	print("- Simulating fully cooked cookies")
	for i in range(3):
		GameData.cookie_removed_from_oven(1)  # 1 is the COOKED state
		print("  Cookie " + str(i+1) + " fully cooked")
	
	# Simulate burned cookies
	print("- Simulating burned cookies")
	for i in range(2):
		GameData.cookie_burned()
		print("  Cookie " + str(i+1) + " burned")
	
	# Simulate customers
	print("- Simulating customers")
	for i in range(4):
		GameData.update_customer_stats(i+1)
		print("  Customer " + str(i+1) + " spawned")
	
	# Simulate customers served
	print("- Simulating customers served")
	for i in range(3):
		GameData.update_customer_stats(3, true)  # Serve customer
		print("  Customer " + str(i+1) + " served")
	
	# Simulate game duration
	print("- Simulating game duration")
	GameData.stats["game_duration"] = 120.0  # 2 minutes
	print("  Game duration set to 120 seconds")

func print_stats(label: String):
	print("\n" + label + ":")
	print("- Score: " + str(GameData.score))
	print("- Total customers: " + str(GameData.stats["total_customers_served"]))
	print("- Cookies in oven: " + str(GameData.stats["cookies_in_oven"]))
	print("- Cookies fully cooked: " + str(GameData.stats["cookies_fully_cooked"]))
	print("- Cookies burned: " + str(GameData.stats["total_cookies_burned"]))
	print("- Game duration: " + str(GameData.stats["game_duration"]) + " seconds")
	print("")
