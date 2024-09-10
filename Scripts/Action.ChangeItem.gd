extends "res://Scripts/Action.Human.gd"

@onready var inventory = get_node_or_null('../../Inventory')

func _select_item():
	
	inventory._go_to_next()
	
	if data.has('dual_wield'):
		get_parent()._start_state('DualWieldItem')

func _on_action(_state, _data):
	
	if _state == 'ChangeItemSelectItem':
		_select_item()
	
	super._on_action(_state, _data)
