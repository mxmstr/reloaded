extends Node

@export var state: String

@onready var righthand = get_node_or_null('../../RightHandContainer')
@onready var lefthand = get_node_or_null('../../LeftHandContainer')

func _use_right_hand_item():
	
	righthand.items.size()
	
	if not righthand._is_empty() and get_parent().can_use_item:
		
		var item = righthand.items[0]
		
		if not lefthand._is_empty():
			
			if item._has_tag('DualWieldFireDelay'):
				get_tree().create_timer(float(item._get_tag('DualWieldFireDelay'))).connect('timeout',Callable(self,'_use_left_hand_item'))
			else:
				_use_left_hand_item()
		
		ActorServer.Stim(item, 'Use', owner)

func _use_left_hand_item():
	
	lefthand.items.size()
	
	if not lefthand._is_empty() and get_parent().can_use_item:
		ActorServer.Stim(lefthand.items[0], 'Use', owner)

func _on_action(_state, data):
	
	if _state == state:
		_use_right_hand_item()

func _ready():
	
	await get_tree().process_frame

	get_parent().connect('action_started',Callable(self,'_on_action'))
