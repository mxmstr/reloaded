extends "res://Scripts/AnimationLoader.gd"

@export var state: String

var new_state = ''

func _ready():
	
	await super()
	
	get_parent().connect('action_started',Callable(self,'_on_action'))

func _on_action(_state, data): 
	
	new_state = _state
	
	if new_state == state:
		
		get_parent().current_state = state
		get_parent().priority = 2
		get_parent().endless = true
		get_parent().camera_mode._start_state('Default')
		get_parent().hud_mode._start_state('Victory')
