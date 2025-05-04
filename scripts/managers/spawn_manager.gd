# spawn_manager.gd
# Handles the time-based spawning of enemies based on a defined timeline.
# Mimics horde-style spawning similar to Vampire Survivors.
# Author: [Your Name]
# Date: [Current Date]

extends Node

# --- Enemy Scenes (Preload) ---
const ENEMY_BASIC = preload("res://scenes/enemies/enemy.tscn")

# --- Configuration ---
const MIN_SPAWN_DISTANCE_FROM_PLAYER = 250.0 # Minimum distance enemies should spawn from the player
const MAX_SPAWN_ATTEMPTS = 10 # How many times to try finding a valid spawn position

# Defines the sequence of enemy spawns based on game time.
# Format: [ { "time_start": seconds, "enemy_scene": PackedScene, "interval": seconds, "quantity": num }, ... ]
var spawn_timeline = [
	# Start slow (but slightly faster now)
	{ "time_start": 0,   "enemy_scene": ENEMY_BASIC, "interval": 3.5, "quantity": 1 },
	# Increase rate slightly (15s)
	{ "time_start": 15,  "enemy_scene": ENEMY_BASIC, "interval": 4.0, "quantity": 1 },
	# Start spawning pairs, faster (30s)
	{ "time_start": 30,  "enemy_scene": ENEMY_BASIC, "interval": 3.0, "quantity": 2 },
	# Increase quantity further (45s)
	{ "time_start": 45,  "enemy_scene": ENEMY_BASIC, "interval": 3.0, "quantity": 3 },
	# Faster interval (60s)
	{ "time_start": 60, "enemy_scene": ENEMY_BASIC, "interval": 2.0, "quantity": 3 },
	# More enemies (75s)
	{ "time_start": 75, "enemy_scene": ENEMY_BASIC, "interval": 2.0, "quantity": 4 },
	# Even faster (90s)
	{ "time_start": 90, "enemy_scene": ENEMY_BASIC, "interval": 1.5, "quantity": 4 },
	# Getting crowded (105s)
	{ "time_start": 105, "enemy_scene": ENEMY_BASIC, "interval": 1.5, "quantity": 5 },
	# Max pace (for now) (120s)
	{ "time_start": 120, "enemy_scene": ENEMY_BASIC, "interval": 1.0, "quantity": 5 },
	# Example for adding a new enemy later (Keep commented out)
	# { "time_start": 250, "enemy_scene": preload("res://scenes/enemies/enemy_strong.tscn"), "interval": 10.0, "quantity": 1 }
]

# --- Internal State ---
var current_game_time: float = 0.0
var active_spawners: Array = [] # Tracks active spawn rules and their timers
var next_timeline_index_to_check: int = 0 # Index for checking spawn_timeline

# Node references
@onready var player = get_tree().get_first_node_in_group("player")
@onready var camera = get_viewport().get_camera_2d() # Assuming a single Camera2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Validate essential references
	if not is_instance_valid(player):
		printerr("SpawnManager Error: Player node not found!")
		set_process(false) # Disable processing if player missing
		return
	if camera == null:
		printerr("SpawnManager Error: Camera2D not found in viewport!")
		set_process(false) # Disable processing if camera missing
		return

	print("DEBUG: SpawnManager initialized.")
	# (No specific initialization needed for this approach yet) - Removed TODO

# Called every frame. delta is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	current_game_time += delta

	# 1. Check for and activate NEW spawn rules from the timeline
	while next_timeline_index_to_check < spawn_timeline.size():
		var rule = spawn_timeline[next_timeline_index_to_check]
		if current_game_time >= rule.time_start:
			# Activate this rule: Add its info and a cooldown timer to active_spawners
			active_spawners.append({
				"enemy_scene": rule.enemy_scene,
				"interval": rule.interval,
				"quantity": rule.quantity,
				"cooldown": 0.0 # Start cooldown timer (will spawn on first check if interval > 0)
			})
			print("DEBUG: Activated spawn rule at time %.2f: %s" % [current_game_time, rule])
			next_timeline_index_to_check += 1 # Move to check the next rule in the timeline
		else:
			# Stop checking the timeline for this frame once we hit a rule not yet ready
			break

	# 2. Process all ACTIVE spawners (check intervals and spawn)
	for spawner in active_spawners:
		spawner.cooldown -= delta
		if spawner.cooldown <= 0:
			# Cooldown finished, time to spawn!
			# Use the spawner dictionary directly, ensuring keys match
			_spawn_enemy(spawner["enemy_scene"], spawner["quantity"])
			# Reset the cooldown for the next spawn
			spawner.cooldown = spawner["interval"]

