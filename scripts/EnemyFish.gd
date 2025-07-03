extends CharacterBody2D

@export var speed = 100
@export var is_bigger = false

func _process(delta):
	position.x += speed * delta
	if position.x < -100 or position.x > 1300:
		queue_free()
