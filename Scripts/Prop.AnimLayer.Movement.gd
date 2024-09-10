extends "res://Scripts/AnimationLoader.gd"

var stand_blendspace
var stand_idle
var stand_forward_walk
var stand_forward_run
var stand_forward_sprint
var stand_backward_walk
var stand_backward_run
var stand_backward_sprint
var stand_left_run
var stand_right_run

var crouch_blendspace
var crouch_idle
var crouch_forward
var crouch_backward
var crouch_left
var crouch_right

var target_pos = Vector2()
var x_max_value = 1
var x_min_value = -1
var y_max_value = 1
var y_min_value = -1
var x_min = -1
var y_min = -1
var x_value_range = 2
var y_value_range = 2

@export var speed = 0.0

@onready var animation_player = $AnimationPlayer
@onready var model = get_node_or_null('../Model')
@onready var locomotion = get_node_or_null('../Locomotion')

func _get_blend_point_node(blendspace, resource_name):
	
	for idx in range(blendspace.get_blend_point_count()):
		if resource_name == blendspace.get_blend_point_node(idx).resource_name:
			return blendspace.get_blend_point_node(idx)

func _add_animation(animation_name, animation_res):
	
	var library = animation_player.get_animation_library(animation_player.get_animation_library_list()[0])
	library.call('add_animation', animation_name, animation_res)

func _assign_animation(node, stance, direction):
	
	for animation_name in animation_list:

		if attributes[animation_name].stance == stance and \
			attributes[animation_name].direction == direction:

			# node.scale = scale
			# node.clip_start = clip_start
			# node.clip_end = clip_end
			node.animation = animation_name

func _set_skeleton():
	
	if model != null and model.get_child_count():
		
		var skeleton = model.get_child(0)
		animation_player.root_node = animation_player.get_path_to(skeleton)

func _enter_tree():

	set_physics_process(false)

func _ready():
	
	await get_tree().process_frame
	
	animation_list = _load_animations(schema, '', self)
	
	stand_blendspace = get('tree_root').get_blend_point_node(0)
	stand_idle = _get_blend_point_node(stand_blendspace, 'Idle')
	stand_forward_walk = _get_blend_point_node(stand_blendspace, 'ForwardWalk')
	stand_forward_run = _get_blend_point_node(stand_blendspace, 'ForwardRun')
	stand_forward_sprint = _get_blend_point_node(stand_blendspace, 'ForwardSprint')
	stand_backward_walk = _get_blend_point_node(stand_blendspace, 'BackwardWalk')
	stand_backward_run = _get_blend_point_node(stand_blendspace, 'BackwardRun')
	stand_backward_sprint = _get_blend_point_node(stand_blendspace, 'BackwardSprint')
	stand_left_run = _get_blend_point_node(stand_blendspace, 'LeftRun')
	stand_right_run = _get_blend_point_node(stand_blendspace, 'RightRun')

	crouch_blendspace = get('tree_root').get_blend_point_node(1)
	crouch_idle = _get_blend_point_node(crouch_blendspace, 'Idle')
	crouch_forward = _get_blend_point_node(crouch_blendspace, 'Forward')
	crouch_backward = _get_blend_point_node(crouch_blendspace, 'Backward')
	crouch_left = _get_blend_point_node(crouch_blendspace, 'Left')
	crouch_right = _get_blend_point_node(crouch_blendspace, 'Right')

	_assign_animation(stand_idle, 'Stand', 'Idle')
	_assign_animation(stand_forward_walk, 'Stand', 'ForwardWalk')
	_assign_animation(stand_forward_run, 'Stand', 'ForwardRun')
	_assign_animation(stand_forward_sprint, 'Stand', 'ForwardSprint')
	_assign_animation(stand_backward_walk, 'Stand', 'BackwardWalk')
	_assign_animation(stand_backward_run, 'Stand', 'BackwardRun')
	_assign_animation(stand_backward_sprint, 'Stand', 'BackwardSprint')
	_assign_animation(stand_left_run, 'Stand', 'LeftRun')
	_assign_animation(stand_right_run, 'Stand', 'RightRun')

	_assign_animation(crouch_idle, 'Crouch', 'Idle')
	_assign_animation(crouch_forward, 'Crouch', 'Forward')
	_assign_animation(crouch_backward, 'Crouch', 'Backward')
	_assign_animation(crouch_left, 'Crouch', 'Left')
	_assign_animation(crouch_right, 'Crouch', 'Right')

	_set_skeleton()

	set('active', true)
	set_physics_process(true)

func _physics_process(delta):

	if stand_blendspace == null:
		return

	var x_value = 0
	var y_value = 0
	
	x_value = locomotion.sidestep_speed
	x_value = (((x_value - x_min_value) / (x_max_value - x_min_value)) * x_value_range) + x_min
	
	y_value = locomotion.forward_speed
	y_value = (((y_value - y_min_value) / (y_max_value - y_min_value)) * y_value_range) + y_min

	target_pos = Vector2(x_value, y_value)

	for blend_position in ['parameters/0/blend_position', 'parameters/1/blend_position']:
		
		if speed > 0:

			var current_pos = get(blend_position)
			var new_pos = current_pos.lerp(target_pos, delta * speed)

			set(blend_position, new_pos)

		else:
			
			set(blend_position, target_pos)
	

