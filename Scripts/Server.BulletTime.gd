extends Node

const time_scale = 0.25

var users = []

signal started
signal ended

func _exit_tree():
	
	Engine.time_scale = 1.0

func _start(user):
	
	if not user in users:
		users.append(user)
	
	Engine.time_scale = time_scale
	
	emit_signal('started')

func _stop(user):
	
	users.erase(user)
	
	if users.is_empty():
		
		Engine.time_scale = 1.0
		
		emit_signal('ended')
