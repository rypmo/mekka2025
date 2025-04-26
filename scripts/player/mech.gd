# mech.gd
extends CharacterBody2D

@export var walk_speed: float = 300.0
@export var run_speed_multiplier: float = 1.8
@export var dash_speed_multiplier: float = 3.0
@export var dash_duration: float = 0.15 # How long the dash velocity lasts

@export var projectile_scene: PackedScene # Will hold our projectile scene file

var current_speed: float = 0.0
var is_dashing: bool = false
var dash_timer: float = 0.0

func _physics_process(delta: float) -> void:
	# Handle Dash Timer
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
		# Keep moving with dash velocity during the dash, then recalculate below
		move_and_slide()
		return # Skip normal movement calculation during dash frame

	# --- Shooting Input ---
	if Input.is_action_just_pressed("shoot"):
		fire_projectile()
	# --- End Shooting Input ---

	# Get input direction
	var input_direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	# Determine current speed (walking or running)
	if Input.is_action_pressed("run"):
		current_speed = walk_speed * run_speed_multiplier
	else:
		current_speed = walk_speed

	# Handle Dash Input
	if Input.is_action_just_pressed("dash") and not is_dashing:
		is_dashing = true
		dash_timer = dash_duration
		# Apply dash velocity in the direction of input, or facing direction if no input
		var dash_direction = input_direction if input_direction != Vector2.ZERO else transform.x # Default to facing right if idle, better might be last non-zero dir
		velocity = dash_direction.normalized() * walk_speed * dash_speed_multiplier
		print("DEBUG: Dash Started! Velocity: ", velocity) # Debug output
		move_and_slide() # Apply dash velocity immediately
		return # Skip normal movement for this frame

	# Calculate normal movement velocity
	if input_direction != Vector2.ZERO:
		velocity = input_direction.normalized() * current_speed
	else:
		velocity = Vector2.ZERO # Stop moving if no input

	# Apply movement
	# print("DEBUG: Velocity: ", velocity, " Speed: ", current_speed) # Optional debug output
	move_and_slide()

	# Optional: Rotate sprite to face movement direction (simple version)
	# Note: This might conflict visually with aiming/shooting rotation, consider if needed
	# if velocity.length() > 0 and not is_dashing: # Don't rotate sprite based on movement while dashing maybe?
	#     get_node("Sprite2D").rotation = velocity.angle() + PI/2 # Adjust sprite rotation if needed based on your asset

func fire_projectile() -> void:
	if projectile_scene == null:
		print("ERROR: Projectile scene not set on Mech!")
		return

	# Make sure we can actually get the scene tree and root node
	if not is_inside_tree():
		print("ERROR: Mech not in scene tree, cannot fire.")
		return
	var tree_root = get_tree().root
	if tree_root == null:
		print("ERROR: Cannot get scene tree root.")
		return

	# Get mouse position and calculate direction from Mech
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position).normalized()

	# Instance the projectile
	var projectile = projectile_scene.instantiate()

	# Check if instantiation worked
	if projectile == null:
		print("ERROR: Failed to instantiate projectile scene.")
		return

	# Add to the main scene tree NOT as a child of the mech
	tree_root.add_child(projectile)

	# Position projectile at the Mech's location (can refine later with muzzle point)
	projectile.global_position = global_position
	# Rotate projectile to face the calculated direction
	projectile.rotation = direction.angle()

	print("DEBUG: Fired projectile towards ", direction) # Debug output
