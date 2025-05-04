# mech.gd
# Player-controlled mech character with movement, dashing, and shooting capabilities.
# This script handles the core player mechanics including movement, dashing, aiming, and shooting.
# Author: [Your Name]
# Date: [Current Date]

extends CharacterBody2D

# Movement properties
@export var walk_speed: float = 300.0
@export var run_speed_multiplier: float = 1.8

# Dash properties
@export var dash_speed_multiplier: float = 3.0
@export var dash_duration: float = 0.15 # How long the dash velocity lasts
@export var dash_cooldown: float = 1.0 # Time between dashes
@export var dash_invincibility_duration: float = 0.3 # How long invincibility lasts after dash

# Combat properties
@export var projectile_scene: PackedScene # Will hold our projectile scene file
@export var max_health: int = 100 # Maximum health of the mech
@export var projectile_damage: int = 25 # Damage dealt by projectiles (Increased for testing)

# Internal state variables
var current_speed: float = 0.0
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var aim_direction: Vector2 = Vector2.RIGHT # Default facing right
var current_health: int = max_health
var is_invincible: bool = false
var invincibility_timer: float = 0.0

# Node references
# @onready var muzzle_point = $Sprite2D/MuzzlePoint # OLD PATH - INCORRECT - REMOVED
@onready var muzzle = $Muzzle # CORRECTED PATH - Direct child of Mech node

# Signals
signal health_changed(new_health: int)
signal dash_ready
signal dash_used
signal mech_died

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	# Initialize health
	current_health = max_health
	
	# Add to player group for easy reference
	add_to_group("player")
	
	print("DEBUG: Mech initialized with health: ", current_health)

# Called every physics frame
func _physics_process(delta: float) -> void:
	# Update timers
	_update_timers(delta)
	
	# Handle dash state
	_handle_dash(delta)
	
	# Handle shooting input
	_handle_shooting()
	
	# Handle movement
	_handle_movement()
	
	# Update aim direction
	_update_aim()

# Updates all timers
func _update_timers(delta: float) -> void:
	# Update dash cooldown timer
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta
		if dash_cooldown_timer <= 0:
			emit_signal("dash_ready")
	
	# Update invincibility timer
	if invincibility_timer > 0:
		invincibility_timer -= delta
		if invincibility_timer <= 0:
			is_invincible = false

# Handles the dash state and timer
func _handle_dash(delta: float) -> void:
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
			# Start invincibility period after dash
			is_invincible = true
			invincibility_timer = dash_invincibility_duration
		# Keep moving with dash velocity during the dash
		move_and_slide()
		return # Skip normal movement calculation during dash frame

# Handles shooting input and projectile firing
func _handle_shooting() -> void:
	if Input.is_action_just_pressed("shoot"):
		fire_projectile()

# Handles movement input and velocity calculation
func _handle_movement() -> void:
	# Skip movement if dashing
	if is_dashing:
		return
		
	# Get input direction
	var input_direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	# Determine current speed (walking or running)
	if Input.is_action_pressed("run"):
		current_speed = walk_speed * run_speed_multiplier
	else:
		current_speed = walk_speed

	# Handle Dash Input
	if Input.is_action_just_pressed("dash") and not is_dashing and dash_cooldown_timer <= 0:
		is_dashing = true
		dash_timer = dash_duration
		dash_cooldown_timer = dash_cooldown
		# Apply dash velocity in the direction of input, or facing direction if no input
		var dash_direction = input_direction if input_direction != Vector2.ZERO else aim_direction
		velocity = dash_direction.normalized() * walk_speed * dash_speed_multiplier
		emit_signal("dash_used")
		# print("DEBUG: Dash Started! Velocity: ", velocity) # Commented out dash start print
		move_and_slide() # Apply dash velocity immediately
		return # Skip normal movement for this frame

	# Calculate normal movement velocity
	if input_direction != Vector2.ZERO:
		velocity = input_direction.normalized() * current_speed
	else:
		velocity = Vector2.ZERO # Stop moving if no input

	# Apply movement
	move_and_slide()

# Updates the aim direction based on mouse position
func _update_aim() -> void:
	var mouse_pos = get_global_mouse_position()
	aim_direction = (mouse_pos - global_position).normalized()
	
	# Update mech rotation to face aim direction
	rotation = aim_direction.angle()

# Fires a projectile in the current aim direction
func fire_projectile() -> void:
	if projectile_scene == null:
		print("ERROR: Projectile scene not set on Mech!")
		return

	# Check if the Muzzle node exists
	if muzzle == null:
		print("ERROR: Muzzle node not found! Ensure it exists and the path is correct in mech.gd.")
		return

	# Make sure we can actually get the scene tree and root node
	if not is_inside_tree():
		print("ERROR: Mech not in scene tree, cannot fire.")
		return
	var tree_root = get_tree().root
	if tree_root == null:
		print("ERROR: Cannot get scene tree root.")
		return

	# Instance the projectile
	var projectile = projectile_scene.instantiate()

	# Check if instantiation worked
	if projectile == null:
		print("ERROR: Failed to instantiate projectile scene.")
		return

	# Add to the main scene tree NOT as a child of the mech
	tree_root.add_child(projectile)

	# Position projectile at the muzzle point (using Marker2D's global position)
	# var muzzle_position = global_position + muzzle_offset.rotated(rotation) - REMOVED OLD CODE
	projectile.global_position = muzzle.global_position # Use Marker2D global position
	
	# Set projectile rotation to match aim direction
	projectile.rotation = aim_direction.angle()
	
	# Set projectile damage if it has the property
	if projectile.has_method("set_damage"):
		projectile.set_damage(projectile_damage)

	print("DEBUG: Fired projectile from ", muzzle.global_position, " towards ", aim_direction) # Debug output using marker position

# Takes damage and updates health
func take_damage(amount: int) -> void:
	print("DEBUG: Mech take_damage called with amount: ", amount)
	
	# Skip if invincible
	if is_invincible:
		print("DEBUG: Mech is invincible, ignoring damage")
		return
		
	# Apply damage
	current_health = max(0, current_health - amount)
	emit_signal("health_changed", current_health)
	
	print("DEBUG: Mech took ", amount, " damage. Health remaining: ", current_health)
	
	# Make player flash or show hit effect
	modulate = Color(1, 0.5, 0.5, 1) # Flash red
	var timer = get_tree().create_timer(0.1)
	await timer.timeout
	modulate = Color(1, 1, 1, 1) # Reset to normal
	
	# Check if dead
	if current_health <= 0:
		die()

# Handles death
func die() -> void:
	print("DEBUG: Mech destroyed!")
	emit_signal("mech_died")
	
	# Notify game manager
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager and game_manager.has_method("end_game"):
		game_manager.end_game()
	
	# Disable the mech
	set_physics_process(false)
	set_process_input(false)
	
	# Optional: Play death animation or effect
	# For now, just hide the mech
	visible = false
