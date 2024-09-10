extends "res://Scripts/Action.8Way.gd"

const test_off_wall_time = 0.25

var active = false
var test_off_wall = false

func _on_test_off_wall_timeout():
	
	if not owner.is_on_wall():
		
		get_parent()._start_state('Default')
		locomotion.mode = locomotion.Mode.DEFAULT
		active = false
	
	test_off_wall = false

func _on_action(_state, _data):
	
	if _state == state:
		
		if not _play(_state, null):
			return
		
		data = _data
		locomotion.surface = locomotion.SurfaceType.WALL
		locomotion.wall_normal = data.normal
		active = true
	
	elif _state == 'WallRunEnd':
		
		if get_parent().current_state == state:
			
			get_parent()._start_state('Default', { 'override': true })
			locomotion.surace = locomotion.SurfaceType.FLOOR
			active = false
			test_off_wall = false

func _set_blendspace_position():
	
	var x_value = locomotion.wall_sidestep_speed
	var x_max_value = 1
	var x_min_value = -1
	x_value = (((x_value - x_min_value) / (x_max_value - x_min_value)) * x_value_range) + x_min
	
	var y_value = locomotion.wall_forward_speed
	var y_max_value = 1
	var y_min_value = -1
	y_value = (((y_value - y_min_value) / (y_max_value - y_min_value)) * y_value_range) + y_min
	
	get_parent().set('parameters/BlendSpace2D/blend_position', Vector2(x_value, y_value))

func _process(delta):
	
	if get_parent().current_state == state:
		
		_set_blendspace_position()
		
		if not owner.is_on_wall() and not test_off_wall:
			
			get_tree().create_timer(test_off_wall_time).connect('timeout',Callable(self,'_on_test_off_wall_timeout'))
			test_off_wall = true
