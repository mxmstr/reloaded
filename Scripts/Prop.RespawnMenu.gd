extends Control

@onready var perspective = owner.get_node_or_null('../Perspective')


func _just_pressed(event, action):
	
	return event.is_action(action) and \
		Input.is_action_just_pressed(action) and \
		event.device == perspective.gamepad_device


func _input(event):

	if _just_pressed(event, 'Respawn'):

		$'/root/Mission/Links/PVPPlayerFactory'._respawn(owner.owner)


func _ready():
	
	pass
