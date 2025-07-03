extends CharacterBody2D

@export var speed = 200
@export var growth_per_fish = 0.1

var size_level = 1
var sprite_stage = 0
var sprites: Array[Texture2D] = []
var last_direction = 1  # 1 = right, -1 = left

func _ready():
	sprites = [
		preload("res://sprites/player_1.png"),
		preload("res://sprites/player_2.png"),
		preload("res://sprites/player_3.png"),
	]
	update_sprite()

func _process(delta):
	var dir = Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		dir.x += 1
	if Input.is_action_pressed("ui_left"):
		dir.x -= 1
	if Input.is_action_pressed("ui_down"):
		dir.y += 1
	if Input.is_action_pressed("ui_up"):
		dir.y -= 1

	if dir.x != 0:
		last_direction = -dir.x  # Save direction

	# Flip sprite based on last direction
	$Sprite2D.flip_h = last_direction < 0

	velocity = dir.normalized() * speed
	move_and_slide()

func _on_area_2d_body_entered(body):
	if body != self and body is CharacterBody2D and body.has_node("Sprite2D"):
		var enemy_sprite = body.get_node("Sprite2D")
		var enemy_size = enemy_sprite.texture.get_size().x * body.scale.x
		var player_size = $Sprite2D.texture.get_size().x * scale.x

		if player_size >= enemy_size:
			grow()
			body.queue_free()
		else:
			get_tree().reload_current_scene()

func grow():
	size_level += 1
	scale += Vector2(growth_per_fish, growth_per_fish)
	update_sprite()

func update_sprite():
	sprite_stage = clamp(int(size_level / 3), 0, sprites.size() - 1)
	$Sprite2D.texture = sprites[sprite_stage]
