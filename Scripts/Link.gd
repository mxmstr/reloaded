extends Node

@export var enabled = true
@export var from: NodePath
@export var to: NodePath

var check_nulls = true

var base_name
var from_node
var to_node

signal destroyed

func _notification(what):
	
	if what == NOTIFICATION_SCENE_INSTANTIATED:
		base_name = name

func _equals(other):
	
	return base_name == other.base_name and from_node == other.from_node and to_node == other.to_node

func _is_invalid():
	
	if is_queued_for_deletion():
		return true
	
	if from_node == null:
		return true
	
	if not is_instance_valid(from_node):
		return true
	
	if from_node.is_queued_for_deletion():
		return true
	
	if not is_instance_valid(from_node.get_parent()):
		return true
	
	if to_node == null:
		return true
	
	if not is_instance_valid(to_node):
		return true
	
	if to_node.is_queued_for_deletion():
		return true
	
	if not is_instance_valid(to_node.get_parent()):
		return true
	
	return false

func _enter_tree():
	
	if not enabled:
		queue_free()
		return
	
#	if check_nulls:
#
#		if from.is_empty() or to.is_empty() or not has_node(from) or not has_node(to):
#			queue_free()
#			return
	
	if not from.is_empty():
		from_node = get_node(from)
	
	if not to.is_empty():
		to_node = get_node(to)
	
#	from_node.connect('tree_exited',Callable(self,'queue_free'))
#	to_node.connect('tree_exited',Callable(self,'queue_free'))

#func _process(delta):
#
#	if from_node and (not weakref(from_node).get_ref() or from_node.is_queued_for_deletion()) or \
#		to_node and (not weakref(to_node).get_ref() or to_node.is_queued_for_deletion()):
#		_destroy()
#		return

func _destroy():
	
	set_process(false)
	set_physics_process(false)
	queue_free()
	
	emit_signal('destroyed')
