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


# Spawn control
var time_until_next_spawn: float = 0.0
var can_spawn: bool = true
var max_customers: int = 4
var current_customers: int = 0
var next_customer_id: int = 1

# Queue management
var queue_distance: float = 25.0  # Distance between customers in queue
var customers_in_queue: Array = []  # Track customers in order

# Store which counter each customer is assigned to
var customer_counter_assignments = {}

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

func _process(delta: float) -> void:
	if can_spawn and current_customers < max_customers:
		time_until_next_spawn -= delta
		
		if time_until_next_spawn <= 0:
			print("Spawning customer now...")
			spawn_customer()
			time_until_next_spawn = randf_range(2.0, 5.0)
			print("Next customer will spawn in ", time_until_next_spawn, " seconds.")

func spawn_customer() -> void:
	if customer_scene:
		var customer = customer_scene.instantiate()
		
		# Assign a unique ID
		customer.customer_id = next_customer_id
		next_customer_id += 1
		
		# Set spawn position exactly at the spawner's position
		customer.global_position = global_position
		print("Customer spawned at position: ", customer.global_position)
		
		# Randomly select a counter position
		var selected_position = select_random_counter_position()
		var counter_node = selected_position.node
		var position_name = selected_position.name
		
		# Store the counter assignment for this customer
		customer_counter_assignments[customer] = counter_node
		
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
	else:
		print("ERROR: No customer scene assigned to spawner!")

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
	
	# Remove from queue
	var index = customers_in_queue.find(customer)
	if index >= 0:
		customers_in_queue.remove_at(index)
		
		# Remove counter assignment
		customer_counter_assignments.erase(customer)
		
		# Update queue positions for remaining customers
		update_queue()
		
	print("Customer left. Current customer count: ", current_customers)

# Select a random counter position node
func select_random_counter_position() -> Dictionary:
	var available_positions = []
	var position_names = []
	
	if counter_left_position_node:
		available_positions.append(counter_left_position_node)
		position_names.append("left")
	
	if counter_middle_position_node:
		available_positions.append(counter_middle_position_node)
		position_names.append("middle")
		
	if counter_right_position_node:
		available_positions.append(counter_right_position_node)
		position_names.append("right")
	
	if available_positions.is_empty():
		print("ERROR: No counter positions available!")
		return {"node": null, "name": "none"}
	
	var random_index = randi() % available_positions.size()
	return {"node": available_positions[random_index], "name": position_names[random_index]}

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
