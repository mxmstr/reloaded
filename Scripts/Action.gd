extends "res://Scripts/AnimationLoader.gd"

@export var state: String

@export var enable_abilities = true
@export var next = 'Default'
@export var switch_mode = 'Immediate'
@export var priority = 0
@export var endless = false

var data = {}
var new_data = {}

func _ready():
	
	await super()
	
	get_parent().connect('action_started',Callable(self,'_on_action'))

func _can_switch(new_priority, override):
	
	return override or \
		not get_parent()._is_action_playing() or \
		new_priority > get_parent().priority or \
		(new_priority == get_parent().priority and get_parent().switch_mode == 'Immediate')

func _apply_attributes(attributes):
	
	var override = attributes.has('override')
	var new_priority = attributes.priority if attributes.has('priority') else 0
	
	if not _can_switch(new_priority, override):
		return false
	
	get_parent().clip_start = 0
	get_parent().clip_end = 0
	get_parent().scale = 1.0
	get_parent().finished = false
	
	if attributes.has('speed'):
		get_parent().scale = attributes.speed
	
	if attributes.has('clip_start'):
		get_parent().clip_start = attributes.clip_start
	
	if attributes.has('clip_end'):
		get_parent().clip_end = attributes.clip_end
	
	get_parent().enable_abilities = enable_abilities
	get_parent().next = next
	get_parent().switch_mode = switch_mode
	get_parent().endless = endless

	return true

func _play(_state, _animation, _attributes_prefix='', _down=null, _up=null):
	
	var attributes_name = _attributes_prefix + _animation
	var attributes_cloned = attributes[attributes_name].duplicate()
	
	if new_data.has('override'):
		attributes_cloned.override = true
	
	if not _apply_attributes(attributes_cloned):
		return false
	
	var result
	
	if _up and _down:
		result = get_parent()._play(_state, _animation, new_data, _up, _down)
	else:
		result = get_parent()._play(_state, _animation, new_data)
	
	if random:
		_randomize_animation()

	return result

func _state_start(): pass

func _state_end(): pass

func _on_state_started(new_state):
	
	if new_state != state:
		
		_state_end()
		
		get_parent().disconnect('state_started',Callable(self,'_on_state_started'))

func _on_action(_state, _data):
	
	new_data = _data
	
	if _state == state and _play(state, animation_list[0]):
		
		data = new_data
		
		if not get_parent().is_connected('state_started',Callable(self,'_on_state_started')):
			get_parent().connect('state_started',Callable(self,'_on_state_started'))
		
		_state_start()
