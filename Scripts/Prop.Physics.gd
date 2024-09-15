extends Node

var speed = 0.0 : get = _get_speed, set = _set_speed
@export var active = true
@export var direction = Vector3() : set = _set_direction
@export var angular_direction = Vector2()
@export var velocity = Vector3() : get = _get_velocity, set = _set_velocity
var angular_velocity = Vector2()
var pitch = 0.0
var collisions = [] : get = _get_collisions, set = _set_collisions
var collision_exceptions = [] : get = _get_collision_exceptions, set = _set_collision_exceptions

@onready var collision = get_node_or_null('../Collision')

func _enable():
	
	active = true
	
	if collision != null:
		collision.call_deferred('set_disabled', false)

func _disable():
	
	active = false
	
	if collision != null:
		collision.call_deferred('set_disabled', true)

func _set_collisions(new_collisions):
	
	collisions = new_collisions

func _get_collisions():
	
	return []

func _set_collision_exceptions(new_exceptions):
	
	collision_exceptions = new_exceptions 

func _get_collision_exceptions():
	
#	if not owner is PhysicsBody3D:
#
#		return []
	
	if owner is Area3D:
		
		for exception in collision_exceptions:
			if not is_instance_valid(exception):
				collision_exceptions.erase(exception)
		
		return collision_exceptions
	
	else:
		
		return owner.get_collision_exceptions()

func _set_speed(new_speed): 
	
	speed = new_speed

func _get_speed(): 
	
	return speed

func _set_direction(new_direction):
	
	direction = new_direction

func _set_direction_local(new_direction):
	
	direction = owner.global_transform.basis * new_direction

func _get_velocity():
	
	return velocity

func _set_velocity(new_velocity):
	
	velocity = new_velocity

func _get_forward_speed(): return 0

func _get_sidestep_speed(): return 0

func _teleport(new_position=null, new_rotation=null): pass

func _turn(delta): pass

func _look(delta): pass

func _face(target, angle_delta=0.0): pass
