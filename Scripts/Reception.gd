extends Node

var stims = []
var stim
var data = {}
var last_node

signal stimulate

func _start_state(_name, _data={}):
	
	stim = _name
	data = _data
	
	emit_signal('stimulate', stim, data)

func _next_stim():
	
	if not stims.size():
		return
	
	var next_stim = stims.pop_front()
	
	stim = next_stim[0]
	data = next_stim[1]
	
	emit_signal('stimulate', stim, data)
	
	_next_stim()

func _reflect(reflected_stim=''):
	
	if reflected_stim == '':
		reflected_stim = stim
	
	ActorServer.Stim(data.source, reflected_stim, owner, data.intensity, data.position, data.direction * -1)
