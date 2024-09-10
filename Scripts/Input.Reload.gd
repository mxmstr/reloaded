extends "res://Scripts/Input.gd"

@onready var behavior = get_node_or_null('../../Behavior')

func _on_just_activated(): 
	
	behavior._start_state('Reload')
