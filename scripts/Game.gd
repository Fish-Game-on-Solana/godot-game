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

func _ready():
	$Timer.start()

func _on_timer_timeout():
	spawn_enemy()

func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	var from_left = randf() < 0.5

	var start_x = 0
	var enemy_speed = 0.0

	if from_left:
		start_x = -100
		enemy_speed = randf_range(80, 160)
	else:
		start_x = 1300
		enemy_speed = randf_range(-160, -80)

	enemy.position = Vector2(start_x, randf_range(100, 500))
	enemy.speed = enemy_speed
	enemy.is_bigger = randf() < 0.5

	var type_index = randi() % enemy_types.size()
	var sprite = enemy.get_node("Sprite2D")
	sprite.texture = enemy_types[type_index]
	
	# Flip the sprite based on direction
	sprite.flip_h = enemy_speed > 0  # flip if moving right

	add_child(enemy)
