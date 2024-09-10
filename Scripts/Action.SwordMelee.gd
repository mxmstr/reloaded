extends "res://Scripts/Action.Human.gd"

func _on_action(_state, data):
	
	if _state == 'SwordMelee':
		
		_play(_state, animation_list[0])
		_randomize_animation()
