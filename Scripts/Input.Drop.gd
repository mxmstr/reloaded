extends "res://Scripts/Input.gd"

@onready var right_hand = get_node_or_null('../../RightHandContainer')
@onready var left_hand = get_node_or_null('../../LeftHandContainer')
@onready var behavior = get_node_or_null('../../Behavior')

func _on_just_activated(): 
	
	left_hand._release_front()
	right_hand._release_front()
	behavior._start_state('Default')
