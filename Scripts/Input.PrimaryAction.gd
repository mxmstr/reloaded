extends "res://Scripts/Input.gd"

@onready var behavior = get_node_or_null('../../Behavior')
@onready var righthand = get_node_or_null('../../RightHandContainer')

func _on_just_activated():
	
	if righthand._is_empty():
		
		behavior._start_state('PunchIdle')
	
	else:
		
		if righthand.items[0]._has_tag('Sword'):
			
			behavior._start_state('SwordMelee')
		
		else:
		
			behavior._start_state('UseItem')

func _on_just_deactivated():
	
	if righthand._is_empty():
		
		if behavior.current_state == 'PunchIdle':
			behavior._start_state('Punch')

func _process(delta):
	
	super(delta)
	
	righthand.items.size()
	
	if not righthand._is_empty():
		
		if active and righthand.items[0]._has_tag('AutoFire'):
			
			behavior._start_state('UseItem')
