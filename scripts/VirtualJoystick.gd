extends Control

@export var radius := 30.0  # max drag distance in pixels
@export var tap_threshold := 10.0  # max distance for tap detection
@export var tap_time_limit := 0.3  # max time for tap detection (seconds)\
@onready var move_label = $Move
var has_moved_once := false

var dragging := false
var drag_start := Vector2.ZERO
var drag_current := Vector2.ZERO
var direction := Vector2.ZERO

# Tap detection variables
var touch_start_time := 0.0
var touch_start_pos := Vector2.ZERO
var is_potential_tap := false

@onready var base = $Base
@onready var knob = $Knob

# Signal for tap events
signal tapped(position: Vector2)
signal drag_started()
signal drag_ended()

func _ready():
	base.visible = true
	knob.visible = true
	set_process(true)

func _gui_input(event):
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.pressed:
			_handle_touch_start(event)
		else:
			_handle_touch_end(event)
	elif event is InputEventScreenDrag or (event is InputEventMouseMotion and dragging):
		_handle_drag(event)

func _handle_touch_start(event):
	dragging = true
	drag_start = event.position
	drag_current = event.position
	
	# Initialize tap detection
	touch_start_time = Time.get_time_dict_from_system()["second"] + Time.get_time_dict_from_system()["minute"] * 60
	touch_start_pos = event.position
	is_potential_tap = true
	
	drag_started.emit()

func _handle_touch_end(event):
	var current_time = Time.get_time_dict_from_system()["second"] + Time.get_time_dict_from_system()["minute"] * 60
	var touch_duration = current_time - touch_start_time
	var touch_distance = (event.position - touch_start_pos).length()
	
	# Check if this was a tap (short duration, small movement)
	if is_potential_tap and touch_duration < tap_time_limit and touch_distance < tap_threshold:
		tapped.emit(event.position)
		print("Tap detected at: ", event.position)
	
	# Reset dragging state
	dragging = false
	direction = Vector2.ZERO
	is_potential_tap = false
	
	drag_ended.emit()

func _handle_drag(event):
	drag_current = event.position
	
	# If we've moved too far, it's no longer a potential tap
	var drag_distance = (drag_current - touch_start_pos).length()
	if drag_distance > tap_threshold:
		is_potential_tap = false
		
	if not has_moved_once:
		has_moved_once = true
		move_label.visible = false	

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

# Helper function to get the current direction vector
func get_direction() -> Vector2:
	return direction

# Helper function to check if joystick is being used
func is_active() -> bool:
	return dragging
