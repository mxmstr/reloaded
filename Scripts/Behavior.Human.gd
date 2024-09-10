extends "res://Scripts/Behavior.gd"

enum Mode {
	OneShot,
	EightWay
}

const torso_bone = 'Torso'
const upper_body_bones = ['shoulders', 'Neck', 'Head', 'UpArm-L', 'UpArm-R', 'LoArm-L', 'LoArm-R', 'Hand-L', 'Hand-R', 'Gun']
const left_arm_root = 'UpArm-L'
const left_arm_bones = ['LoArm-L', 'Hand-L']
const right_arm_root = 'UpArm-R'
const right_arm_bones = ['LoArm-R', 'Hand-R', 'Gun']
const blend_time_max = 0.05

var arms_only = false
var layer = Meta.BlendLayer.MOVEMENT : set = _set_layer
var can_use_item = false
var can_zoom = false
var root_motion_use_model = false
var cached_action_pose
var cached_blend_pose
var blend_time = 0

var one_shot
var action
var action_up
var action_down
var transition
var blend_space_2d
var blend_space_up
var blend_space_upright
var blend_space_right
var blend_space_downright
var blend_space_down
var blend_space_downleft
var blend_space_left
var blend_space_upleft

@onready var camera_rig = get_node_or_null('../CameraRig')
@onready var camera = get_node_or_null('../CameraRig/Camera3D')
@onready var anim_layer_movement = get_node_or_null('../AnimLayerMovement')
@onready var bullet_time = get_node_or_null('../BulletTime')

signal pre_advance
signal post_advance

func _is_action_playing():
	
	return true if endless else not finished

func _set_layer(_layer):
	
	layer = _layer
	
	blend_time = blend_time_max
	_cache_blend_pose()

func _set_oneshot_active(enabled):
	
	set('parameters/OneShot/active', enabled)
	set('parameters/OneShot/request', 
		AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE if enabled else AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT
		)

func _set_action_blend(blend):
	
	set('parameters/ActionBlend/blend_amount', blend)

func _add_animation(animation_name, animation_res):
	
	var library = animation_player.get_animation_library(animation_player.get_animation_library_list()[0])
	library.add_animation(animation_name, animation_res)

func _set_animation(animation, scale, clip_start, clip_end):
	
	action.scale = scale
	action.clip_start = clip_start
	action.clip_end = clip_end
	action.animation = animation

func _set_animation_up(animation, scale, clip_start, clip_end):
	
	action_up.scale = scale
	action_up.clip_start = clip_start
	action_up.clip_end = clip_end
	action_up.animation = animation

func _set_animation_down(animation, scale, clip_start, clip_end):
	
	action_down.scale = scale
	action_down.clip_start = clip_start
	action_down.clip_end = clip_end
	action_down.animation = animation

func _cache_action_pose():
	
	cached_action_pose = []
	
	for idx in range(skeleton.get_bone_count()):
		
		var bone_name = skeleton.get_bone_name(idx)
		
		if arms_only:
			
			if bone_name in [left_arm_root, right_arm_root]:
				cached_action_pose.append(skeleton.get_bone_global_pose_no_override(idx))
			else:
				cached_action_pose.append(skeleton.get_bone_pose(idx))
		
		else:
			
			if bone_name == torso_bone:
				cached_action_pose.append(skeleton.get_bone_global_pose_no_override(idx))
			else:
				cached_action_pose.append(skeleton.get_bone_pose(idx))

func _cache_blend_pose():
	
	cached_blend_pose = []
	
	for idx in range(skeleton.get_bone_count()):
		
		var bone_name = skeleton.get_bone_name(idx)
		
		if bone_name == torso_bone:
			cached_blend_pose.append(skeleton.get_bone_global_pose_no_override(idx))
		else:
			cached_blend_pose.append(skeleton.get_bone_pose(idx))

