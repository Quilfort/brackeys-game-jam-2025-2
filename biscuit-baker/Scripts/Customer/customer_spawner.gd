class_name CustomerSpawner
extends Node2D

# Customer scene to instantiate
@export var customer_scene: PackedScene

# Counter position marker
@export var counter_middle_marker: NodePath
var counter_middle_position_node: Node2D

@export var counter_left_marker: NodePath
var counter_left_position_node: Node2D

@export var counter_right_marker: NodePath
var counter_right_position_node: Node2D

# Difficulty progression timings
var difficulty_stages = {
	1: {
		"max_customers": 2,
		"spawn_interval_min": 5.5,
		"spawn_interval_max": 7.5,
		"available_counters": ["middle"],
		"patience_time": 20.0  # Keep patience time consistent
	},
	2: {
		"max_customers": 3,
		"spawn_interval_min": 5.0,
		"spawn_interval_max": 7.0,
		"available_counters": ["middle", "random_side"],
		"patience_time": 20.0
	},
	3: {
		"max_customers": 6,
		"spawn_interval_min": 4.5,
		"spawn_interval_max": 6.5,
		"available_counters": ["middle", "left", "right"],
		"patience_time": 18.0
	},
	4: {
		"max_customers": 8,
		"spawn_interval_min": 4.0,
		"spawn_interval_max": 6.0,
		"available_counters": ["middle", "left", "right"],
		"patience_time": 18.0
	},
	5: {
		"max_customers": 8,
		"spawn_interval_min": 3.5,
		"spawn_interval_max": 5.5,
		"available_counters": ["middle", "left", "right"],
		"patience_time": 18.0
	},
	6: {
		"max_customers": 10,
		"spawn_interval_min": 3.2,
		"spawn_interval_max": 5.2,
		"available_counters": ["middle", "left", "right"],
		"patience_time": 15.0
	},
	7: {
		"max_customers": 10,
		"spawn_interval_min": 2.9,
		"spawn_interval_max": 4.9,
		"available_counters": ["middle", "left", "right"],
		"patience_time": 15.0
	},
	8: {
		"max_customers": 12,
		"spawn_interval_min": 2.6,
		"spawn_interval_max": 4.6,
		"available_counters": ["middle", "left", "right"],
		"patience_time": 15.0
	},
	9: {
		"max_customers": 13,
		"spawn_interval_min": 2.3,
		"spawn_interval_max": 4.3,
		"available_counters": ["middle", "left", "right"],
		"patience_time": 15.0
	},
	10: {
		"max_customers": 14,
		"spawn_interval_min": 2.0,
		"spawn_interval_max": 4.0,
		"available_counters": ["middle", "left", "right"],
		"patience_time": 15.0
	},
	11: {
		"max_customers": 15,
		"spawn_interval_min": 1.8,
		"spawn_interval_max": 3.8,
		"available_counters": ["middle", "left", "right"],
		"patience_time": 15.0
	},
	12: {
		"max_customers": 18,
		"spawn_interval_min": 1.6,
		"spawn_interval_max": 3.6,
		"available_counters": ["middle", "left", "right"],
		"patience_time": 15.0
	},
	13: {
		"max_customers": 18,
		"spawn_interval_min": 1.4,
		"spawn_interval_max": 3.4,
		"available_counters": ["middle", "left", "right"],
		"patience_time": 15.0
	},
	14: {
		"max_customers": 20,
		"spawn_interval_min": 1.2,
		"spawn_interval_max": 3.2,
		"available_counters": ["middle", "left", "right"],
		"patience_time": 13.0
	},
	15: {
		"max_customers": 22,
		"spawn_interval_min": 1.0,
		"spawn_interval_max": 3.0,
		"available_counters": ["middle", "left", "right"],
		"patience_time": 13.0
	},
	16: {
		"max_customers": 0,  # Will be calculated dynamically
		"spawn_interval_min": 0.8,
		"spawn_interval_max": 2.8,
		"available_counters": ["middle", "left", "right"],
		"patience_time": 10.0
	}
}

# Difficulty progression timing thresholds (in seconds)
var difficulty_thresholds = {
	1: 0.0,     # Start at level 1
	2: 20.0,    # After 20 seconds, move to level 2 (add one side counter, more customers)
	3: 60.0,    # After 60 seconds, move to level 3 (all counters)
	4: 120.0,   # After 120 seconds, move to level 4 (more customers)
	5: 180.0,   # After 180 seconds, move to level 5
	6: 240.0,   # After 240 seconds, move to level 6
	7: 300.0,   # After 300 seconds, move to level 7
	8: 360.0,   # After 360 seconds, move to level 8
	9: 420.0,   # After 420 seconds, move to level 9
	10: 480.0,  # After 480 seconds, move to level 10
	11: 540.0,  # After 540 seconds, move to level 11
	12: 600.0,  # After 600 seconds, move to level 12
	13: 660.0,  # After 660 seconds, move to level 13
	14: 720.0,  # After 720 seconds, move to level 14
	15: 780.0,  # After 780 seconds, move to level 15
	16: 840.0   # After 840 seconds, move to level 16 (auto-scaling difficulty)
}

