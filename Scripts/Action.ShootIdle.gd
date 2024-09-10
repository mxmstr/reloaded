extends "res://Scripts/Action.Human.gd"

const item_names = ['Beretta', 'Colt', 'DesertEagle', 'Ingram', 'Jackhammer', 'M79', 'MP5', 'PumpShotgun', 'SawedoffShotgun', 'Sniper', 'Grenade']
const dual_wield_items = ['Beretta', 'DesertEagle', 'Ingram', 'SawedoffShotgun']

var shoot_idle_animations = {}
var shoot_dual_idle_animations = {}

@onready var righthand = get_node_or_null('../../RightHandContainer')
@onready var lefthand = get_node_or_null('../../LeftHandContainer')
@onready var camera_raycast = get_node_or_null('../../CameraRig/Camera3D')
@onready var camera_raycast_target = get_node_or_null('../../CameraRaycastStim/Target')

func _ready():
	
	await get_tree().process_frame
	get_parent().connect('action_started',Callable(self,'_on_action'))
	
	for item_name in item_names:
		
		shoot_idle_animations[item_name] = _load_animations(schema + item_name + 'Idle', item_name + '_')
		
		if item_name in dual_wield_items:
			shoot_dual_idle_animations[item_name] = _load_animations(schema + item_name + 'DualIdle', item_name + 'Dual_')

func _play_idle_action():

	if righthand._is_empty():
		return false
	
	var right_name = righthand.items[0].base_name
	var left_name = ''
	
	lefthand.items.size()
	if not lefthand._is_empty():
		left_name = lefthand.items[0].base_name
	
	var dual_wielding = right_name in dual_wield_items and right_name == left_name
	
	if not shoot_idle_animations.has(right_name):
		return false
		
	var animation_list
	var prefix
	
	if dual_wielding:
		animation_list = shoot_dual_idle_animations[right_name]
		prefix = right_name + 'Dual_'
	else:
		animation_list = shoot_idle_animations[right_name]
		prefix = right_name + '_'
	
	if animation_list.size() == 3:
		return _play(state, animation_list[0], prefix, animation_list[1], animation_list[2])
	else:
		return _play(state, animation_list[0], prefix)

func _on_action(_state, _data):
	
	new_data = _data
	
	if _state == state and _play_idle_action():
		
		data = new_data
		
		if not get_parent().is_connected('state_started',Callable(self,'_on_state_started')):
			get_parent().connect('state_started',Callable(self,'_on_state_started'))
		
		_state_start()

func _process(delta):
	
	if righthand._has_item_with_tag('Firearm'):
		if get_parent().current_state == 'Default':
			_on_action(state, {})
	else:
		if get_parent().current_state == state:
			get_parent()._start_state('Default')
		
	if get_parent().current_state in [state]:
		
		var target_pos = camera_raycast_target.global_transform.origin
		var look_direction = camera_raycast.global_transform.origin.direction_to(target_pos).normalized()
		var look_angle = Vector3(0, -1, 0).angle_to(look_direction)
		
		get_parent()._set_action_blend((rad_to_deg(look_angle) - 90) / 90)
