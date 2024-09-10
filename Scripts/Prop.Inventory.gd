extends Node

var selected_item

@onready var right_hand = get_node_or_null('../RightHandContainer')
@onready var inventory = get_node_or_null('../InventoryContainer')
@onready var behavior = get_node_or_null('../Behavior')

func _go_to_unarmed():
	
	var current = right_hand._release_front()
	
	if current:
		LinkServer.Create(owner, current, 'Contains', { 'container': 'InventoryContainer' } )

func _go_to_next(next=null):
	
	if next == null:
		next = selected_item
	
	if not is_instance_valid(next):
		return
	
	var current = right_hand._release_front()
	
	if current:
		LinkServer.Create(owner, current, 'Contains', { 'container': 'InventoryContainer' } )
	
	var new = inventory._release(next)
	
	if new:
		LinkServer.Create(owner, new, 'Contains', { 'container': 'RightHandContainer' } )
	
	behavior._start_state('Default')

func _find_next(current_rank, not_empty):
	
	var next_item
	var next_rank = 100
	
	for item in inventory.items:
		
		var rank = int(item._get_tag('Rank'))
		var magazine = item.get_node_or_null('Magazine')
		var has_ammo = false if not_empty and magazine and magazine._is_empty() else true
		
		if rank > current_rank and rank < next_rank and has_ammo:
			next_item = item
			next_rank = rank
	
	return next_item

func _find_previous(current_rank, not_empty):
	
	var next_item
	var next_rank = -1
	
	for item in inventory.items:
		
		var rank = int(item._get_tag('Rank'))
		var magazine = item.get_node_or_null('Magazine')
		var has_ammo = false if not_empty and magazine and magazine._is_empty() else true
		
		if rank < current_rank and rank > next_rank and has_ammo:
			next_item = item
			next_rank = rank
	
	return next_item

func _is_container(node):
	
	if node.get_script() != null:
		
		var script_name = node.get_script().get_path().get_file()
		return script_name == 'Prop.Container.gd'
	
	return false

func _get_ammo_container(item):
	
	var required_tags = item.get_node('Magazine').required_tags_dict.keys()
	var container
	var best_tag_count = 0
	
	for prop in owner.get_children():
		
		if _is_container(prop):
			
			var tag_count = 0
			
			for required_tag in required_tags:
				if required_tag in prop.required_tags_dict.keys():
					tag_count += 1
			
			if tag_count > best_tag_count:
				
				container = prop
				best_tag_count = tag_count
	
	return container

func _has_enough_ammo(next):
	
	var ammo_container = _get_ammo_container(next)
	var inv_ammo = ammo_container.items.size()
	var clip_size = next.get_node('Magazine').max_quantity
	
	return inv_ammo >= clip_size

func _try_dual_wield(next=null):
	
	if next == null:
		next = selected_item
	
	if not is_instance_valid(next):
		return
	
	if not _has_enough_ammo(next):
		return
	
	var link = LinkServer.Create(owner, next, 'DualWield')
	
	if not link or link._is_invalid():
		return false
	
	behavior._start_state('Default')
	
	return true

func _stop_dual_wield(current):
	
	var dual_wield_links = LinkServer.GetAll(owner, current, 'DualWield')
	
	if dual_wield_links.size():
		for link in dual_wield_links:
			link._destroy()
	
	behavior._start_state('Default')
	
	return dual_wield_links.size()

func _next(forward=true, not_empty=false):
	
	if right_hand._is_empty():
		
		if forward:
			
			selected_item = _find_next(-1, not_empty)
			
			if selected_item:
				behavior._start_state('ChangeItem')
		
		else:
			
			selected_item = _find_previous(1000, not_empty)
			
			if selected_item:
				
				if selected_item._has_tag('DualWield'):
					behavior._start_state('ChangeItem', { 'dual_wield': true })
				else:
					behavior._start_state('ChangeItem')
				
			else:
				
				behavior._start_state('HolsterItem')
		
	else:
		
		var current = right_hand.items[0]
		var current_rank = int(current._get_tag('Rank'))
		var dual_wield = current._has_tag('DualWield')
		
		if forward:
			
			if dual_wield and _has_enough_ammo(current):
				
				if LinkServer.GetAll(owner, current, 'DualWield').size():
					
					selected_item = _find_next(current_rank, not_empty)
					
					if selected_item:
						behavior._start_state('ChangeItem')
					else:
						behavior._start_state('HolsterItem')
				
				else:
					
					selected_item = current
					behavior._start_state('DualWieldItem')
				
			else:
				
				selected_item = _find_next(current_rank, not_empty)
				
				if selected_item:
					behavior._start_state('ChangeItem')
				else:
					behavior._start_state('HolsterItem')
		
		else:

			if dual_wield and LinkServer.GetAll(owner, current, 'DualWield').size():
				_stop_dual_wield(current)

			else:

				selected_item = _find_previous(current_rank, not_empty)

				if selected_item:
				
					if selected_item._has_tag('DualWield'):
						behavior._start_state('ChangeItem', { 'dual_wield': true })
					else:
						behavior._start_state('ChangeItem')
				
				else:
					behavior._start_state('HolsterItem')
