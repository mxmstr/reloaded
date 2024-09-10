extends 'res://Scripts/Response.gd'

@onready var audio = get_node_or_null('../../Audio')

func _on_stimulate(stim, data):
	
	if stim == 'Touch':
		
		if data.source._has_tag('Map'):
			
			if data.intensity > 1.5:
				audio._start_state('Impact')
