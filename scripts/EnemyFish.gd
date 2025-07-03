extends CharacterBody2D

@export var speed = 100


var visual_size = 0.0  # This stores the visible width in pixels (with scale applied)



func _process(delta):
	position.x += speed * delta
	if position.x < -100 or position.x > 1300:
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
