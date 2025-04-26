# projectile.gd
extends Area2D

@export var speed: float = 750.0 # Pixels per second

# Note: Direction is determined by the node's rotation set by the Mech when spawning.
# The projectile always moves along its local forward axis (transform.x).

func _physics_process(delta: float) -> void:
	# Move the projectile forward based on its rotation
	var direction = transform.x # Vector pointing to the node's local +X direction
	global_position += direction * speed * delta

# Connect the Timer's "timeout" signal to this function in the editor
func _on_timer_timeout() -> void:
	print("DEBUG: Projectile lifetime ended. Deleting.") # Debug output
	queue_free() # Destroy the projectile

func _on_body_entered(body: Node2D) -> void:
	# Check if the body that entered belongs to the "enemies" group
	if body.is_in_group("enemies"):
		print("DEBUG: Projectile hit enemy: ", body.name) # Log which enemy was hit

		# Check if the enemy body actually has the take_damage method before calling
		if body.has_method("take_damage"):
			# Call the take_damage function on the enemy that was hit
			body.take_damage(1) # Deal 1 damage per projectile for now
		else:
			print("ERROR: Enemy body ", body.name, " does not have take_damage method!")

		# Projectile should destroy itself immediately after hitting an enemy
		queue_free()

	# Optional check: Add collision with walls later?
	# elif body.is_in_group("walls"):
	#    print("DEBUG: Projectile hit a wall.")
	#    queue_free()
