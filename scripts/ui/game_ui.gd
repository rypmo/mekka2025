# game_ui.gd
# Connects UI elements to the game manager for displaying game state.
# Author: [Your Name]
# Date: [Current Date]

extends CanvasLayer

# UI elements
@onready var health_label = $HealthLabel
@onready var score_label = $ScoreLabel
@onready var wave_label = $WaveLabel
@onready var enemies_label = $EnemiesLabel

# References
var game_manager = null
var player = null

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	# Find game manager
	game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager == null:
		print("ERROR: Game manager not found!")
		return
	
	# Find player
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		print("ERROR: Player not found!")
		return
	
	# Connect to signals
	_connect_signals()
	
	# Initialize UI
	_update_ui()
	
	print("DEBUG: Game UI initialized")

# Connects to relevant signals
func _connect_signals() -> void:
	# Game manager signals
	if game_manager.has_signal("score_changed"):
		game_manager.score_changed.connect(_on_score_changed)
	
	if game_manager.has_signal("enemies_defeated_changed"):
		game_manager.enemies_defeated_changed.connect(_on_enemies_defeated_changed)
	
	if game_manager.has_signal("wave_started"):
		game_manager.wave_started.connect(_on_wave_started)
	
	# Player signals
	if player.has_signal("health_changed"):
		player.health_changed.connect(_on_health_changed)

# Updates all UI elements
func _update_ui() -> void:
	# Update health
	if player != null:
		health_label.text = "Health: " + str(player.current_health)
	
	# Update score
	if game_manager != null:
		score_label.text = "Score: " + str(game_manager.score)
		wave_label.text = "Wave: " + str(game_manager.wave)
		enemies_label.text = "Enemies: " + str(game_manager.enemies_defeated)

# Signal handlers
func _on_health_changed(new_health: int) -> void:
	health_label.text = "Health: " + str(new_health)

func _on_score_changed(new_score: int) -> void:
	score_label.text = "Score: " + str(new_score)

func _on_enemies_defeated_changed(new_count: int) -> void:
	enemies_label.text = "Enemies: " + str(new_count)

func _on_wave_started(wave_number: int) -> void:
	wave_label.text = "Wave: " + str(wave_number) 