extends "res://Scripts/Input.gd"

@onready var locomotion = get_node_or_null('../../Locomotion')

func _on_just_activated():

	locomotion.sidestep_speed = strength

func _on_active():
	
	locomotion.sidestep_speed = strength

