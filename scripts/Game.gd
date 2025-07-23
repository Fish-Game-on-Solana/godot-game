extends Node2D

@onready var player = $Player
@onready var enemy_scene = preload("res://scenes/EnemyFish.tscn")
@onready var enemy_types = [
	preload("res://sprites/enemy1.png"),
	preload("res://sprites/enemy2.png"),
	preload("res://sprites/enemy3.png"),
	preload("res://sprites/enemy4.png"),
	preload("res://sprites/jellyfish.png"),
	preload("res://sprites/shark.png"),
	preload("res://sprites/whale.png")
]

# Preload your stats popup scene here (adjust path accordingly)
@onready var stats_popup_scene = preload("res://scenes/StatsPopup.tscn")
var stats_popup: Control = null

func _ready():
	$Timer.start()
	
	# Instantiate and add the stats popup to a suitable UI layer (e.g., root viewport or CanvasLayer)
	stats_popup = stats_popup_scene.instantiate()
	stats_popup.visible = false
	
	# Add popup to a CanvasLayer or root viewport to ensure it’s drawn over everything
	get_tree().root.add_child(stats_popup)

func _on_timer_timeout():
	spawn_enemy()

func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	
	# Assign wallet and holding info (for now, all "coming soon")
	enemy.wallet_address = "coming soon"
	enemy.holding_percentage = "coming soon"
	
	# Connect enemy signals for showing/hiding the popup
	enemy.connect("show_stats", Callable(self, "_on_show_stats"))
	enemy.connect("hide_stats", Callable(self, "_on_hide_stats"))

	var from_left = randf() < 0.5
	var start_x = -100 if from_left else 1100
	var enemy_speed = randf_range(80, 160) if from_left else randf_range(-160, -80)
	
	enemy.position = Vector2(start_x, randf_range(100, 800))
	enemy.speed = enemy_speed

	var type_index = randi() % enemy_types.size()
	var sprite = enemy.get_node("Sprite2D")
	sprite.texture = enemy_types[type_index]

	var rand_scale = randf_range(0.5, 1.5)
	enemy.scale = Vector2(rand_scale, rand_scale)

	sprite.flip_h = enemy_speed > 0
	enemy.call_deferred("update_visual_size_and_collision")

	add_child(enemy)

func _on_show_stats(wallet: String, holding: String, global_pos: Vector2) -> void:
	# Show the popup near the enemy position with some offset
	stats_popup.show_stats(wallet, holding, global_pos)

func _on_hide_stats() -> void:
	stats_popup.hide_stats()
