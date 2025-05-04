# enemy.gd
# Basic enemy that follows and attacks the player.
# This script handles enemy movement, player detection, and health management.
# Author: [Your Name]
# Date: [Current Date]

extends CharacterBody2D

# Enemy properties
@export var max_health: float = 100.0
@export var speed: float = 100.0 # Increased default speed
@export var detection_range: float = 300.0 # NOTE: Currently unused for movement/attack trigger
@export var minimum_distance: float = 40.0 # Stop moving towards player if closer than this
#@export var attack_range: float = 130.0 # No longer used for attack trigger - REMOVED
@export var attack_damage: float = 10.0
@export var attack_cooldown: float = 1.0 # Time between attacks
@export var score_value: int = 100 # Points awarded when defeated
@export var knockback_resistance: float = 0.5 # 0 = no resistance, 1 = full resistance

# Difficulty Scaling Modifiers
@export var health_scale_per_wave: float = 1.1
@export var speed_scale_per_wave: float = 1.05
@export var damage_scale_per_wave: float = 1.1

# Internal state variables
var current_health: float
var current_speed: float # Speed adjusted for scaling
var current_damage: float # Damage adjusted for scaling
var player = null # Variable to hold a reference to the player node
var attack_timer: float = 0.0 # Timer for attack cooldown
var can_attack: bool = true
var is_knockback_immune: bool = false
var knockback_immunity_timer: float = 0.0

# Node references
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var attack_hitbox: Area2D = $AttackHitbox # Reference to the new hitbox

signal died(enemy_instance: Node2D, points: int)
signal health_changed(new_health: float, max_health: float)

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	# Initialize health and scaled stats
	current_health = max_health
	current_speed = speed # Use exported speed
	current_damage = attack_damage
	emit_signal("health_changed", current_health, max_health)
	
	# Add to enemies group for easy reference
	add_to_group("enemies")
	
	# Initialize attack timer
	attack_timer = attack_cooldown
	
	# player = get_tree().get_first_node_in_group("player") # REMOVED - Deferred to _physics_process
	print("DEBUG: Enemy initialized with health: ", current_health)

	# Validate NavigationAgent2D reference
	if not navigation_agent:
		printerr("Enemy Error: NavigationAgent2D node not found or not assigned!")
		return
	
	# --- Connect signals ---
	# Connect the velocity_computed signal for navigation movement
	if not navigation_agent.velocity_computed.is_connected(_on_velocity_computed):
		navigation_agent.velocity_computed.connect(_on_velocity_computed)

	# Validate AttackHitbox reference
	if not attack_hitbox:
		printerr("Enemy Error: AttackHitbox node not found or not assigned!")
		return
	# Connect the area_entered signal for attack detection
	if not attack_hitbox.area_entered.is_connected(_on_attack_hitbox_area_entered):
		attack_hitbox.area_entered.connect(_on_attack_hitbox_area_entered)


	# Explicitly set agent's max_speed to match our script speed
	navigation_agent.max_speed = current_speed 
	# print("DEBUG: Set NavigationAgent max_speed to: ", navigation_agent.max_speed) # REMOVED - Verified

	# Set initial target to self if player not found yet
	# This check is now less critical as _physics_process will handle finding player
	# if not is_instance_valid(player):
	# 	 navigation_agent.target_position = global_position
	navigation_agent.target_position = global_position # Default target initially

# Called every physics frame
func _physics_process(delta: float) -> void:
	# Early exit if agent isn't assigned 
	if not navigation_agent:
		return
		
	# Update timers (including attack cooldown)
	_update_timers(delta)
	
	# --- Knockback Handling ---
	if is_knockback_immune:
		move_and_slide() # Apply knockback velocity
		return # Skip the rest of the logic
	
	# --- Player Finding --- (Still need player ref for navigation)
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		if not is_instance_valid(player):
			# Player still not found, log error and stop processing (or wait)
			if Engine.get_physics_frames() % 120 == 0: # Print error less frequently
				printerr("Enemy Error: Player node not found in group 'player'!")
			navigation_agent.set_velocity(Vector2.ZERO)
			velocity = Vector2.ZERO
			return # Stop processing until player is found
		# else: # Optional: Print when player is first found
		# 	 print("DEBUG: Enemy found player: ", player.name)
	
	# --- Distance Calculation for Movement --- (Still needed for minimum_distance)
	var distance_to_player = global_position.distance_to(player.global_position)
	
	# --- ATTACK LOGIC REMOVED FROM HERE --- 
	# Attack logic is now handled by the _on_attack_hitbox_area_entered signal handler
	
	# --- Debug Info (Optional) ---
	# if Engine.get_physics_frames() % 60 == 0: # REMOVED old debug print check
	# 	 pass # Placeholder
	
	# --- Navigation Logic --- 
	# Set the target for the agent
	navigation_agent.target_position = player.global_position
		
	# --- Calculate Desired Velocity --- (Stop if too close)
	var desired_velocity = Vector2.ZERO
	if distance_to_player > minimum_distance:
		var direction_to_target = global_position.direction_to(navigation_agent.target_position)
		desired_velocity = direction_to_target * current_speed
	# Else: If close enough, desired velocity remains ZERO, agent should stop.

	# Set the agent's desired velocity. 
	navigation_agent.set_velocity(desired_velocity)