# Spawn control
var time_until_next_spawn: float = 0.0
var can_spawn: bool = true
var max_customers: int = 2  # Start with just 2 customers
var current_customers: int = 0
var next_customer_id: int = 1
var current_difficulty: int = 1

# Queue management
var queue_distance: float = 25.0  # Distance between customers in queue
var customers_in_queue: Array = []  # Track customers in order

# Store which counter each customer is assigned to
var customer_counter_assignments = {}

# Store which side counter is available in level 2
var second_counter: String = "left"  # Will be randomized at start

func _ready() -> void:
	# Set initial spawn timer
	randomize()
	time_until_next_spawn = 1.0  # Start first spawn after 1 second
	print("CustomerSpawner ready at position: ", global_position)
	print("First customer will spawn in 1 second.")
	
	# Get the counter position markers if specified
	if not counter_middle_marker.is_empty():
		counter_middle_position_node = get_node(counter_middle_marker)
		print("Counter middle marker found at position: ", counter_middle_position_node.global_position)
	else:
		print("WARNING: No counter middle marker set!")
		
	if not counter_left_marker.is_empty():
		counter_left_position_node = get_node(counter_left_marker)
		print("Counter left marker found at position: ", counter_left_position_node.global_position)
	else:
		print("WARNING: No counter left marker set!")
		
	if not counter_right_marker.is_empty():
		counter_right_position_node = get_node(counter_right_marker)
		print("Counter right marker found at position: ", counter_right_position_node.global_position)
	else:
		print("WARNING: No counter right marker set!")
		
	if counter_middle_position_node == null and counter_left_position_node == null and counter_right_position_node == null:
		print("WARNING: No counter markers set! Customers won't know where to go.")
	
	# Randomly select which side counter will be the second one to open
	second_counter = "left" if randf() < 0.5 else "right"
	print("Second counter will be: " + second_counter)

func _process(delta: float) -> void:
	# Update game timer in GameData
	GameData.update_timer(delta)
	
	# Check for difficulty progression
	check_difficulty_progression()
	
	# Spawn customers based on current difficulty
	if can_spawn and current_customers < max_customers:
		time_until_next_spawn -= delta
		
		if time_until_next_spawn <= 0:
			print("Spawning customer now...")
			spawn_customer()
			
			# Get spawn interval based on current difficulty
			var current_stage = difficulty_stages[current_difficulty]
			time_until_next_spawn = randf_range(
				current_stage.spawn_interval_min, 
				current_stage.spawn_interval_max
			)
			print("Next customer will spawn in ", time_until_next_spawn, " seconds.")

# Check if we should progress to a new difficulty level
func check_difficulty_progression() -> void:
	var game_time = GameData.game_time
	
	# Check each threshold to see if we should increase difficulty
	for level in difficulty_thresholds.keys():
		if game_time >= difficulty_thresholds[level] and current_difficulty < level:
			set_difficulty(level)

# Set the current difficulty level
func set_difficulty(level: int) -> void:
	if level == current_difficulty:
		return
		
	current_difficulty = level
	GameData.set_difficulty(level)
	
	# Update spawner settings based on new difficulty
	var settings = difficulty_stages[level]
	max_customers = settings.max_customers
	
	if level == 16:
		max_customers = int(ceil(GameData.game_time / 60.0)) + 2
	
	print("Difficulty increased to level " + str(level))
	print("Max customers: " + str(max_customers))
	print("Available counters: " + str(settings.available_counters))

func spawn_customer() -> void:
	if customer_scene:
		var customer = customer_scene.instantiate()
		
		# Assign a unique ID
		customer.customer_id = next_customer_id
		next_customer_id += 1
		
		# Set spawn position exactly at the spawner's position
		customer.global_position = global_position
		print("Customer spawned at position: ", customer.global_position)
		
		# Select a counter position based on current difficulty
		var selected_position = select_counter_position_by_difficulty()
		var counter_node = selected_position.node
		var position_name = selected_position.name
		
		# Store the counter assignment for this customer
		customer_counter_assignments[customer] = counter_node
		
		# Set patience time based on difficulty
		customer.patience_time = difficulty_stages[current_difficulty].patience_time
		customer.patience_remaining = customer.patience_time
		
		# Check if there are any customers already at this counter
		var customers_at_this_counter = []
		for existing_customer in customers_in_queue:
			if customer_counter_assignments.get(existing_customer) == counter_node:
				customers_at_this_counter.append(existing_customer)
		
		# Determine position in queue
		if counter_node:
			# Store the counter position for later use (for all customers)
			customer.queue_position = counter_node.global_position
			
			# If no customers are at this counter, send directly to the counter
			if customers_at_this_counter.is_empty():
				customer.target_position = counter_node.global_position
				print("First customer going to " + position_name + " counter at: ", customer.target_position)
			else:
				# Otherwise, queue behind the last customer at this counter
				var last_customer = customers_at_this_counter.back()
				customer.target_position = calculate_queue_position(customers_at_this_counter.size(), counter_node)
				customer.customer_ahead = last_customer
				print("Customer queued for " + position_name + " counter at position: ", customer.target_position)
		else:
			print("WARNING: No counter position set for customer!")
		
		# Add to queue and track
		customers_in_queue.append(customer)
		
		# Connect signals to track when customer is removed
		customer.connect("tree_exited", Callable(self, "_on_customer_exited").bind(customer))
		
		# Add to scene
		add_child(customer)
		current_customers += 1
		print("Current customer count: ", current_customers)
		
		# Update statistics
		GameData.update_customer_stats(current_customers)
	else:
		print("ERROR: No customer scene assigned to spawner!")