func _apply_action_pose():
	
	for idx in range(skeleton.get_bone_count()):
		
		var bone_name = skeleton.get_bone_name(idx)
		
		if arms_only:
			
			if bone_name in [left_arm_root, right_arm_root]:

				var global_pose = skeleton.get_bone_global_pose_no_override(idx)
				cached_action_pose[idx] = Transform3D(cached_action_pose[idx].basis, global_pose.origin)

				skeleton.set_bone_global_pose_override(idx, cached_action_pose[idx], 1.0, true)

			elif bone_name in left_arm_bones + right_arm_bones:
				
				skeleton.set_bone_pose_position(idx, cached_action_pose[idx].origin)
				skeleton.set_bone_pose_rotation(idx, cached_action_pose[idx].basis.get_rotation_quaternion())
				skeleton.set_bone_pose_scale(idx, cached_action_pose[idx].basis.get_scale())
		
		else:
			
			if bone_name == torso_bone:
				
				var global_pose = skeleton.get_bone_global_pose_no_override(idx)
				cached_action_pose[idx] = Transform3D(cached_action_pose[idx].basis, global_pose.origin)
				skeleton.set_bone_global_pose_override(idx, cached_action_pose[idx], 1.0, true)
			
			elif bone_name in upper_body_bones:
				
				skeleton.set_bone_pose_position(idx, cached_action_pose[idx].origin)
				skeleton.set_bone_pose_rotation(idx, cached_action_pose[idx].basis.get_rotation_quaternion())
				skeleton.set_bone_pose_scale(idx, cached_action_pose[idx].basis.get_scale())

func _apply_blend_pose():
	
	if blend_time == 0:
		return
	
	for idx in range(skeleton.get_bone_count()):
		
		var bone_name = skeleton.get_bone_name(idx)
		
		if bone_name == torso_bone:

			var global_pose = skeleton.get_bone_global_pose_no_override(idx)
			cached_blend_pose[idx] = Transform3D(cached_blend_pose[idx].basis, global_pose.origin)
			global_pose = global_pose.interpolate_with(cached_blend_pose[idx], blend_time / blend_time_max)
			skeleton.set_bone_global_pose_override(idx, global_pose, 1.0, true)

		elif bone_name in upper_body_bones:
			
			var pose = skeleton.get_bone_pose(idx)
			pose = pose.interpolate_with(cached_blend_pose[idx], blend_time / blend_time_max)
			skeleton.set_bone_pose_position(idx, pose.origin)
			skeleton.set_bone_pose_rotation(idx, pose.basis.get_rotation_quaternion())
			skeleton.set_bone_pose_scale(idx, pose.basis.get_scale())
	
	blend_time = clamp(blend_time - get_process_delta_time(), 0, blend_time_max)

func _play(new_state, animation, _data, up_animation=null, down_animation=null):
	
	current_state = new_state
	data = _data
	
	if up_animation == null and down_animation == null:
		_set_action_blend(0)
	
	# _set_oneshot_active(false)
	# call('advance', 0)
	# _set_oneshot_active(true)
	
	if not one_shot.is_connected('finished',Callable(self,'_on_action_finished')):
		one_shot.connect('finished',Callable(self,'_on_action_finished'))
	
#	if blend_space_2d.is_connected('finished',Callable(self,'_on_action_finished')):
#		blend_space_2d.disconnect('finished',Callable(self,'_on_action_finished'))
	
	set('parameters/Transition/current', Mode.OneShot)
	
	emit_signal('state_started', new_state)
	
	if current_state == 'Default':
		return true
	
	_set_animation(animation, scale, clip_start, clip_end)
	
	if up_animation:
		_set_animation_up(up_animation, action.scale, action.clip_start, action.clip_end)
	else:
		_set_animation_up('DefaultAnim', action.scale, action.clip_start, action.clip_end)
	
	if down_animation:
		_set_animation_down(down_animation, action.scale, action.clip_start, action.clip_end)
	else:
		_set_animation_down('DefaultAnim', action.scale, action.clip_start, action.clip_end)
	
	_set_oneshot_active(true)

	return true

