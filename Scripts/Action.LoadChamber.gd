extends Node

var tree

@onready var behavior = get_node_or_null('../../Behavior')
@onready var chamber = get_node_or_null('../../Chamber')
@onready var magazine = get_node_or_null('../../Magazine')

func _process(delta):

	if chamber._is_empty() and not magazine._is_empty():

		# TODO
		pass
#		var projectile = magazine._release_front()
#		LinkServer.Create(owner, projectile, 'Contains', { 'container': 'Chamber' } )
#
#		while not chamber._is_full():
#
#			var clone = ActorServer.Create(projectile.system_path)
#			LinkServer.Create(owner, clone, 'Contains', { 'container': 'Chamber' } )
