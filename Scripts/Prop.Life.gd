extends Node

@export var time = -1.0


func _on_timeout():
	
	ActorServer.Destroy(owner)


func _ready():
	
	if time != -1.0:
	
		var timer = Timer.new()
		timer.autostart = true
		timer.wait_time = time
		add_child(timer)
		
		timer.connect('timeout',Callable(self,'_on_timeout'))
