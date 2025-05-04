# game_utils.gd
# Utility functions for game mechanics and calculations.
# This script provides common utility functions that can be used across the project.
# Author: [Your Name]
# Date: [Current Date]

extends Node

# Returns a random position within a specified radius of a center point
static func get_random_position_in_radius(center: Vector2, radius: float) -> Vector2:
	var random_angle = randf() * TAU  # Random angle in radians (0 to 2π)
	var random_distance = randf() * radius  # Random distance from center (0 to radius)
	
	# Calculate position using polar coordinates
	var x = center.x + random_distance * cos(random_angle)
	var y = center.y + random_distance * sin(random_angle)
	
	return Vector2(x, y)

# Calculates the angle between two points in radians
static func angle_between_points(from: Vector2, to: Vector2) -> float:
	return (to - from).angle()

# Calculates the distance between two points
static func distance_between_points(from: Vector2, to: Vector2) -> float:
	return from.distance_to(to)

# Returns a random integer between min and max (inclusive)
static func random_int(min_value: int, max_value: int) -> int:
	return randi() % (max_value - min_value + 1) + min_value

# Returns a random float between min and max
static func random_float(min_value: float, max_value: float) -> float:
	return randf() * (max_value - min_value) + min_value

# Prints debug information with a timestamp
static func debug_print(message: String) -> void:
	var timestamp = Time.get_time_dict_from_system()
	var time_string = "%02d:%02d:%02d" % [timestamp.hour, timestamp.minute, timestamp.second]
	print("[%s] %s" % [time_string, message]) 