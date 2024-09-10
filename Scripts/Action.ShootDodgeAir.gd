extends "res://Scripts/Action.8Way.gd"

func _process(delta):
	
	if get_parent().current_state == state:
		
		_set_blendspace_position()
