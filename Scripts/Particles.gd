extends GPUParticles3D


func _on_ressurected():
	
	restart()


func _enter_tree():
	
	owner.connect('ressurected',Callable(self,'_on_ressurected'))
	
	emitting = true

	var time = (lifetime * 2) / speed_scale
	get_tree().create_timer(time).connect('timeout',Callable(ActorServer,'Destroy').bind(owner))
