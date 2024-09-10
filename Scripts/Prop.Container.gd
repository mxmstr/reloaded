extends Node

@export var path: NodePath
@export var bone_name: String
@export var factory_mode = false
@export var parent_position = true
@export var parent_rotation = true
@export var position_offset: Vector3
@export var rotation_degrees_offset: Vector3
@export var release_speed: float
@export var release_direction: Vector3
@export var release_angular_spread: Vector2 = Vector2(0, 0)
@export var release_angular_spread_decay: float
@export var release_lifetime: float
@export var release_exclude_parent = false
@export var release_exclude_parent_lifetime = 0.0
@export var max_quantity: int
@export var invisible: bool
@export var interactable: bool
@export_multiline var required_tags

var physics = get_node_or_null('../Physics')
var root
var shooter
var required_tags_dict = {}
var items = [] : get = _get_items, set = _set_items

signal item_added
signal item_removed
signal item_released
signal released

func _set_items(new_items):
	
	items = new_items

func _get_items():
	
	for item in items.duplicate():
		if not item is String and not is_instance_valid(item):
			items.erase(item)
	
	return items

func _is_empty():
	
	items.size()
	
	return items.size() == 0

func _is_full():
	
	return max_quantity > 0 and items.size() >= max_quantity

func _add_item(item):
	
	if max_quantity > 0 and items.size() >= max_quantity:
		return false

	if factory_mode:

		if not item is String:

			ActorServer.Destroy(item)
			item = item.system_path

	items.append(item)

	emit_signal('item_added', item)
	
	return true

func _remove_item(item):
	
	if _has_item(item):
		
		items.erase(item)
		
		emit_signal('item_removed', item)
		
		return item

func _remove_all_items():
	
	var returned = items.duplicate()
	items = []
	
	return returned

func _has_item(item):
	
	return items.has(item)

func _has_item_with_tag(tag):
	
	for item in items:
		if is_instance_valid(item) and  item._has_tag(tag):
			return true
	
	return false

func _has_item_with_tags(tags):
	
	for item in items:
		
		if not is_instance_valid(item):
			continue
		
		var tagged = true
		
		for tag in tags:
			if not item._has_tag(tag):
				tagged = false
		
		if not tagged:
			continue
		
		return true
	
	return false

func _get_item_with_tags(tags):
	
	for item in items:
		
		var tagged = true
		
		for tag in tags:
			if not item._has_tag(tag):
				tagged = false
		
		if tagged:
			return item
	
	return null

func _push_front_into_container(new_container):
	
	if not items.size():
		return
	
	var item = _release_front()
	
	LinkServer.Create(owner, item, 'Contains', {'container': new_container})

func _exclude_recursive(item, parent):
	
	var parent_list = []
	
	if release_exclude_parent:
		ActorServer.AddCollisionException(item, parent)
	
	parent_list.append(parent)
	shooter = parent
	
	for link in LinkServer.GetAll(null, parent, 'Contains'):
		parent_list += _exclude_recursive(item, link.from_node)
	
	return parent_list

func _remove_exclusions(item, parent_list):
	
	if not is_instance_valid(item):
		return
	
	for parent in parent_list:
		ActorServer.RemoveCollisionException(item, parent)

func _apply_launch_attributes(item):
	
	ActorServer.SetDirectionLocal(item, release_direction)
	ActorServer.SetSpeed(item, release_speed)
	
	if release_angular_spread.length():
		
		var spread_x = release_angular_spread.x
		spread_x = randf_range(-spread_x, spread_x)
		var spread_y = release_angular_spread.y
		spread_y = randf_range(-spread_y, spread_y)
		
		ActorServer.SetAngularDirection(item, Vector2(spread_x, spread_y))
		
	var parent_list = _exclude_recursive(item, owner)
	
	#prints(item, parent_list)
	
	if shooter._has_tag('Shooter'):
		shooter = shooter._get_tag('Shooter')
		ActorServer.SetTag(item, 'Shooter', shooter)
	
	if release_exclude_parent and release_exclude_parent_lifetime > 0:
		get_tree().create_timer(release_exclude_parent_lifetime).connect('timeout',Callable(self,'_remove_exclusions').bind(item, parent_list))
	
	if release_lifetime > 0:
		get_tree().create_timer(release_lifetime).connect('timeout',Callable(ActorServer,'Destroy').bind(item))

func _create_and_launch_item(item_path, _rotation=null):
	
	var position = root.global_transform.origin
	var rotation = root.global_transform.basis.get_euler()
	
	if _rotation:
		rotation = _rotation
	
	var item = ActorServer.Create(item_path, position, rotation, null, { 'Shooter': shooter })
		
	#item.get_node('Physics')._teleport(position, basis)
	
	_apply_launch_attributes(item)
	
	emit_signal('item_released', item)
	
	return item

func _release_front_threaded():
	
	var thread = Thread.new()
	thread.start(Callable(self,'_release_front'))
	
	Meta.threads.append(thread)

func _release_front(release_speed_override=null):
	
	if not items.size():
		return
	
	var release_speed_default = release_speed
	
	if release_speed_override:
		release_speed = release_speed_override
	
	var item
	
	if factory_mode:
		
		var removed = _remove_item(items[0])
		item = ActorServer.Create(removed, root.global_transform.origin, root.rotation)
		_apply_launch_attributes(item)
	
	else:
		
		item = items[0]
		LinkServer.Destroy(owner, item, 'Contains', {'container': name})
	
	if is_instance_valid(item):
		ActorServer.SetTag(item, 'Shooter', shooter)
	
	emit_signal('item_released', item)
	
	release_speed = release_speed_default
	
	return item

func _release(item):
	
	if not items.size():
		return
	
	LinkServer.Destroy(owner, item, 'Contains', {'container': name})
	
	if is_instance_valid(item):
		item._set_tag('Shooter', shooter)
	
	emit_signal('item_released', item)
	
	return item

func _release_all():
	
	var released = []
	
	if factory_mode:
		
		for item in items:
			
			var removed = _remove_item(item)
			released.append(ActorServer.Create(removed, root.global_transform.origin, root.rotation))
			_apply_launch_attributes(item)
	
	else:
		
		released = LinkServer.Destroy(owner, null, 'Contains', {'container': name})
		
		for item in released.duplicate():
			if not is_instance_valid(item):
				released.erase(item)
	
	for item in released:
		
		ActorServer.SetTag(item, 'Shooter', shooter)
		emit_signal('item_released', item)
	
	return released

func _delete_all():
	
	if factory_mode:
		
		items.clear()
	
	else:
		
		var removed = items.duplicate()
		
		#LinkServer.Destroy(owner, null, 'Contains', {'container': name})
		
		for item in removed:
			ActorServer.Destroy(item)

func _reset_root():
	
	root.position = position_offset
	root.rotation_degrees = rotation_degrees_offset

func _ready():
	
	shooter = owner
	
	for tag in required_tags.split(' '):
		
		var values = Array(tag.split(':'))
		var key = values.pop_front()
		
		required_tags_dict[key] = values
	
	if path.is_empty():
		
		root = self
		
	else:
	
		root = BoneAttachment3D.new()
		root.name = name + 'Root'
		get_node(path).call_deferred('add_child', root)
		
		if bone_name != '':
			root.bone_name = bone_name
		
		_reset_root()
