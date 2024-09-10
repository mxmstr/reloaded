extends "res://Scripts/Input.gd"

func _on_just_activated(): 
	
	if bullet_time.active:
		bullet_time._input_stop()
	else:
		bullet_time._input_start()

func _process(delta):
	
	super(delta)
	
	if not owner.is_processing_input():
		
		if bullet_time.active:
			bullet_time._input_stop()