# --- Spawning Logic ---
func _spawn_enemy(enemy_scene: PackedScene, quantity: int) -> void:
	if enemy_scene == null:
		printerr("SpawnManager Error: Tried to spawn null enemy scene!")
		return
	
	if not is_instance_valid(player):
		printerr("SpawnManager Error: Player invalid while trying to spawn enemy!")
		return

	for i in range(quantity):
		var valid_spawn_position = Vector2.INF # Placeholder for a valid position
		
		# Try to find a spawn position away from the player
		for attempt in range(MAX_SPAWN_ATTEMPTS):
			var spawn_position = _get_off_screen_spawn_position()
			
			# Check distance from player (using squared distance for efficiency)
			if spawn_position.distance_squared_to(player.global_position) > MIN_SPAWN_DISTANCE_FROM_PLAYER * MIN_SPAWN_DISTANCE_FROM_PLAYER:
				valid_spawn_position = spawn_position
				break # Found a valid position, exit the attempt loop
				
		# Check if a valid position was found
		if valid_spawn_position != Vector2.INF:
			var enemy_instance = enemy_scene.instantiate()
			# TODO: Add the instance to the correct place in the scene tree (e.g., get_tree().root or a dedicated container)
			get_tree().root.add_child(enemy_instance) # Example: adding to root
			enemy_instance.global_position = valid_spawn_position

			# Optional: Apply difficulty scaling based on current_game_time if needed
			# if enemy_instance.has_method("apply_scaling"):
			#     enemy_instance.apply_scaling(current_game_time)

			# print("DEBUG: Spawned enemy at ", valid_spawn_position) # Commented out per-spawn print
		else:
			# If no valid position found after MAX_SPAWN_ATTEMPTS, print a warning
			# (Could potentially still spawn at the last attempted position, or skip spawning this one)
			print("WARNING: SpawnManager could not find a suitable spawn position away from the player after %d attempts." % MAX_SPAWN_ATTEMPTS)


# Calculates a random spawn position just outside the camera's view
func _get_off_screen_spawn_position() -> Vector2:
	if camera == null: return Vector2.ZERO # Failsafe

	var viewport_rect = camera.get_viewport_rect()
	var spawn_buffer = 50.0 # Pixels outside the screen edge

	# Expand the rect slightly
	var spawn_rect = viewport_rect.grow(spawn_buffer)

	# Choose a random edge (0: top, 1: bottom, 2: left, 3: right)
	var edge = randi() % 4
	var spawn_pos = Vector2.ZERO

	match edge:
		0: # Top edge
			spawn_pos.x = randf_range(spawn_rect.position.x, spawn_rect.position.x + spawn_rect.size.x)
			spawn_pos.y = spawn_rect.position.y - spawn_buffer
		1: # Bottom edge
			spawn_pos.x = randf_range(spawn_rect.position.x, spawn_rect.position.x + spawn_rect.size.x)
			spawn_pos.y = spawn_rect.position.y + spawn_rect.size.y + spawn_buffer
		2: # Left edge
			spawn_pos.x = spawn_rect.position.x - spawn_buffer
			spawn_pos.y = randf_range(spawn_rect.position.y, spawn_rect.position.y + spawn_rect.size.y)
		3: # Right edge
			spawn_pos.x = spawn_rect.position.x + spawn_rect.size.x + spawn_buffer
			spawn_pos.y = randf_range(spawn_rect.position.y, spawn_rect.position.y + spawn_rect.size.y)

	# Convert position from viewport coordinates to global coordinates
	return camera.get_global_transform() * spawn_pos

# Calculates a random spawn position outside the camera view
# TODO: Refine this to potentially use NavigationServer pathfinding checks?
func _get_random_off_screen_position() -> Vector2:
	if camera == null:
		print("ERROR: Camera not found in SpawnManager!")
		return Vector2.ZERO

	var viewport_rect = camera.get_viewport_rect()
	var spawn_margin = 50 # How far outside the view to spawn

	# Choose a random edge (0: top, 1: bottom, 2: left, 3: right)
	var edge = randi() % 4
	var spawn_pos = Vector2.ZERO

	match edge:
		0: # Top
			spawn_pos.x = randf_range(viewport_rect.position.x - spawn_margin, viewport_rect.end.x + spawn_margin)
			spawn_pos.y = viewport_rect.position.y - spawn_margin
		1: # Bottom
			spawn_pos.x = randf_range(viewport_rect.position.x - spawn_margin, viewport_rect.end.x + spawn_margin)
			spawn_pos.y = viewport_rect.end.y + spawn_margin
		2: # Left
			spawn_pos.x = viewport_rect.position.x - spawn_margin
			spawn_pos.y = randf_range(viewport_rect.position.y - spawn_margin, viewport_rect.end.y + spawn_margin)
		3: # Right
			spawn_pos.x = viewport_rect.end.x + spawn_margin
			spawn_pos.y = randf_range(viewport_rect.position.y - spawn_margin, viewport_rect.end.y + spawn_margin)

	return camera.get_global_transform().origin + spawn_pos # Convert to global coordinates
