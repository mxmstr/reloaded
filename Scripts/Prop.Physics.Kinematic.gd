extends 'res://Scripts/Prop.Physics.gd'

@export var process_movement = true
@export var gravity = -9.8
@export var accel = 3
@export var deaccel = 5
@export var angular_accel = 1.0
@export var angular_deaccel = 1.0
@export var projectile = false
@export var ghost = false

var kinematic_collision

@onready var collision = get_node_or_null('../Collision')

signal move_and_slide

func _get_collisions():
	
	return [kinematic_collision] if kinematic_collision else []

func _get_velocity():
	
	return owner.velocity

func _set_velocity(new_velocity):
	
	owner.velocity = new_velocity

func _get_forward_speed():
	
	return owner.velocity * owner.global_transform.basis.z

func _get_sidestep_speed():
	
	return owner.velocity * owner.global_transform.basis.x

func _teleport(new_position=null, new_rotation=null):
	
	if new_position != null:
		owner.global_transform.origin = new_position
	
	if new_rotation != null:
		owner.global_transform.basis = new_rotation

func _turn(delta):
	
	owner.rotation.y += delta

func _face(target, angle_delta=0.0):
	
	var owner_direction = owner.global_transform.basis.z
	var turn_target = owner.direction_to(target)
	turn_target.y = owner_direction.y
	
	var angle = owner_direction.angle_to(turn_target)
	
	if angle_delta == 0 or angle <= angle_delta:
		
		owner.global_transform.look_at(-turn_target)
	
	else:
		
		turn_target = owner.global_transform.basis.z.lerp(turn_target, angle_delta / angle)
		owner.global_transform.look_at(owner.global_transform.origin - turn_target)

func _process(delta):
	
	if not process_movement or (collision == null and collision.disabled):
		return
	
	var new_velocity = angular_direction * delta
	var deltax = new_velocity.x - angular_velocity.x
	var deltay = new_velocity.y - angular_velocity.y
	var factorx
	var factory
	
	if (new_velocity.x > 0 and angular_velocity.x > 0) or (new_velocity.x < 0 and angular_velocity.x < 0):
		factorx = angular_accel
	else:
		factorx = angular_deaccel
	
	if (new_velocity.y > 0 and angular_velocity.y > 0) or (new_velocity.y < 0 and angular_velocity.y < 0):
		factory = angular_accel
	else:
		factory = angular_deaccel
	
	angular_velocity.x = angular_velocity.lerp(new_velocity, factorx * delta).x
	angular_velocity.y = angular_velocity.lerp(new_velocity, factory * delta).y
	
	
	owner.rotation.y += angular_velocity.x
	owner.rotation.x += angular_velocity.y
	
	if projectile:
		_set_direction_local(Vector3(0, 0, 1))

func _physics_process(delta):
	
	if not process_movement or (collision != null and collision.disabled):
		return

	var gravity_direction = Vector3.DOWN * gravity * delta

	var new_velocity = direction * speed
	var factor

	if new_velocity.dot(owner.velocity) > 0:
		factor = accel
	else:
		factor = deaccel

	if factor > 0:
		new_velocity = owner.velocity.lerp(new_velocity, factor * delta)

	new_velocity += gravity_direction
	
	owner.set_velocity(new_velocity)

	kinematic_collision = owner.move_and_collide(new_velocity, false, 0.001, true, 1)
	
	if kinematic_collision and not ghost:
		owner.velocity = kinematic_collision.remainder

	emit_signal('move_and_slide', delta)
	
