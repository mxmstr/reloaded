extends "res://Scripts/Action.Human.gd"

const item_names = ['Beretta', 'Colt', 'DesertEagle', 'Ingram', 'Jackhammer', 'M79', 'MP5', 'PumpShotgun', 'SawedoffShotgun', 'Sniper']
const dual_wield_items = ['Beretta', 'DesertEagle', 'Ingram', 'SawedoffShotgun']

var animations = {}
var dual_animations = {}

@onready var righthand = get_node_or_null('../../RightHandContainer')
@onready var lefthand = get_node_or_null('../../LeftHandContainer')
@onready var camera_raycast = get_node_or_null('../../CameraRig/Camera3D')
@onready var camera_raycast_target = get_node_or_null('../../CameraRaycastStim/Target')

func _play_reload_sound():
	
	if righthand._is_empty(): return
	
	righthand.items[0].get_node('Audio')._start_state('Reload')

func _is_container(node):
	
	if node.get_script() != null:
		var script_name = node.get_script().get_path().get_file()
		return script_name == 'Prop.Container.gd'
	
	return false

func _can_transfer_items_to(to):
	
	for prop in owner.get_children():
		
		if _is_container(prop):
			
			if prop._is_empty(): continue
			var valid = true
			
			for required_tag in to.required_tags_dict.keys():
				if not required_tag in prop.required_tags_dict.keys():
					valid = false
					break
			
			if valid: return true
	
	return false

func _transfer_items_to(to, limit=0):
	
	var from_container
	var best_tag_count = 0
	
	for prop in owner.get_children():
		
		if _is_container(prop):
			
			var tag_count = 0
			
			for required_tag in to.required_tags_dict.keys():
				if required_tag in prop.required_tags_dict.keys():
					tag_count += 1
			
			if tag_count > best_tag_count:
				from_container = prop
				best_tag_count = tag_count
		
	if from_container and to.factory_mode:
		
		var count = 0
		
		while not to._is_full() and from_container.items.size():
			
			var item = from_container._release_front()
			to._add_item(item)
			count += 1
			
			if limit > 0 and count == limit: break
		
		return from_container.items.size()
	
	return 0

func _load_magazine(item):
	
	var magazine = item.get_node('Magazine')
	var chamber = item.get_node('Chamber')
	var limit = 0 if chamber._is_empty() else max(magazine.max_quantity - 1, 0)
	
	_transfer_items_to(magazine, limit)

func _load_righthand_magazine():
	
	if righthand._is_empty() or not righthand.items[0].has_node('Magazine'): return
	
	_load_magazine(righthand.items[0])

func _load_lefthand_magazine():
	
	if lefthand._is_empty() or not lefthand.items[0].has_node('Magazine'): return
	
	_load_magazine(lefthand.items[0])

func _load_shotgun_shell():
	
	var item = righthand.items[0]
	var magazine = righthand.items[0].get_node('Magazine')
	
	var remaining = _transfer_items_to(magazine, 1)
	var is_full = magazine._is_full()
	var item_name = item.base_name
	
	if animations.has(item_name) and not is_full and remaining > 0:
		_play(state, animations[item_name][0], item_name + '_')

func _ready():
	
	await get_tree().process_frame
	get_parent().connect('action_started',Callable(self,'_on_action'))
	
	for item_name in item_names:

		animations[item_name] = _load_animations(schema + item_name, item_name + '_')
		
		if item_name in dual_wield_items:
			dual_animations[item_name] = _load_animations(schema + item_name + 'Dual', item_name + 'Dual_')
	
func _play_reload_action():

	if righthand._has_item_with_tag('Firearm'):
		
		var right_name = righthand.items[0].base_name
		var left_name = '' if lefthand._is_empty() else lefthand.items[0].base_name
		
		var item_name = righthand.items[0].base_name
		var chamber = righthand.items[0].get_node('Chamber')
		var magazine = righthand.items[0].get_node('Magazine')
		var is_full = magazine.max_quantity <= magazine.items.size() + (0 if chamber._is_empty() else 1)
		
		if animations.has(item_name) and not is_full and _can_transfer_items_to(magazine):
			if right_name in dual_wield_items and right_name == left_name:
				_play(state, dual_animations[right_name][0], item_name + 'Dual_')
			else:
				_play(state, animations[item_name][0], item_name + '_')

func _on_action(_state, _data):
	
	new_data = _data
	
	if _state == state and _play_reload_action():
		
		data = new_data
		
		if not get_parent().is_connected('state_started',Callable(self,'_on_state_started')):
			get_parent().connect('state_started',Callable(self,'_on_state_started'))
		
		_state_start()
