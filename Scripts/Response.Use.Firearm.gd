extends 'res://Scripts/Response.gd'

@onready var audio = get_node_or_null('../../Audio')
@onready var behavior = get_node_or_null('../../Behavior')
@onready var chamber = get_node_or_null('../../Chamber')
@onready var magazine = get_node_or_null('../../Magazine')

func _on_stimulate(stim, data):
	
	if stim == 'Use':
		
		if not chamber._is_empty():
			behavior._start_state(owner._get_tag('UseAction'))
		
		elif magazine._is_empty():
			audio._start_state('Empty')
			ActorServer.Stim(data.source, 'EmptyReact', owner)
