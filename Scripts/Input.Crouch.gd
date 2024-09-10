extends "res://Scripts/Input.gd"

const roll_timeout = 0.25

var roll_input_timeout = false
var roll_input_active = false

@onready var forward = get_node_or_null('../MoveForwardInput')
@onready var backward = get_node_or_null('../MoveBackwardInput')
@onready var right = get_node_or_null('../MoveRightInput')
@onready var left = get_node_or_null('../MoveLeftInput')
@onready var behavior = get_node_or_null('../../Behavior')
@onready var locomotion = get_node_or_null('../../Locomotion')

func _on_roll_timeout():
	
	roll_input_timeout = true
	
	if strength > 0.9:
		
		var vertical = forward.strength + backward.strength
		var horizontal = left.strength + right.strength
		
		if abs(vertical) < 0.75 and abs(horizontal) < 0.75:
			behavior._start_state('ShootDodgeStand', { 'direction': Vector2(0, -1) })
		else:
			behavior._start_state('Dive', { 'direction': Vector2(horizontal, vertical) })

func _roll():
	
	var vertical = forward.strength + backward.strength
	var horizontal = left.strength + right.strength
	var action
	
	if vertical > 0.65:
		
		if horizontal > 0.65:
			action = 'RollForwardLeft'
		elif horizontal < -0.65:
			action = 'RollForwardRight'
		elif vertical > 0.9:
			action = 'RollForward'
	
	elif vertical < -0.65:
		
		if horizontal > 0.65:
			action = 'RollBackwardLeft'
		elif horizontal < -0.65:
			action = 'RollBackwardRight'
		elif vertical < -0.9:
			action = 'RollBackward'
	
	elif horizontal < -0.9:
		action = 'RollRight'
	
	elif horizontal > 0.9:
		action = 'RollLeft'
	
	if action:
		behavior._start_state(action)

#func _on_just_activated():
#
#

#func _on_just_deactivated():
#
#	if stance.stance == stance.StanceType.STANDING:
#		stance._set_stance_input(stance.StanceType.CROUCHING)
#	else:
#		stance._set_stance_input(stance.StanceType.STANDING)

func _process(delta):
	
	super(delta)
	
	if roll_input_active:
		
		if roll_input_timeout and strength < 0.9:
			roll_input_active = false
		
		elif not roll_input_timeout and strength < 0.9:# and strength > 0.1:
			_roll()
	
	elif strength > 0.9:
		
		roll_input_active = true
		roll_input_timeout = false
		
		get_tree().create_timer(roll_timeout).connect('timeout',Callable(self,'_on_roll_timeout'))