func _play_8way(new_state, animation_list, _data):
	
	current_state = new_state
	data = _data
	
	_set_action_blend(0)
	_set_oneshot_active(false)
	call('advance', 0)
	
	if one_shot.is_connected('finished',Callable(self,'_on_action_finished')):
		one_shot.disconnect('finished',Callable(self,'_on_action_finished'))
	
	if not blend_space_2d.is_connected('finished',Callable(self,'_on_action_finished')):
		blend_space_2d.connect('finished',Callable(self,'_on_action_finished'))
	
	var animation_nodes = [
		blend_space_up,
		blend_space_upright,
		blend_space_right,
		blend_space_downright,
		blend_space_down,
		blend_space_downleft,
		blend_space_left,
		blend_space_upleft
		]
	
	for idx in range(8):
		animation_nodes[idx].scale = scale
		animation_nodes[idx].clip_start = clip_start
		animation_nodes[idx].clip_end = clip_end
		animation_nodes[idx].animation = animation_list[idx]
	
#	if current_state == 'Default':
#		return true
	
	set('parameters/Transition/current', Mode.EightWay)
	
	return true

func _offset_camera_rig():
	
	var offset_angle = Vector3.BACK.angle_to(model.transform.basis.z)
	
	if Vector3.RIGHT.angle_to(model.transform.basis.z) > PI / 2:
		offset_angle *= -1
	
	camera_rig.transform.origin = camera_rig.transform.origin.rotated(
		Vector3.UP, 
		offset_angle
		)

func _get_blend_point_node(direction):
	
	for idx in range(blend_space_2d.get_blend_point_count()):
		if direction == blend_space_2d.get_blend_point_node(idx).resource_name:
			return blend_space_2d.get_blend_point_node(idx)

func _set_skeleton():
	
	if model != null and model.get_child_count():
		
		skeleton = model.get_child(0)
		animation_player.root_node = animation_player.get_path_to(skeleton)
		
		set('root_motion_track', NodePath('../../'))

func _ready():
	
	super()
	
	set_physics_process(false)
	
	await get_tree().process_frame
	
	set('tree_root', get('tree_root').duplicate(true))
	
	one_shot = get('tree_root').get_node('OneShot')
	action = get('tree_root').get_node('Action')
	transition = get('tree_root').get_node('Transition')
	action_up = get('tree_root').get_node('ActionUp')
	action_down = get('tree_root').get_node('ActionDown')
	blend_space_2d = get('tree_root').get_node('BlendSpace2D')
	blend_space_up = _get_blend_point_node('Forward')
	blend_space_upright = _get_blend_point_node('ForwardRight')
	blend_space_right = _get_blend_point_node('Right')
	blend_space_downright = _get_blend_point_node('BackwardRight')
	blend_space_down = _get_blend_point_node('Backward')
	blend_space_downleft = _get_blend_point_node('BackwardLeft')
	blend_space_left = _get_blend_point_node('Left')
	blend_space_upleft = _get_blend_point_node('ForwardLeft')
		
	var anim_layer_player = anim_layer_movement.get_node('AnimationPlayer')
	var library = animation_player.get_animation_library('')
	
	for animation in anim_layer_player.get_animation_list():
		library.add_animation(animation, anim_layer_player.get_animation(animation))
	
	anim_layer_movement.active = true
		
	set('active', true)
	set_physics_process(true)

func _physics_process(delta):
	
	super(delta)
	
	emit_signal('pre_advance', delta)

	var is_action = layer == Meta.BlendLayer.ACTION
	var is_movement = layer == Meta.BlendLayer.MOVEMENT
	var is_mixed = layer == Meta.BlendLayer.MIXED
	
	if is_action or is_movement:
		skeleton.clear_bones_global_pose_override()

	if not is_movement:

		call('advance', delta)
		#actor_physics.call_deferred('_apply_root_transform', call('get_root_motion_transform'), delta)
		
		if is_mixed:
			_cache_action_pose()

	if not is_action:
		anim_layer_movement.advance(delta)
	
	if is_mixed:
		_apply_action_pose()
	
	#_apply_blend_pose()
	
	#skeleton.scale = Vector3(-1, -1, -1)
	
#	if root_motion_use_model:
#		call_deferred('_offset_camera_rig')
	
	emit_signal('post_advance', delta)