# Updates all timers
func _update_timers(delta: float) -> void:
	# Update attack cooldown
	if !can_attack:
		attack_timer -= delta
		if attack_timer <= 0:
			can_attack = true
			print("DEBUG: Enemy can attack again (cooldown finished)") # DEBUG
	
	# Update knockback immunity
	if is_knockback_immune:
		knockback_immunity_timer -= delta
		if knockback_immunity_timer <= 0:
			is_knockback_immune = false

# --- Signal Handler for Attack Hitbox --- 
func _on_attack_hitbox_area_entered(area: Area2D) -> void:
	# Check if the overlapping area is the player's hurtbox and if we can attack
	if area.is_in_group("player_hurtbox") and can_attack:
		print("DEBUG: AttackHitbox collided with PlayerHurtbox!")
		_attack_player() # Call the existing attack function
	#else: # Optional: Debugging if collision happens but attack doesn't
	#	if not area.is_in_group("player_hurtbox"):
	#		print("DEBUG: AttackHitbox hit something NOT in player_hurtbox group: ", area)
	#	elif not can_attack:
	#		print("DEBUG: AttackHitbox hit player_hurtbox but attack is on cooldown.")

# Called when the enemy takes damage
func take_damage(amount: float) -> void:
	current_health -= amount
	emit_signal("health_changed", current_health, max_health)
	print("DEBUG: Enemy took ", amount, " damage. Health: ", current_health)
	
	if current_health <= 0:
		die()

# Handles enemy death
func die() -> void:
	print("DEBUG: Enemy defeated")
	
	# Award score to game manager
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager and game_manager.has_method("add_score"):
		game_manager.add_score(score_value)
	
	# Increment enemies defeated counter
	if game_manager and game_manager.has_method("increment_enemies_defeated"):
		game_manager.increment_enemies_defeated()
	
	# Remove the enemy from the scene
	# Disable agent and collision before freeing
	if navigation_agent:
		navigation_agent.set_velocity(Vector2.ZERO)
		navigation_agent.avoidance_enabled = false # Can be set directly
		
	var collision_shape = $CollisionShape2D
	if collision_shape:
		collision_shape.set_deferred("disabled", true)
		
	# Also disable the hitbox area monitoring using deferred calls
	if attack_hitbox:
		attack_hitbox.set_deferred("monitoring", false) 
		attack_hitbox.set_deferred("monitorable", false)
	
	queue_free()

# Attacks the player (Now called primarily by hitbox signal)
func _attack_player() -> void:
	# Don't attack if player is invalid or already dead/destroyed
	if not is_instance_valid(player) or player.current_health <= 0:
		# print("DEBUG: Attack skipped, player invalid or dead.") # Optional debug
		return 
	
	print("DEBUG: _attack_player called (triggered by Hitbox)") # Clarify trigger
	
	# Player validity already checked above, but doesn't hurt to be safe
	if not is_instance_valid(player):
		print("DEBUG: Player instance INVALID inside _attack_player!") # Should not happen now
		return
	
	# print("DEBUG: Player instance is valid inside _attack_player.") # Redundant now
	
	# Double-check player has take_damage method
	if not player.has_method("take_damage"):
		print("DEBUG: Player object does NOT have take_damage method.")
		return
	
	# --- REMOVE DISTANCE CHECK --- 
	# The overlap IS the check now.
	# REMOVED OLD CODE BLOCK
	
	# Apply damage to player
	var damage_to_deal: int = int(current_damage)
	player.take_damage(damage_to_deal)
	print("DEBUG: Enemy attacked player for %d damage (sent as int via Hitbox)" % damage_to_deal)
	
	# Start attack cooldown
	can_attack = false
	attack_timer = attack_cooldown

# Applies knockback to the enemy
func apply_knockback(force: Vector2) -> void:
	if !is_knockback_immune:
		# Apply knockback resistance
		var kb_velocity = force * (1.0 - knockback_resistance)
		velocity = kb_velocity
		
		# Set knockback immunity
		is_knockback_immune = true
		knockback_immunity_timer = 0.2 # Short immunity after knockback

# Scales enemy properties based on difficulty using wave number
# (Assuming this is the intended scaling method)
func scale_difficulty(wave_number: int):
	# Apply scaling based on wave number
	current_health = max_health * pow(health_scale_per_wave, wave_number - 1)
	current_speed = speed * pow(speed_scale_per_wave, wave_number - 1)
	current_damage = attack_damage * pow(damage_scale_per_wave, wave_number - 1)
	# Update agent max speed if needed?
	if navigation_agent: navigation_agent.max_speed = current_speed # Good idea to update this
	
	score_value = int(score_value * pow(1.2, wave_number - 1)) # Example score scaling
	
	emit_signal("health_changed", current_health, max_health) # Update health bar if exists
	print("Enemy scaled for wave %s: HP=%.1f, SPD=%.1f, DMG=%.1f" % [wave_number, current_health, current_speed, current_damage])

# --- Signal Handler for Velocity Computation --- (Handles Movement)
func _on_velocity_computed(safe_velocity: Vector2):
	# Check if under knockback - if so, knockback velocity takes precedence.
	if not is_knockback_immune: 
		velocity = safe_velocity
	# else: knockback velocity is already set in apply_knockback and handled in _physics_process

	move_and_slide() # Apply the final velocity (either safe_velocity or knockback)

# Cleaned up unused functions and _draw method
