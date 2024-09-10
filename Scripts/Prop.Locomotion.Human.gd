extends Node

enum StanceType {
	STANDING,
	CROUCHING,
	CRAWLING
}

enum SpeedType {
	STOPPED,
	WALKING,
	RUNNING
}

enum LeanDirection {
	DEFAULT,
	LEFT,
	RIGHT
}

enum SurfaceType {
	FLOOR,
	WALL
}

const wall_run_vertical_speed = 4
const wall_run_vertical_mult = 2
const wall_run_horizontal_mult = 2

@export var forward_speed: float : set = _set_forward_speed
@export var sidestep_speed: float : set = _set_sidestep_speed
@export var turn_speed: float : set = _set_turn_speed
@export var look_speed: float : set = _set_look_speed

@export var stance: StanceType = StanceType.STANDING : set = _set_stance
@export var speed: SpeedType = SpeedType.RUNNING
@export var lean: LeanDirection = LeanDirection.DEFAULT
@export var surface: SurfaceType = SurfaceType.FLOOR

@export var max_speed = 3.25
@export var sprint_mult = 1.75
@export var walk_mult = 0.3
@export var crouch_mult = 0.25
@export var crawl_mult = 0.15

@export var max_slope_angle = 30

var speed_mult = 1.0
var rotate_speed_mult = 1.0

var lock_stance = false
var lock_speed = false
var lock_direction = false
var lock_rotation = false
var lock_movement = false

var wall_normal = Vector3.FORWARD
var wall_forward_speed = 0.0
var wall_sidestep_speed = 0.0

@onready var animation_player = get_node_or_null('AnimationPlayer')
@onready var physics = get_node_or_null('../Physics')
@onready var collision = get_node_or_null('../Collision')
@onready var camera = get_node_or_null('../CameraRig/Camera3D')

func _turn(delta):
	
	if lock_rotation:
		return
	
	physics._turn(delta)

func _look(delta):
	
	if lock_rotation:
		return
	
	physics._look(delta)

func _set_stance_input(new_state):
	
	if lock_stance:
		return
	
	_set_stance(new_state)

func _set_stance(new_state):
	
	stance = new_state
	
	match stance:
	
		StanceType.STANDING:
			
			speed_mult = 1.0
			collision.shape.height = 1.8
			collision.position.y = 0.9
			#animation_player.play('Standing')
		
		StanceType.CROUCHING:
			
			speed_mult = crouch_mult
			collision.shape.height = 1.2
			collision.position.y = 0.6
			#animation_player.play('Crouching')
		
		StanceType.CRAWLING:
			
			speed_mult = crawl_mult
			collision.shape.height = 0.6
			collision.position.y = 0.3
			#animation_player.play('Crawling')

func _set_forward_speed(new_speed):
	
	forward_speed = new_speed

func _set_sidestep_speed(new_speed):
	
	sidestep_speed = new_speed

func _set_turn_speed(new_speed):
	
	physics.angular_direction.x = new_speed * rotate_speed_mult

func _set_look_speed(new_speed):
	
	physics.angular_direction.y = new_speed * rotate_speed_mult

func _physics_process(delta):
	
	if lock_movement:
		physics.direction = Vector3()
		return
	
	if surface == SurfaceType.WALL:
		forward_speed = 1.0
	
	
	var velocity = Vector3()
	var direction = Vector2(sidestep_speed, forward_speed)
	
	if direction.length():
		
		var x2 = sidestep_speed * sidestep_speed
		var y2 = forward_speed * forward_speed
		
		if (x2 >= y2):
			velocity.x = (sign(sidestep_speed) * x2 * 1.0/sqrt(x2 + y2))
			velocity.z = (sign(sidestep_speed) * sidestep_speed * forward_speed * 1.0/sqrt(x2 + y2))

		if (x2 < y2):
			velocity.x = (sign(forward_speed) * sidestep_speed * forward_speed * 1.0/sqrt(x2 + y2))
			velocity.z = (sign(forward_speed) * y2 * 1.0/sqrt(x2 + y2))
	
	
	if surface == SurfaceType.FLOOR:
		
		velocity *= max_speed * speed_mult
		
		if stance == StanceType.STANDING \
			and Vector3(0, 0, 1).angle_to(velocity) < 0.25 \
			and owner.velocity.length() > (max_speed * 0.95):
			velocity *= sprint_mult
		
		physics._set_speed(velocity.length())
		physics._set_direction_local(velocity.normalized())
	
	elif surface == SurfaceType.WALL:
		
		velocity *= max_speed
		
		var global_rotation = owner.global_transform.basis
		var global_velocity = global_rotation * velocity
		var slide_direction = global_velocity.slide(wall_normal)
		slide_direction = slide_direction.lerp(-wall_normal, 0.1)
		
		var facing_angle_forward = global_rotation.z.angle_to(-wall_normal)
		var facing_angle_sidestep = global_rotation.z.angle_to(
			(-wall_normal).rotated(Vector3.UP, (PI / 2))
			)
		var slide_angle_forward = global_velocity.angle_to(-wall_normal)
		var slide_angle_sidestep = global_velocity.angle_to(
			(-wall_normal).rotated(Vector3.UP, (PI / 2))
			)
		
		var horizontal_speed = velocity.length() * ( min(slide_angle_forward * wall_run_horizontal_mult, PI) / PI )
		var vertical_speed = velocity.length() * ( (PI - min(slide_angle_forward * wall_run_vertical_mult, PI) ) / PI )# * wall_run_vertical_speed
		
		wall_forward_speed = max( ((PI / 2) - facing_angle_forward) / (PI / 2), 0 )
		wall_sidestep_speed = ((PI / 2) - facing_angle_sidestep) / (PI / 2)
		
		physics._set_speed(horizontal_speed)
		physics._set_direction(slide_direction.normalized())
		physics._set_vertical_velocity(vertical_speed)
