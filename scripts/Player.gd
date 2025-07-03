extends CharacterBody2D

@export var speed = 200
@export var growth_per_fish = 0.1

var size_level = 1
var sprite_stage = 0
var sprites: Array[Texture2D] = []
var last_direction = 1  # 1 = right, -1 = left
var visual_size = 0.0  # Player’s current size on screen in pixels

func _ready():
	sprites = [
		preload("res://sprites/player_1.png"),
		preload("res://sprites/player_2.png"),
		preload("res://sprites/player_3.png"),
	]
	update_sprite()
	update_visual_size()
	spawn_in_middle()

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
		var enemy_size = 0.0
		if "visual_size" in body:
			enemy_size = body.visual_size
		else:
			var enemy_sprite = body.get_node("Sprite2D")
			if enemy_sprite.texture:
				enemy_size = enemy_sprite.texture.get_size().x * body.scale.x

		if visual_size >= enemy_size:
			grow()
			body.call_deferred("queue_free")
		else:
			call_deferred("_restart_game")


func grow():
	size_level += 1
	scale += Vector2(growth_per_fish, growth_per_fish)
	update_visual_size()
	update_sprite()

func update_visual_size():
	if $Sprite2D.texture:
		visual_size = $Sprite2D.texture.get_size().x * scale.x
		
		var collision = $CollisionShape2D
		if collision.shape is RectangleShape2D:
			# Duplicate the shape to avoid shared instance issues
			var new_shape = collision.shape.duplicate()
			collision.shape = new_shape
			new_shape.extents = $Sprite2D.texture.get_size() * scale / 2


func update_sprite():
	sprite_stage = clamp(int(size_level / 3), 0, sprites.size() - 1)
	$Sprite2D.texture = sprites[sprite_stage]
	
func _restart_game():
	get_tree().reload_current_scene()
	
func spawn_in_middle():
	var viewport = get_viewport()
	if viewport:
		var screen_size = viewport.get_visible_rect().size
		position = screen_size / 2
