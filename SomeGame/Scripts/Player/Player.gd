extends KinematicBody2D

#Values
var max_dist = 25
var axis = Vector2.ZERO
var last_step = 0
var current_anim = 0


#Nodes
onready var sprite = $YSort/Sprite
onready var animplayer = $AnimationPlayer
onready var animtree = $AnimationTree
onready var animationState = animtree.get('parameters/playback')
onready var movement = $Movement

#Scenes
export var Footstep:PackedScene = null 

#Booleans
var is_attacking = false
var step_done = true

#Arrays
enum {
	IDLE,
	MOVE,
	ATTACK
}

#States and shit
var state = MOVE


#Game Loop
func _ready():
	animtree.active = true

func _physics_process(delta):
	handle_particles()
	animations()
	print(state)
	match state:
		IDLE:
			move(delta)
		MOVE:
			move(delta)
		ATTACK:
			attack(delta)

# Funtions
func move(delta):
	axis = movement.get_input_axis() if !is_attacking else Vector2.ZERO
	if axis == Vector2.ZERO:
		movement.apply_friction(movement.accel * delta)
	else:
		movement.apply_movement(axis * movement.accel * delta)
	movement.motion = move_and_slide(movement.motion)

func animations():
	var move_direction = movement.get_input_axis()
	if move_direction != Vector2.ZERO && !is_attacking:
		animtree.set('parameters/Run/blend_position', move_direction)
		animtree.set('parameters/Idle/blend_position', move_direction)
		
		animationState.travel("Run")
		state = MOVE
	else:
		animationState.travel("Idle")


	if Input.is_action_just_pressed("Attack"):
		state = ATTACK

	

func handle_particles():
	if state == MOVE && axis != Vector2.ZERO:
		if step_done:
			step_done = false
			var footstep = Footstep.instance()
			footstep.emitting = true
			footstep.global_position = Vector2(sprite.global_position.x, sprite.global_position.y + 15)
			get_parent().get_parent().add_child(footstep)
			yield(get_tree().create_timer(1),"timeout")
			step_done = true

func particles():
	if state == MOVE && axis != Vector2.ZERO:
		last_step = -1
	if animplayer.current_animation_position == 0 or 0.2 or 0.3:
		if last_step != animplayer.current_animation_length:
			last_step = animplayer.current_animation
			var footstep = Footstep.instance()
			footstep.emitting = true
			footstep.global_position = Vector2(global_position.x,global_position.y + 15)
			get_parent().get_parent().add_child(footstep)

func attack(delta):
	axis = Vector2.ZERO
	is_attacking = true
	var mouse_dir = get_local_mouse_position().clamped(2)
	animtree.set('parameters/Attack/blend_position', mouse_dir)
	animationState.travel("Attack")
	

func attack_done():
	state = MOVE
	is_attacking = false
