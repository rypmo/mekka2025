# projectile.gd
# Projectile fired by the player's mech.
# This script handles projectile movement, collision detection, and damage dealing.
# Author: [Your Name]
# Date: [Current Date]

extends Area2D

# Movement properties
@export var speed: float = 750.0 # Pixels per second
@export var lifetime: float = 5.0 # How long the projectile exists before auto-destroying

# Combat properties
@export var damage: int = 1 # Base damage of the projectile
@export var penetration: int = 1 # How many enemies this projectile can hit before being destroyed
@export var knockback: float = 100.0 # Knockback force applied to enemies

# Internal state variables
var enemies_hit: int = 0 # Counter for how many enemies this projectile has hit

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	# Set up lifetime timer
	var timer = Timer.new()
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.connect("timeout", _on_timer_timeout)
	add_child(timer)
	timer.start()
	
	# connect("body_entered", _on_body_entered) # REMOVED - Signal is connected in the scene file
	
	print("DEBUG: Projectile created with damage: ", damage)

# Called every physics frame
func _physics_process(delta: float) -> void:
	# Move the projectile forward based on its rotation
	var direction = transform.x # Vector pointing to the node's local +X direction
	global_position += direction * speed * delta

# Called when the projectile's lifetime timer expires
func _on_timer_timeout() -> void:
	print("DEBUG: Projectile lifetime ended. Deleting.") # Debug output
	queue_free() # Destroy the projectile

# Called when the projectile collides with a body
func _on_body_entered(body: Node2D) -> void:
	# Check if the body that entered belongs to the "enemies" group
	if body.is_in_group("enemies"):
		print("DEBUG: Projectile hit enemy: ", body.name) # Log which enemy was hit
		
		# Apply damage if the enemy has the take_damage method
		if body.has_method("take_damage"):
			# Call the take_damage function on the enemy that was hit
			body.take_damage(damage)
			
			# Apply knockback if the enemy has the apply_knockback method
			if body.has_method("apply_knockback"):
				var knockback_direction = transform.x # Use projectile's forward direction
				body.apply_knockback(knockback_direction * knockback)
		else:
			print("ERROR: Enemy body ", body.name, " does not have take_damage method!")
		
		# Increment hit counter
		enemies_hit += 1
		
		# Check if we've hit the maximum number of enemies
		if enemies_hit >= penetration:
			print("DEBUG: Projectile reached maximum penetration. Deleting.")
			queue_free()
	
	# Check for collision with walls
	elif body.is_in_group("walls"):
		print("DEBUG: Projectile hit a wall.")
		queue_free()
	
	# Check for collision with other projectiles
	elif body.is_in_group("projectiles") and body != self:
		print("DEBUG: Projectile collided with another projectile.")
		queue_free()

# Sets the damage value for this projectile
func set_damage(new_damage: int) -> void:
	damage = new_damage
	print("DEBUG: Projectile damage set to: ", damage)
