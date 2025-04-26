# enemy.gd
extends CharacterBody2D

@export var health: int = 3 # How many hits the enemy can take
@export var speed: float = 150.0
@export var detection_range: float = 400.0
@export var minimum_distance: float = 35.0 # Stop moving towards player if closer than this

var player = null # Variable to hold a reference to the player node

func _physics_process(delta: float) -> void:
	# Try to find the player node using the "player" group
	# Note: This search could be optimized if performance becomes an issue later
	#       (e.g., search only once in _ready or use signals/Area2D detection)
	player = get_tree().get_first_node_in_group("player")

	# If player doesn't exist (e.g., not in the scene yet), stop moving.
	if player == null:
		velocity = Vector2.ZERO
		move_and_slide()
		# print("DEBUG: Enemy cannot find player.") # Optional debug
		return

	# Calculate distance to player
	var distance_to_player = global_position.distance_to(player.global_position)
	# print("DEBUG: Distance to player: ", distance_to_player) # Optional debug

	# Check if player is within detection range
	if distance_to_player < detection_range:
		# --- ADD THIS CHECK ---
		# Only move if player is not too close
		if distance_to_player > minimum_distance:
			# Calculate direction towards player
			var direction = (player.global_position - global_position).normalized()
			# Set velocity towards player
			velocity = direction * speed
			# print("DEBUG: Enemy moving towards player. Velocity: ", velocity) # Optional debug
		else:
			# Player is too close, stop pushing
			velocity = Vector2.ZERO
			# print("DEBUG: Player too close, stopping.") # Optional debug
		# --- END ADDED CHECK ---
	else:
		# Player is too far, stop moving
		velocity = Vector2.ZERO
		# print("DEBUG: Player out of range.") # Optional debug

	# Apply movement
	move_and_slide()

func take_damage(amount: int) -> void:
	health -= amount
	print("DEBUG: Enemy ", self.name, " took ", amount, " damage. Health remaining: ", health) # Debug output
	if health <= 0:
		print("DEBUG: Enemy ", self.name, " defeated!")
		queue_free() # Remove the enemy from the scene
