extends "res://Scripts/Action.8Way.gd"

func _state_end():
	
	locomotion.stance = locomotion.StanceType.STANDING

func _process(delta):
	
	if get_parent().current_state == state:
		
		_set_blendspace_position()
		
		if get_parent().finished and (abs(get_parent().forward_speed) > 0.1 or abs(get_parent().sidestep_speed) > 0.1):
			
			get_parent()._start_state('Default', { 'override': true })
