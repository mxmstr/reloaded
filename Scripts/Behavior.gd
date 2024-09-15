extends Node

@export var default_state = 'Default'

var enable_abilities = true
var current_state = 'Default'
var data = {}
var next = 'Default'
var switch_mode = 'Immediate'
var clip_start = 0
var clip_end = 0
var scale = 1.0
var priority = 0
var endless = false
var finished = true

var skeleton

@onready var animation_player = $AnimationPlayer
@onready var model = get_node_or_null('../Model')

signal action_started
signal state_started
signal on_physics_process
signal on_process

func _is_action_playing():
	
	return call('is_playing')

func _can_switch(new_priority, override):
	
	return override or \
		not _is_action_playing() or \
		new_priority > priority or \
		(new_priority == priority and switch_mode == 'Immediate')

func _on_action_finished(animation_name=null):
	
	finished = true
	
	if endless:
		return
	
	if next == 'Default':
		call_deferred('emit_signal', 'action_started', next, {})
	else:
		call_deferred('emit_signal', 'action_started', next, data)

func _start_state(_name, _data={}):
	
	if not enable_abilities:
		return
	
	emit_signal('action_started', _name, _data)

func _add_animation(animation_name, animation_res):
	
	var library = call('get_animation_library', call('get_animation_library_list')[0])
	library.call('add_animation', animation_name, animation_res)

func _set_animation(animation, scale, clip_start, clip_end):
	
	call('play', animation, -1, scale)

func _play(new_state, animation, _data, up_animation=null, down_animation=null):
	
	current_state = new_state
	data = _data
	
	emit_signal('state_started', new_state)
	
	if current_state == 'Default':
		return true
	
	_set_animation(animation, scale, clip_start, clip_end)
	
	return true

func _set_skeleton():
	
	if model and model.get_child_count():
		
		skeleton = model.get_child(0)
		set('root_node', get_path_to(skeleton))
	
	connect('animation_finished',Callable(self,'_on_action_finished'))

func _ready():
	
#	if not is_instance_valid(self):
#		return
	
	call_deferred('_set_skeleton')
	
	#await get_tree().process_frame
	
	call_deferred('emit_signal', 'action_started', default_state, {})

func _physics_process(delta):
	
	emit_signal('on_physics_process', delta)

func _process(delta):
	
	emit_signal('on_process', delta)
