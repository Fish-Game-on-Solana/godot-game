extends CharacterBody2D

@export var speed = 200
@export var growth_per_fish = 1

var size_level = 1
var sprite_stage = 0
var sprites: Array[Texture2D] = []
var last_direction = 1  # 1 = right, -1 = left
var visual_size = 0.0  # Player’s current size on screen in pixels

const WINDOW_SIZE = Vector2(600, 964)
const FLOOR_HEIGHT = 80

@onready var joystick := get_tree().get_current_scene().get_node("CanvasLayer/VirtualJoystick")

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

	if joystick and joystick.direction.length() > 0.01:
		dir += joystick.direction

	# Keyboard input
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

	# Clamp position to window bounds, leaving bottom FLOOR_HEIGHT pixels off-limits
	var half_width = $Sprite2D.texture.get_size().x * scale.x / 2.0
	var half_height = $Sprite2D.texture.get_size().y * scale.y / 2.0

	position.x = clamp(position.x, half_width, WINDOW_SIZE.x - half_width)
	position.y = clamp(position.y, half_height, WINDOW_SIZE.y - FLOOR_HEIGHT - half_height)


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
			var growth_amount = 0.1  # Default growth if no value set
			if "growth_value" in body:
				growth_amount = body.growth_value
			grow(growth_amount)
			body.call_deferred("queue_free")
		else:
			call_deferred("_restart_game")

func grow(amount: float = 0.1):
	size_level += 0.1
	scale += Vector2(amount, amount)
	update_visual_size()
	update_sprite()


func update_visual_size():
	if $Sprite2D.texture:
		var size = $Sprite2D.texture.get_size()
		visual_size = size.x * scale.x  # Scaled width for logic

		var collision = $CollisionShape2D
		var new_shape = CircleShape2D.new()
		var base_radius = min(size.x, size.y) / 2.7  # Base radius without scale
		
		# Apply scale to radius so collision grows with player
		new_shape.radius = base_radius * scale.x
		
		collision.shape = new_shape



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
