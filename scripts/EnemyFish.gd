extends CharacterBody2D

@export var speed = 100
var wallet_address: String = "coming soon"
var holding_percentage: String = "coming soon"

var visual_size = 0.0  # This stores the visible width in pixels (with scale applied)

signal show_stats(wallet: String, holding: String, global_pos: Vector2)
signal hide_stats()

func _ready():
	var area = $Area2D
	area.connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	area.connect("mouse_exited", Callable(self, "_on_mouse_exited"))

func _process(delta):
	position.x += speed * delta
	if position.x < -100 or position.x > 1200:
		queue_free()


func update_visual_size_and_collision():
	var sprite = $Sprite2D
	var collision = $CollisionShape2D

	if sprite.texture and collision.shape is RectangleShape2D:
		# Duplicate the shape so it's unique for this instance
		var new_shape = collision.shape.duplicate()
		collision.shape = new_shape

		var size = sprite.texture.get_size() * scale
		visual_size = size.x
		new_shape.extents = size / 2

func _on_mouse_entered():
	emit_signal("show_stats", wallet_address, holding_percentage, global_position)

func _on_mouse_exited():
	emit_signal("hide_stats")
