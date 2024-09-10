extends 'res://Scripts/Response.gd'

@onready var behavior = get_node_or_null('../../Behavior')
@onready var right_hand = get_node_or_null('../../RightHandContainer')
@onready var inventory = get_node_or_null('../../Inventory')


func _on_stimulate(stim, data):
	
	if stim == 'EmptyReact':
		
		if not right_hand._is_empty() and data.source == right_hand.items[0]:
			
			behavior._start_state('Reload')
			
			if behavior.current_state != 'Reload':
				inventory._next(true, true)
				
				if right_hand._is_empty():
					inventory._next(false, true)
				
#				if right_hand._is_empty():
#					inventory._go_to_unarmed()
