extends Node2D

@onready var player = $Player
@onready var enemy_scene = preload("res://scenes/EnemyFish.tscn")

var current_wait_time = 2
const MIN_WAIT_TIME = 0.2  # minimum wait time limit
const WAIT_TIME_DECREASE_FACTOR = 0.98

@onready var stats_popup_scene = preload("res://scenes/StatsPopup.tscn")
var stats_popup: Control = null

# Define enemy types with scale, spawn weight, and sprites
@onready var enemy_types = {
	"small": {
		"scaleSize": 0.5,
		"spawnWeight": 4,
		"growthValue": 0.02,
		"sprites": [
			preload("res://sprites/enemy1.png"),
			preload("res://sprites/enemy2.png")
		]
	},
	"medium": {
		"scaleSize": 1.5,
		"spawnWeight": 8,
		"growthValue": 0.1,
		"sprites": [
			preload("res://sprites/enemy3.png"),
			preload("res://sprites/enemy4.png"),
		]
	},
	"large": {
		"scaleSize": 2.5,
		"spawnWeight": 3,
		"growthValue": 0.2,
		"sprites": [
			preload("res://sprites/shark.png"),
			preload("res://sprites/jellyfish.png"),
			preload("res://sprites/enemy5.png"),
		]
	},
	"huge": {
		"scaleSize": 5,
		"spawnWeight": 1,
		"growthValue": 1,
		"sprites": [
			preload("res://sprites/whale.png")
		]
	}
}

# Precomputed weighted list of keys based on spawnWeight
var weighted_keys: Array = []

func _ready():
	$Timer.wait_time = 1
	$Timer.start()

	# Instantiate and add stats popup to UI layer
	stats_popup = stats_popup_scene.instantiate()
	stats_popup.visible = false
	get_tree().root.add_child(stats_popup)

	# Build weighted key list once for performance
	for key in enemy_types.keys():
		var weight = enemy_types[key].get("spawnWeight", 1)
		for i in range(weight):
			weighted_keys.append(key)

func _on_timer_timeout():
	spawn_enemy()
	
	# Decrease the wait time but clamp it to minimum
	current_wait_time = max(current_wait_time * WAIT_TIME_DECREASE_FACTOR, MIN_WAIT_TIME)
	$Timer.wait_time = current_wait_time
	$Timer.start()


func spawn_enemy():
	var enemy = enemy_scene.instantiate()

	# Assign placeholder wallet info
	enemy.wallet_address = "coming soon"
	enemy.holding_percentage = "coming soon"

	# Connect signals for popup
	enemy.connect("show_stats", Callable(self, "_on_show_stats"))
	enemy.connect("hide_stats", Callable(self, "_on_hide_stats"))

	# Determine spawn direction
	var from_left = randf() < 0.5
	var start_x = -100 if from_left else 1100
	var enemy_speed = randf_range(80, 160) if from_left else randf_range(-160, -80)

	enemy.position = Vector2(start_x, randf_range(100, 800))
	enemy.speed = enemy_speed

	# Choose enemy type using weighted list
	var type_key = weighted_keys[randi() % weighted_keys.size()]
	var enemy_data = enemy_types[type_key]

	# Assign sprite and scale
	var sprite = enemy.get_node("Sprite2D")
	var sprite_list = enemy_data["sprites"]
	sprite.texture = sprite_list[randi() % sprite_list.size()]
	var base_scale = float(enemy_data["scaleSize"])
	var variation = randf_range(-0.3, 0.3)
	var final_scale = max(base_scale + variation, 0.1)  # Avoid scale below 0.1
	enemy.scale = Vector2(final_scale, final_scale)


	sprite.flip_h = enemy_speed > 0
	enemy.call_deferred("update_visual_size_and_collision")

	enemy.growth_value = enemy_data["growthValue"]
	enemy.enemy_type_key = type_key
	
	add_child(enemy)

func _on_show_stats(wallet: String, holding: String, global_pos: Vector2) -> void:
	stats_popup.show_stats(wallet, holding, global_pos)

func _on_hide_stats() -> void:
	stats_popup.hide_stats()
