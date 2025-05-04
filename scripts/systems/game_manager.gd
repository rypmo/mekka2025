# game_manager.gd
# Manages game state, events, and global game logic.
# This script serves as the central manager for game systems and state.
# Author: [Your Name]
# Date: [Current Date]

extends Node

# Game state enum
enum GameState {
	MENU,
	PLAYING,
	PAUSED,
	GAME_OVER
}

# Current game state
var current_state: int = GameState.MENU

# Game statistics
var score: int = 0
var enemies_defeated: int = 0
var time_played: float = 0.0
var wave: int = 0
var difficulty: float = 1.0

# Enemy spawning
@export var enemy_scene: PackedScene # Reference to the enemy scene
@export var spawn_interval: float = 2.0 # Time between enemy spawns
@export var max_enemies: int = 10 # Maximum number of enemies on screen
@export var spawn_radius: float = 500.0 # Distance from player to spawn enemies
@export var difficulty_increase_rate: float = 0.1 # How much difficulty increases per wave
@export var enemies_per_wave: int = 5 # Base number of enemies per wave

# Internal state variables
var spawn_timer: float = 0.0
var wave_timer: float = 0.0
var wave_duration: float = 30.0 # Time per wave in seconds
var enemies_remaining: int = 0
var is_wave_active: bool = false

# Signals
signal game_state_changed(new_state: int)
signal score_changed(new_score: int)
signal enemies_defeated_changed(new_count: int)
signal wave_started(wave_number: int)
signal wave_ended(wave_number: int)
signal difficulty_changed(new_difficulty: float)

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	# Initialize game systems
	randomize()  # Seed the random number generator
	
	# Connect to input events
	set_process_input(true)
	
	# Add to game_manager group for easy reference
	add_to_group("game_manager")
	
	print("DEBUG: Game Manager initialized")

# Called every frame
func _process(delta: float) -> void:
	# Update game time if playing
	if current_state == GameState.PLAYING:
		time_played += delta
		
		# Handle wave timing
		if is_wave_active:
			wave_timer -= delta
			if wave_timer <= 0:
				_end_wave()
		
		# Handle enemy spawning
		if is_wave_active and enemies_remaining > 0:
			spawn_timer -= delta
			if spawn_timer <= 0:
				_try_spawn_enemy()
				spawn_timer = spawn_interval

# Called when input is received
func _input(event: InputEvent) -> void:
	# Handle pause input
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

# Changes the game state
func change_state(new_state: int) -> void:
	current_state = new_state
	emit_signal("game_state_changed", new_state)
	
	match new_state:
		GameState.MENU:
			print("DEBUG: Game state changed to MENU")
		GameState.PLAYING:
			print("DEBUG: Game state changed to PLAYING")
		GameState.PAUSED:
			print("DEBUG: Game state changed to PAUSED")
		GameState.GAME_OVER:
			print("DEBUG: Game state changed to GAME_OVER")

# Toggles the pause state
func toggle_pause() -> void:
	if current_state == GameState.PLAYING:
		change_state(GameState.PAUSED)
		get_tree().paused = true
	elif current_state == GameState.PAUSED:
		change_state(GameState.PLAYING)
		get_tree().paused = false

# Starts a new game
func start_game() -> void:
	# Reset game statistics
	score = 0
	enemies_defeated = 0
	time_played = 0.0
	wave = 0
	difficulty = 1.0
	
	# Change to playing state
	change_state(GameState.PLAYING)
	
	# Start first wave
	_start_wave()
	
	print("DEBUG: Game started")

# Ends the current game
func end_game() -> void:
	change_state(GameState.GAME_OVER)
	print("DEBUG: Game ended. Final score: ", score)

# Adds points to the score
func add_score(points: int) -> void:
	score += points
	emit_signal("score_changed", score)
	print("DEBUG: Score increased by ", points, ". New score: ", score)

# Increments the enemies defeated counter
func increment_enemies_defeated() -> void:
	enemies_defeated += 1
	emit_signal("enemies_defeated_changed", enemies_defeated)
	print("DEBUG: Enemy defeated. Total: ", enemies_defeated)
	
	# Check if wave is complete
	if is_wave_active and enemies_remaining > 0:
		enemies_remaining -= 1
		if enemies_remaining <= 0:
			_end_wave()

# Starts a new wave
func _start_wave() -> void:
	wave += 1
	is_wave_active = true
	wave_timer = wave_duration
	
	# Calculate enemies for this wave
	enemies_remaining = enemies_per_wave + (wave - 1) * 2
	
	# Increase difficulty
	difficulty += difficulty_increase_rate
	emit_signal("difficulty_changed", difficulty)
	
	# Reset spawn timer
	spawn_timer = spawn_interval
	
	emit_signal("wave_started", wave)
	print("DEBUG: Wave ", wave, " started. Enemies: ", enemies_remaining, ", Difficulty: ", difficulty)

# Ends the current wave
func _end_wave() -> void:
	is_wave_active = false
	emit_signal("wave_ended", wave)
	print("DEBUG: Wave ", wave, " ended")
	
	# Start next wave after a delay
	await get_tree().create_timer(3.0).timeout
	_start_wave()

# Attempts to spawn an enemy
func _try_spawn_enemy() -> void:
	# Check if we've reached the maximum number of enemies
	var current_enemies = get_tree().get_nodes_in_group("enemies").size()
	if current_enemies >= max_enemies:
		print("DEBUG: Maximum enemies reached, skipping spawn")
		return
	
	# Get player position
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		print("ERROR: Cannot find player for enemy spawning")
		return
	
	# Spawn enemy at random position around player
	var spawn_pos = _get_random_spawn_position(player.global_position)
	_spawn_enemy(spawn_pos)

# Gets a random spawn position around the player
func _get_random_spawn_position(player_pos: Vector2) -> Vector2:
	# Use the utility function if available
	if has_node("/root/GameUtils"):
		@warning_ignore("static_called_on_instance")
		return GameUtils.get_random_position_in_radius(player_pos, spawn_radius)
	
	# Fallback implementation
	var random_angle = randf() * TAU
	var random_distance = randf() * spawn_radius
	var x = player_pos.x + random_distance * cos(random_angle)
	var y = player_pos.y + random_distance * sin(random_angle)
	return Vector2(x, y)

# Spawns an enemy at the specified position
func _spawn_enemy(position: Vector2) -> void:
	if enemy_scene == null:
		print("ERROR: Enemy scene not set on Game Manager!")
		return
	
	# Instance the enemy
	var enemy = enemy_scene.instantiate()
	
	# Check if instantiation worked
	if enemy == null:
		print("ERROR: Failed to instantiate enemy scene.")
		return
	
	# Add to the scene tree
	get_tree().root.add_child(enemy)
	
	# Position the enemy
	enemy.global_position = position
	
	# Apply difficulty scaling
	if enemy.has_method("scale_for_difficulty"):
		enemy.scale_for_difficulty(difficulty)
	
	print("DEBUG: Enemy spawned at ", position) 
