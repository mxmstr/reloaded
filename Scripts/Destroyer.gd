extends Area3D

func _on_body_entered(body):
	
	ActorServer.Destroy(body)

func _ready():
	
	connect('area_entered',Callable(self,'_on_body_entered'))
	connect('body_entered',Callable(self,'_on_body_entered'))
