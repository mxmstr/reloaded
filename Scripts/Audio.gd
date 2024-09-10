extends Node3D

@export var default_state = 'Default'
@export var bus: String
@export var level_modifier = 0.0
@export var time_scaled = true

var switch_mode = 'Immediate'

@onready var animation_player = $AnimationPlayer
@onready var audio_stream = $AudioStreamPlayer3D

signal action_started

var current_state = ''

func _on_bullet_time_started():
	
	if time_scaled:
		audio_stream.pitch_scale = Engine.time_scale

func _on_bullet_time_ended():
	
	audio_stream.pitch_scale = 1.0

func _start_state(_name, _data={}):
	
	emit_signal('action_started', _name, _data)

func _can_switch():
	
	return switch_mode == 'Immediate' or not animation_player.is_playing()

func _add_animation(animation_name, animation_res):
	
	var library = animation_player.get_animation_library(animation_player.get_animation_library_list()[0])
	library.add_animation(animation_name, animation_res)

func _play(new_state, animation, attributes, _data):
	
	if not _can_switch():
		return
	
	current_state = new_state
	
	var level = 0
	var scale = 1.0
	var clip_start = 0
	var clip_end = 0
	switch_mode = 'Immediate'
	
	if attributes.has('level'):
		level = attributes.level
	
	if attributes.has('speed'):
		scale = attributes.speed
	
	if attributes.has('clip_start'):
		clip_start = attributes.clip_start
	
	if attributes.has('clip_end'):
		clip_end = attributes.clip_end
	
	if attributes.has('switch_mode'):
		switch_mode = attributes.switch_mode
	
	audio_stream.volume_db = level + level_modifier
	animation_player.stop()
	animation_player.play(animation, -1, scale)

func _on_ressurected():
	
	call_deferred('emit_signal', 'action_started', default_state, {})

func _ready():
	
	owner.connect('ressurected',Callable(self,'_on_ressurected'))
	
	BulletTimeServer.connect('started',Callable(self,'_on_bullet_time_started'))
	BulletTimeServer.connect('ended',Callable(self,'_on_bullet_time_ended'))
	
	audio_stream.bus = bus
	audio_stream.pitch_scale = Engine.time_scale
	
	await get_tree().process_frame
	
	call_deferred('emit_signal', 'action_started', default_state, {})
