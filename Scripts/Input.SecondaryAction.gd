extends "res://Scripts/Input.gd"

@onready var behavior = get_node_or_null('../../Behavior')
@onready var forward = get_node_or_null('../MoveForwardInput')
@onready var backward = get_node_or_null('../MoveBackwardInput')
@onready var right = get_node_or_null('../MoveRightInput')
@onready var left = get_node_or_null('../MoveLeftInput')

func _on_just_activated():
	
	var vertical = forward.strength + backward.strength
	var horizontal = left.strength + right.strength
	var action
	
	if horizontal > 0.1:
		action = 'KickForwardLeft'
	elif horizontal < -0.1:
		action = 'KickForwardRight'
	else:
		action = 'KickForward'
	
	behavior._start_state(action)
