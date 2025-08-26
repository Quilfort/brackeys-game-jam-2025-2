class_name CustomerSpawner
extends Node2D

# Customer scene to instantiate
@export var customer_scene: PackedScene

# Counter position marker
@export var counter_marker: NodePath
var counter_position_node: Node2D

# Spawn control
var time_until_next_spawn: float = 0.0
var can_spawn: bool = true
var max_customers: int = 4
var current_customers: int = 0
var next_customer_id: int = 1

# Queue management
var queue_distance: float = 25.0  # Distance between customers in queue
var customers_in_queue: Array = []  # Track customers in order

func _ready() -> void:
	# Set initial spawn timer
	randomize()
	time_until_next_spawn = 1.0  # Start first spawn after 1 second
	print("CustomerSpawner ready at position: ", global_position)
	print("First customer will spawn in 1 second.")
	
	# Get the counter position marker if specified
	if not counter_marker.is_empty():
		counter_position_node = get_node(counter_marker)
		print("Counter marker found at position: ", counter_position_node.global_position)
	else:
		print("WARNING: No counter marker set! Customers won't know where to go.")

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
		
		# Determine position in queue
		if counter_position_node:
			# Store the counter position for later use (for all customers)
			customer.queue_position = counter_position_node.global_position
			
			# If this is the first customer, send them directly to the counter
			if customers_in_queue.is_empty():
				customer.target_position = counter_position_node.global_position
				print("First customer going to counter at: ", customer.target_position)
			else:
				# Otherwise, queue behind the last customer
				var last_customer = customers_in_queue.back()
				customer.target_position = calculate_queue_position(customers_in_queue.size())
				customer.customer_ahead = last_customer
				print("Customer queued at position: ", customer.target_position)
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
func calculate_queue_position(queue_index: int) -> Vector2:
	if counter_position_node:
		# Create a queue going down from the counter (south direction)
		var counter_pos = counter_position_node.global_position
		var queue_pos = Vector2(counter_pos.x, counter_pos.y + (queue_distance * queue_index))
		return queue_pos
	return global_position

func _on_customer_exited(customer: Node) -> void:
	current_customers -= 1
	
	# Remove from queue
	var index = customers_in_queue.find(customer)
	if index >= 0:
		customers_in_queue.remove_at(index)
		
		# Update queue positions for remaining customers
		update_queue()
		
	print("Customer left. Current customer count: ", current_customers)

# Update queue positions when a customer leaves
func update_queue() -> void:
	if customers_in_queue.is_empty():
		return
		
	# First customer goes to counter if they're not already there
	var first_customer = customers_in_queue[0]
	if first_customer.current_state == first_customer.CustomerState.QUEUED:
		first_customer.target_position = counter_position_node.global_position
		first_customer.customer_ahead = null
		first_customer.set_state(first_customer.CustomerState.ENTERING)
		print("Moving first customer in queue to counter")
	
	# Update references for remaining customers
	for i in range(1, customers_in_queue.size()):
		var customer = customers_in_queue[i]
		customer.customer_ahead = customers_in_queue[i-1]
		
		# Optionally, update their target positions too
		customer.target_position = calculate_queue_position(i)
		if customer.current_state == customer.CustomerState.QUEUED:
			customer.set_state(customer.CustomerState.ENTERING)
			print("Moving customer in position " + str(i) + " forward in queue")

# Call this to pause/resume customer spawning
func set_spawning(enabled: bool) -> void:
	can_spawn = enabled
	print("Customer spawning set to: ", enabled)
