extends Node3D

@export var limit = 50

var actors = []


func _on_node_added(node):
	
	if node.get_parent() == $Actors:
		actors.append(node)


func _on_node_removed(node):
	
	if node in actors:
		actors.erase(node)


func _enter_tree():
	
	get_tree().connect('node_added',Callable(self,'_on_node_added'))
	get_tree().connect('node_removed',Callable(self,'_on_node_removed'))
	
#	for actor in actors.get_children():
#		actors.append(actor)


func _process(delta):
	
	if limit == 0:
		return
	
	for actor in actors:
		if not actor._has_tag('Human') and actor.position.length() > limit:
			ActorServer.Destroy(actor)
