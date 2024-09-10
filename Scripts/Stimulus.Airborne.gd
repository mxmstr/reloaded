extends Node

@export var delay = 1.0
@export var min_fall_speed = 1.0

var timer


func _on_timeout():
	
	#if get_parent().has_node('Receptor'):
	#	get_parent().get_node('Receptor')._start_state('Airborne')
	
	timer.queue_free()
	timer = null


func _physics_process(delta):
	
	return
	
	var velocity = $'../Physics'.velocity
	
	if get_parent().is_on_floor():
		
		if timer != null:
			timer.queue_free()
			timer = null
	
	
	elif velocity.y < -min_fall_speed and timer == null:
		
		timer = Timer.new()
		timer.autostart = true
		timer.wait_time = delay
		add_child(timer)
		
		timer.connect('timeout',Callable(self,'_on_timeout'))
