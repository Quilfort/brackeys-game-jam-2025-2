extends Node2D

# Customer scene to instantiate
@export var customer_scene: PackedScene

# Counter position marker
@export var counter_marker: NodePath
var counter_position_node: Node2D

# Spawn control
var time_until_next_spawn: float = 0.0
var can_spawn: bool = true
var max_customers: int = 1
var current_customers: int = 0

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
		
		# Set spawn position exactly at the spawner's position
		customer.global_position = global_position
		print("Customer spawned at position: ", customer.global_position)
		
		# Set the target position for the customer to move to
		if counter_position_node:
			customer.target_position = counter_position_node.global_position
			print("Customer target set to: ", customer.target_position)
		else:
			print("WARNING: No counter position set for customer!")
		
		# Connect signals to track when customer is removed
		customer.connect("tree_exited", Callable(self, "_on_customer_exited"))
		
		# Add to scene
		add_child(customer)
		current_customers += 1
		print("Current customer count: ", current_customers)
	else:
		print("ERROR: No customer scene assigned to spawner!")

func _on_customer_exited() -> void:
	current_customers -= 1
	print("Customer left. Current customer count: ", current_customers)

# Call this to pause/resume customer spawning
func set_spawning(enabled: bool) -> void:
	can_spawn = enabled
	print("Customer spawning set to: ", enabled)