# Select a counter position based on current difficulty level
func select_counter_position_by_difficulty() -> Dictionary:
	var available_positions = []
	var position_names = []
	
	# Get available counters for current difficulty
	var available_counters = difficulty_stages[current_difficulty].available_counters
	
	# Always add middle counter if it exists
	if "middle" in available_counters and counter_middle_position_node:
		available_positions.append(counter_middle_position_node)
		position_names.append("middle")
	
	# Add left counter if it's available in this difficulty
	if ("left" in available_counters or "random_side" in available_counters and second_counter == "left") and counter_left_position_node:
		available_positions.append(counter_left_position_node)
		position_names.append("left")
	
	# Add right counter if it's available in this difficulty
	if ("right" in available_counters or "random_side" in available_counters and second_counter == "right") and counter_right_position_node:
		available_positions.append(counter_right_position_node)
		position_names.append("right")
	
	if available_positions.is_empty():
		print("ERROR: No counter positions available for current difficulty!")
		return {"node": null, "name": "none"}
	
	# Select a random counter from available ones
	var random_index = randi() % available_positions.size()
	return {"node": available_positions[random_index], "name": position_names[random_index]}

# Calculate position in queue based on index
func calculate_queue_position(queue_index: int, counter_node: Node2D) -> Vector2:
	if counter_node:
		# Create a queue going down from the counter (south direction)
		var counter_pos = counter_node.global_position
		var queue_pos = Vector2(counter_pos.x, counter_pos.y + (queue_distance * queue_index))
		return queue_pos
	return global_position

func _on_customer_exited(customer: Node) -> void:
	current_customers -= 1
	
	# Check if customer was satisfied (for statistics)
	if customer.current_state == customer.CustomerState.SATISFIED:
		GameData.update_customer_stats(current_customers, true)
	else:
		GameData.update_customer_stats(current_customers, false)
	
	# Remove from queue
	var index = customers_in_queue.find(customer)
	if index >= 0:
		customers_in_queue.remove_at(index)
		
		# Remove counter assignment
		customer_counter_assignments.erase(customer)
		
		# Update queue positions for remaining customers
		update_queue()
		
	print("Customer left. Current customer count: ", current_customers)

# Select a random counter position node (legacy method, kept for compatibility)
func select_random_counter_position() -> Dictionary:
	return select_counter_position_by_difficulty()

# Update queue positions when a customer leaves
func update_queue() -> void:
	if customers_in_queue.is_empty():
		return
		
	# Group customers by their counter assignments
	var counter_groups = {}
	
	for customer in customers_in_queue:
		var counter_node = customer_counter_assignments.get(customer)
		if counter_node:
			if not counter_groups.has(counter_node):
				counter_groups[counter_node] = []
			counter_groups[counter_node].append(customer)
	
	# Process each counter group separately
	for counter_node in counter_groups.keys():
		var counter_customers = counter_groups[counter_node]
		
		# Sort customers by their position in the main queue
		counter_customers.sort_custom(func(a, b): return customers_in_queue.find(a) < customers_in_queue.find(b))
		
		# First customer in this counter's group goes to counter if they're not already there
		if not counter_customers.is_empty():
			var first_customer = counter_customers[0]
			if first_customer.current_state == first_customer.CustomerState.QUEUED or first_customer.current_state == first_customer.CustomerState.ENTERING:
				first_customer.target_position = counter_node.global_position
				first_customer.customer_ahead = null
				first_customer.set_state(first_customer.CustomerState.ENTERING)
				
				# Get counter position name for logging
				var position_name = "unknown"
				if counter_node == counter_left_position_node:
					position_name = "left"
				elif counter_node == counter_middle_position_node:
					position_name = "middle"
				elif counter_node == counter_right_position_node:
					position_name = "right"
				
				print("Moving first customer in queue to " + position_name + " counter")
		
		# Update references for remaining customers in this counter's group
		for i in range(1, counter_customers.size()):
			var customer = counter_customers[i]
			var previous_customer = counter_customers[i-1]
			
			# Update customer_ahead reference
			customer.customer_ahead = previous_customer
			
			# Calculate new position in queue
			var new_position = calculate_queue_position(i, counter_node)
			
			# Only update position if it's different
			if customer.target_position != new_position:
				customer.target_position = new_position
				if customer.current_state == customer.CustomerState.QUEUED:
					customer.set_state(customer.CustomerState.ENTERING)
				print("Moving customer forward in queue")

# Call this to pause/resume customer spawning
func set_spawning(enabled: bool) -> void:
	can_spawn = enabled
	print("Customer spawning set to: ", enabled)
