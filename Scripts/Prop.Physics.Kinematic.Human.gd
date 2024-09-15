extends 'res://Scripts/Prop.Physics.gd'

const gravity = 9.8
const max_slides = 4
const accel = 4.0
const deaccel = 7.0
const angular_accel = 0.02#0.05
const angular_deaccel = 9.0
const angular_vertical_speed_mult = 0.5

const SPEED_DEFAULT: float = 7.0
const SPEED_ON_STAIRS: float = 5.0
const ACCEL_DEFAULT: float = 7.0
const ACCEL_AIR: float = 1.0
const WALL_MARGIN: float = 0.001
const STEP_HEIGHT_DEFAULT: Vector3 = Vector3(0, 0.5, 0)
const STEP_MAX_SLOPE_DEGREE: float = 5.0
const STEP_CHECK_COUNT: int = 1

var on_wall_count = 0
var is_step: bool = false
var step_check = false
var step_check_height: Vector3 = STEP_HEIGHT_DEFAULT / STEP_CHECK_COUNT
var gravity_direction: Vector3 = Vector3.ZERO

var gravity_scale = 1.0
var angular_velocity_x_pos = 0.0
var angular_velocity_x_neg = 0.0
var angular_velocity_y_pos = 0.0
var angular_velocity_y_neg = 0.0
var rotate_x_camera = false
var rotate_y_camera = true
var snap = Vector3()
var factorx = angular_deaccel
var factory = angular_deaccel
var root_motion_use_model = false

@onready var model = get_node_or_null('../Model')
@onready var behavior = get_node_or_null('../Behavior')
@onready var camera_rig = get_node_or_null('../CameraRig')
@onready var bullet_time = get_node_or_null('../BulletTime')

signal move_and_slide

func _get_collisions():
	
	return collisions

func _get_velocity():
	
	return owner.velocity

func _set_velocity(new_velocity):
	
	owner.velocity = new_velocity

func _get_forward_speed():
	
	return (owner.velocity * owner.global_transform.basis).z

func _get_sidestep_speed():
	
	return (owner.velocity * owner.global_transform.basis).x

func _set_vertical_velocity(vertical):
	
	gravity_direction.y = vertical

func _add_vertical_velocity(vertical):
	
	gravity_direction.y += vertical

func _apply_root_transform():
	
	if behavior == null:
		return Vector3()
	
	var root_velocity = behavior.get_root_motion_position()
	var root_rotation = behavior.get_root_motion_rotation().get_euler()
	
	if root_velocity != Vector3() and root_rotation != Vector3():
		
		owner.global_transform.basis = owner.global_transform.basis.rotated(root_rotation)
		
		if root_motion_use_model:
			return root_velocity * model.global_transform.basis
		
		else:
			return root_velocity

	return Vector3()

func _teleport(new_position=null, new_rotation=null):
	
	if new_position != null:
		owner.global_transform.origin = new_position
	
	if new_rotation != null:
		owner.global_transform.basis = new_rotation

func _turn(delta):
	
	angular_direction.x = delta

func _look(delta):
	
	angular_direction.y = delta

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

func _test_movement(new_velocity):
	
	return owner.move_and_collide(new_velocity, true, true, true)

func _apply_rotation(delta):
	
	var new_angular_velocity = angular_direction * delta
	
	if rotate_x_camera:
		if camera_rig != null:
			camera_rig._rotate_camera(new_angular_velocity.y, new_angular_velocity.x)
	else:
		owner.rotation.y += new_angular_velocity.x
		if camera_rig != null:
			camera_rig._rotate_camera(new_angular_velocity.y, 0.0)

func _step_check(delta, new_velocity):
	
	for i in range(STEP_CHECK_COUNT):
		var test_motion_result: PhysicsTestMotionResult3D = PhysicsTestMotionResult3D.new()
		
		var step_height: Vector3 = STEP_HEIGHT_DEFAULT - i * step_check_height
		var params = PhysicsTestMotionParameters3D.new()
		params.from = owner.global_transform
		params.motion = step_height
		var is_player_collided = PhysicsServer3D.body_test_motion(owner.get_rid(), params, test_motion_result)
		
		if test_motion_result.collision_normal.y < 0:
			continue
		
		if not is_player_collided:
			params.from += step_height
			params.motion = new_velocity * delta
			is_player_collided = PhysicsServer3D.body_test_motion(owner.get_rid(), params, test_motion_result)
			
			if not is_player_collided:
				params.from += params.motion
				params.motion = -step_height
				is_player_collided = PhysicsServer3D.body_test_motion(owner.get_rid(), params, test_motion_result)
				if is_player_collided:
					if test_motion_result.collision_normal.angle_to(Vector3.UP) <= deg_to_rad(STEP_MAX_SLOPE_DEGREE):
						is_step = true
						owner.global_transform.origin += -test_motion_result.motion_remainder
						break
			else:
				var wall_collision_normal = test_motion_result.collision_normal

				params.from += test_motion_result.collision_normal * WALL_MARGIN
				params.motion = (new_velocity * delta).slide(wall_collision_normal)
				is_player_collided = PhysicsServer3D.body_test_motion(owner.get_rid(), params, test_motion_result)
				if not is_player_collided:
					params.from += params.motion
					params.motion = -step_height
					is_player_collided = PhysicsServer3D.body_test_motion(owner.get_rid(), params, test_motion_result)
					if is_player_collided:
						if test_motion_result.collision_normal.angle_to(Vector3.UP) <= deg_to_rad(STEP_MAX_SLOPE_DEGREE):
							is_step = true
							owner.global_transform.origin += -test_motion_result.motion_remainder
							break

func _physics_process(delta):
	
	if not active: return
	
	var bullet_time_active = bullet_time.active if bullet_time != null else false
	var scaled_delta = delta / Engine.time_scale if bullet_time_active else delta
	
	_apply_rotation(scaled_delta)
	
	is_step = false
	
	if owner.is_on_floor():
		
		if gravity_direction.y > 0:
			snap = Vector3.ZERO
		else:
			snap = -owner.get_floor_normal()
			gravity_direction = Vector3.ZERO
		
	else:
		snap = Vector3.DOWN
		gravity_direction = Vector3.DOWN * gravity * delta
	
	
	var new_velocity = direction * speed
	var factor

	if new_velocity.dot(owner.velocity) > 0:
		factor = accel
	else:
		factor = deaccel

	if factor > 0:
		new_velocity = owner.velocity.lerp(new_velocity, factor * scaled_delta)

	if step_check and gravity_direction.y >= 0:
		_step_check(delta, new_velocity)
	
	new_velocity += _apply_root_transform() + gravity_direction
	
	
	owner.set_velocity(new_velocity)
#	owner.set_up_direction(Vector3.UP)
#	owner.set_floor_stop_on_slope_enabled(false)
#	owner.set_max_slides(3)
#	owner.set_floor_max_angle(deg_to_rad(46))
	owner.move_and_slide()
	
	collisions = []
	var new_on_wall_count = 0

	for index in range(owner.get_slide_collision_count()):
		
		var slide = owner.get_slide_collision(index)
		
		# TODO
#		if slide.on_wall:
#			new_on_wall_count += 1
		
		collisions.append(slide)
	
	#prints(owner.get_slide_collision_count())
	
#	if new_on_wall_count != on_wall_count:
#		prints(on_wall_count, new_on_wall_count)
	
	step_check = new_on_wall_count != on_wall_count
	on_wall_count = new_on_wall_count

	emit_signal('move_and_slide', delta)
