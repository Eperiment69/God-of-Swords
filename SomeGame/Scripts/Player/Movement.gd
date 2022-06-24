extends Node2D

var parent = get_parent()
export var max_speed = 750
export var accel = 2000
export var motion = Vector2.ZERO


func _physics_process(delta):
	var axis = get_input_axis()
	if axis == Vector2.ZERO:
		apply_friction(accel * delta)
	else:
		apply_movement(axis * accel* delta)

func get_input_axis():
	var axis = Vector2.ZERO
	axis.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed('left'))
	axis.y = int(Input.is_action_pressed('down')) - int(Input.is_action_pressed('up'))
	return axis.normalized()

func apply_friction(amount):
	if motion.length() > amount:
		motion -= motion.normalized() * amount
	else:
		motion = Vector2.ZERO

func apply_movement(acceleration):
	motion += acceleration
	motion = motion.clamped(max_speed)
