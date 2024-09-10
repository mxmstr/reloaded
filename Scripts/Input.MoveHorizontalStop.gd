extends Node

@onready var right = get_node_or_null('../MoveRightInput')
@onready var left = get_node_or_null('../MoveLeftInput')
@onready var locomotion = get_node_or_null('../../Locomotion')

func _process(delta):
	
	if not right.active and not left.active:
		
		locomotion.sidestep_speed = 0.0
