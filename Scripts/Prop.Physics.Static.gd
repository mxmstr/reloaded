extends 'res://Scripts/Prop.Physics.gd'

@export var process_movement = false
@export var gravity = 0
@export var accel = 0
@export var deaccel = 0
@export var projectile = false

signal before_move
signal after_move

func _enable():
	
	super()
	
	if owner is Area3D:
		owner.monitoring = false

func _disable():
	
	super()
	
	if owner is Area3D:
		owner.monitoring = true

func _get_forward_speed():
	
	return velocity * owner.global_transform.basis.z

func _get_sidestep_speed():
	
	return velocity * owner.global_transform.basis.x

func _set_direction(new_direction, local=false):
	
	if local:
		direction = owner.global_transform.basis * new_direction
	else:
		direction = new_direction

func _teleport(new_position=null, new_rotation=null):
	
	if new_position != null:
		owner.global_transform.origin = new_position
	
	if new_rotation != null:
		owner.global_transform.basis = Basis.from_euler(new_rotation.get_euler())

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

func _physics_process(delta):
	
	if not active or not process_movement: return
	
	angular_velocity = angular_direction * delta
	
	owner.rotation.y += angular_velocity.x
	owner.rotation.x += angular_velocity.y
	
	if projectile:
		_set_direction(Vector3(0, 0, 1), true)
		
	var new_velocity = direction * speed * delta
	var factor
	
	if new_velocity.dot(velocity) > 0:
		factor = accel
	else:
		factor = deaccel
	
	if factor > 0:
		velocity = velocity.lerp(new_velocity, factor * delta)
	else:
		velocity = new_velocity
	
	velocity.y += (delta * gravity)
	
	emit_signal('before_move', velocity)
	
	owner.transform.origin += velocity
	
	emit_signal('after_move', velocity)
	
