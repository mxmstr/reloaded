extends 'res://Scripts/AnimationLoader.gd'

@export var start: String
@export_multiline var statemachine_attributes

var next


func _on_animation_finished(current):
	
	if next:
		
		_play(next)
		next = null


func _ready():
	
	var test_json_conv = JSON.new()
	test_json_conv.parse(statemachine_attributes)
	attributes = test_json_conv.get_data()
	
	for animation_name in call('get_animation_list'):
		
		if attributes:
		
			if not attributes.has(animation_name):
				attributes[animation_name] = {}
			
			if '*' in attributes.keys():
				Meta._merge_dir(attributes[animation_name], attributes['*'])
		
		else:
			
			attributes[animation_name] = {}
	
	
	connect('animation_finished',Callable(self,'_on_animation_finished'))
	
	if start != '':
		_start_state(start)


func _play(_animation):

	var anim_attr = attributes[_animation]

	var speed = 1.0
	var blend = -1.0
	var clip_start = 0
	var clip_end = 0

	if anim_attr.has('speed'):
		speed = anim_attr.speed

	if anim_attr.has('blend'):
		blend = anim_attr.blend

	if anim_attr.has('clip_start'):
		clip_start = anim_attr.clip_start

	if anim_attr.has('clip_end'):
		clip_end = anim_attr.clip_end

	call('play', _animation, blend, speed)

	if random:
		_randomize_animation()


func _start_state(_name, _data={}):
	
	if get('assigned_animation').length() and attributes[get('assigned_animation')].has('next'):
		
		next = _name
		_play(attributes[get('assigned_animation')].next)
		
		return
	
	_play(_name)
