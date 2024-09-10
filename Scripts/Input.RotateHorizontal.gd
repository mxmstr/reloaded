extends 'res://Scripts/Input.Rotate.gd'

@onready var bullet_time = get_node_or_null('../../BulletTime')

func _get_aim_offset(delta):

	var rotation_offset = camera_raycast.rotation_offset.x if camera_raycast != null else 0.0
	
	if owner.is_processing_input():
		
		var fov = camera.fov if camera != null else 65
		var aim_offset = Vector2((-right.strength + left.strength) * aim_offset_range * (fov / 65), 0)

		return Vector2(rotation_offset, 0).lerp(
			aim_offset,
			aim_offset_sensitivity * delta
			).x

	else:

		return 0.0

func _process(delta):
	
	var scaled_delta = delta / Engine.time_scale if bullet_time != null and bullet_time.active else delta
	var rotation_offset = camera_raycast.rotation_offset.x if camera_raycast != null else 0.0

	var speed = -1 * _get_rotation(scaled_delta)
	locomotion.turn_speed = speed
	rotation_offset = _get_aim_offset(scaled_delta)
