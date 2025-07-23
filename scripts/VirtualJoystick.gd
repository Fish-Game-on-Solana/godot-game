extends Control

@export var radius := 30.0  # max drag distance in pixels
var dragging := false
var drag_start := Vector2.ZERO
var drag_current := Vector2.ZERO
var direction := Vector2.ZERO

@onready var base = $Base
@onready var knob = $Knob

func _ready():
	base.visible = true
	knob.visible = true
	set_process(true)

func _gui_input(event):
	if event is InputEventScreenTouch or event is InputEventScreenDrag or event is InputEventMouseButton:
		if event.pressed:
			dragging = true
			drag_start = event.position
			drag_current = event.position
		else:
			dragging = false
			direction = Vector2.ZERO

	elif event is InputEventMouseMotion and dragging:
		drag_current = event.position
func _process(delta):
	if dragging:
		var offset = drag_current - drag_start
		var length = offset.length()
		if length > radius:
			offset = offset.normalized() * radius
		knob.position = base.position + offset
		direction = offset.normalized()
	else:
		direction = Vector2.ZERO
		# Smoothly move knob back to base.position
		knob.position = knob.position.lerp(base.position, 10 * delta)
