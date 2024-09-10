extends Node

@onready var forward = get_node_or_null('../MoveForwardInput')
@onready var backward = get_node_or_null('../MoveBackwardInput')
@onready var locomotion = get_node_or_null('../../Locomotion')

func _process(delta):
	
	if not forward.active and not backward.active:
		
		locomotion.forward_speed = 0.0
