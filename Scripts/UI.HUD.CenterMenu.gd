extends MarginContainer

@export var color_select: Color
@export var color_default: Color
@export var color_cancel: Color
@export var list_item: PackedScene

var update = true
var selection = null
var interactions = []
var select_index = 0


func _has_interactions():
	
	var items = $MarginContainer/ListContainer.get_children()
	
	return len(items) > 0


func _selection_is_freed():
	
	return selection != null and !weakref(selection).get_ref()


func _selection_is_actor():
	
	return selection != null and selection.has_node('Behavior')


func _scroll_up():
	
	select_index = max(0, select_index - 1)
	_highlight_child()


func _scroll_down():
	
	var items = $MarginContainer/ListContainer.get_children()
	
	select_index = min(len(items) - 1, select_index + 1)
	_highlight_child()


func _select():
	
	if _has_interactions():
		
		var items = $MarginContainer/ListContainer.get_children()
		
		if select_index < len(items) - 1:
			
			var interaction = items[select_index].text
			
			if _selection_is_actor():
				selection.get_node('Behavior')._start_state(interaction)
				
		select_index = 0
		_highlight_child()


func _highlight_child():
	
	var items = $MarginContainer/ListContainer.get_children()
	
	if len(items) > 0:
	
		for index in range(len(items)):
			if index == select_index:
				items[index].set('custom_colors/font_color', color_select)
			elif index == len(items) - 1:
				items[index].set('custom_colors/font_color', color_cancel)
			else:
				items[index].set('custom_colors/font_color', color_default)


func _on_selection_changed(_selection):
	
	selection = _selection
	
	_update_interactions()


func _refresh_children():
	
	var list = $MarginContainer/ListContainer
	var items = list.get_children()
	
	for child in items:
		child.name = child.name + '_'
		child.free()
	
	if len(interactions) > 0:
		
		for interaction in interactions:
			var child = list_item.instantiate()
			child.text = interaction
			list.add_child(child)
		
		var child = list_item.instantiate()
		child.text = 'Cancel'
		list.add_child(child)
		
	select_index = 0
	_highlight_child()


func _update_interactions():
	
	if _selection_is_freed():
		
		selection = null
		return
	
	
	if _selection_is_actor():
	
		var last_interactions = interactions.duplicate()
		interactions = selection.get_node('Behavior')._get_visible_interactions()
		
		if last_interactions != interactions:
			_refresh_children()
	
	else:
		
		interactions = []
		_refresh_children()


func _ready():
	
	pass#$'../../CameraRaycast'.connect('selection_changed',Callable(self,'_on_selection_changed'))


func _process(delta):
	
	return
	
	selection = $'../../CameraRaycastStim'.selection
	
	_update_interactions()
