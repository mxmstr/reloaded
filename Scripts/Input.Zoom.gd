extends "res://Scripts/Input.gd"

var zooming = false
var default_fov

@onready var behavior = get_node_or_null('../../Behavior')
@onready var right_hand = get_node_or_null('../../RightHandContainer')
@onready var locomotion = get_node_or_null('../../Locomotion')
@onready var camera = get_node_or_null('../../CameraRig/Camera3D')

func _ready():
	
	default_fov = camera.fov

func _on_just_activated(): 
	
	if zooming:
		
		camera.fov = default_fov
		locomotion.rotate_speed_mult = 1.0
		
#		if perspective.viewmodel:
#			perspective.viewmodel.show()
		
		if not right_hand._is_empty():
			right_hand.items[0].show()
		
		zooming = false
	
	else:
		
		if behavior.can_zoom and right_hand._has_item_with_tag('ZoomFOV'):
			
			camera.fov = int(right_hand.items[0]._get_tag('ZoomFOV'))
			locomotion.rotate_speed_mult = 0.2
			
#			if perspective.viewmodel:
#				perspective.viewmodel.hide()
			
			if not right_hand._is_empty():
				right_hand.items[0].hide()
			
			zooming = true

func _process(delta):
	
	if not behavior.can_zoom and zooming:
		
		camera.fov = default_fov
		locomotion.rotate_speed_mult = 1.0
		
#		if perspective.viewmodel:
#			perspective.viewmodel.show()
		
		if not right_hand._is_empty():
			right_hand.items[0].show()
		
		zooming = false
