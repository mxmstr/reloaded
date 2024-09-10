extends 'res://Scripts/Response.gd'

@onready var behavior = get_node_or_null('../../Behavior')
@onready var righthand = get_node_or_null('../../RightHandContainer')
@onready var lefthand = get_node_or_null('../../LeftHandContainer')


func _on_stimulate(stim, data):
	
	if stim == 'UseReact':
		
		var left_item
		
		if not lefthand._is_empty():
			left_item = lefthand.items[0]
		
		if data.source != left_item:
			
			behavior._start_state('UseReact')
