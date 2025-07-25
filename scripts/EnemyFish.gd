extends CharacterBody2D

@export var speed = 100
var wallet_address: String = "coming soon"
var holding_percentage: String = "coming soon"
var growth_value: float = 0.02
var enemy_type_key: String = ""

var visual_size = 0.0  # This stores the visible width in pixels (with scale applied)

signal show_stats(wallet: String, holding: String, global_pos: Vector2)
signal hide_stats()

func _ready():
	var area = $Area2D
	area.connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	area.connect("mouse_exited", Callable(self, "_on_mouse_exited"))

func _process(delta):
	position.x += speed * delta
	if position.x < -200 or position.x > 1200:
		queue_free()


func update_visual_size_and_collision():
	var sprite = $Sprite2D
	var collision = $CollisionShape2D

	if sprite.texture:
		# Swap to a new CircleShape2D
		var new_shape = CircleShape2D.new()

		# Use the unscaled sprite size
		var size = sprite.texture.get_size()
		var radius = min(size.x, size.y) / 2.7  # Use smaller side for best fit
		if enemy_type_key == "huge":
			radius *= 0.65  # smaller circle for huge fish
		new_shape.radius = radius

		# Assign the new shape
		collision.shape = new_shape

		# Store visual width for sorting or logic
		visual_size = size.x * scale.x  # ← Match player logic




func _on_mouse_entered():
	emit_signal("show_stats", wallet_address, holding_percentage, global_position)

func _on_mouse_exited():
	emit_signal("hide_stats")
