extends Node

const max_amount = 100
const drain_rate = 11.0
const regen_rate = 5.0#2.0
const cooldown_time = 3.0

var locked = false
var active = false
var cooldown = false
var amount = 100.0 : set = _set_amount

@onready var bullet_time_server = get_node_or_null('/root/Mission/Links/BulletTimeServer')
@onready var perspective_anim_player = $'../Perspective/AnimationPlayer'
@onready var ui_audio = $'../UIAudio'

signal amount_changed


func _set_amount(new_amount):
	
	amount = clamp(new_amount, 0, max_amount)
	
	emit_signal('amount_changed', amount)


func _input_start():
	
	if not locked:
		_start()


func _start():
	
	if cooldown:
		return
	
	active = true
	perspective_anim_player.play('BulletTime')
	ui_audio._start_state('BulletTimeStart')
	bullet_time_server._start(owner)


func _input_stop():
	
	if not locked:
		_stop()


func _stop():
	
	active = false
	perspective_anim_player.play('Default')
	ui_audio._start_state('BulletTimeEnd')
	bullet_time_server._stop(owner)


func _cooldown():
	
	cooldown = true
	
	get_tree().create_timer(cooldown_time).connect('timeout',Callable(self,'set').bind('cooldown', false))


func _ready():
	
	_set_amount(max_amount)


func _process(delta):
	
	if active:
		
		_set_amount(amount - (drain_rate * delta / Engine.time_scale))

		if amount == 0:
			_stop()
			_cooldown()
	
	elif not cooldown:
		
		_set_amount(amount + (regen_rate * delta / Engine.time_scale))
