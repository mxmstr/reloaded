extends Node

enum Visibility {
	INVISIBLE,
	PHYSICAL, 
	REMOTE
}

enum BlendLayer {
	ACTION,
	MOVEMENT,
	MIXED
}

enum Priority {
	LOW,
	HIGH,
	VERY_HIGH
}

enum DriverMode {
	Steer,
	Sidestep
}

enum Team {
	None,
	Red,
	Blue,
	Green,
	Yellow
}

const TeamColors = [
	Color.WHITE,
	Color.RED,
	Color.BLUE,
	Color.GREEN,
	Color.YELLOW
	]

const schemas_dir = 'res://Scenes/Schemas/'
const schemas_extension = '.schema.tscn'

var preloader
var tree_count = 0

var menu_input = false
var multi = false
var multi_points_to_win = 5
var multi_radar = false
var multi_outlines = false
var multi_xray = false
var multi_loadout = ['Items/Beretta']
var coop = false
var player_count = 1
var player_data_default = {
	'mouse': -1,
	'keyboard': -1,
	'gamepad': -1,
	'character': 'Humans/Players/Anderson2',
	'hp': 100.0,
	'team': Team.None,
	'auto_aim': true,
	'bot': false
	}
var player_data = [
	player_data_default.duplicate(),
	player_data_default.duplicate(),
	player_data_default.duplicate(),
	player_data_default.duplicate()
]
var rawinput = false
var threads = []
var cached_args = []

signal on_input

class SortActors:
	
	var actor
	
	func _init(actor):
		self.actor = actor
	
	func _ascending(a, b):
		
		var dist_a = a.global_transform.origin.distance_to(actor.global_transform.origin)
		var dist_b = b.global_transform.origin.distance_to(actor.global_transform.origin)
		
		if dist_a < dist_b:
			return true
		
		return false
	
	func _descending(a, b):
		
		var dist_a = a.global_transform.origin.distance_to(actor.global_transform.origin)
		var dist_b = b.global_transform.origin.distance_to(actor.global_transform.origin)
		
		if dist_a > dist_b:
			return true
		
		return false

func _merge_dir(target, patch):
	
	for key in patch:
		if target.has(key):
			var tv = target[key]
			if typeof(tv) == TYPE_DICTIONARY:
				_merge_dir(tv, patch[key])
			else:
				target[key] = patch[key]
		else:
			target[key] = patch[key]

func _make_unique(old, new_owner=null):
	
	var export_props = {}
	
	for prop in old.get_property_list():
		if prop.usage == 8199:
			export_props[prop.name] = old.get(prop.name)
		
	var new_name = old.name
	var new_filename = 'res://duplicated' + str(tree_count) + '.tscn'
	
	prints('old', old.filename, old.tree_root.get_node('Start'))
	var new = load(old.filename)
	prints('new', new.instantiate().tree_root.get_node('Start'))
	ResourceSaver.save(new_filename, new)
		
	new = load(new_filename).instantiate()
	prints('new', new.filename, new.tree_root)
	new.name = old.name
	new.set_meta('unique', true)
	old.name += '_'
		
	for prop in export_props:
		new.set(prop, export_props[prop])
		
	old.get_parent().add_sibling(old, new)
	
	if new_owner:
		new.set_owner(new_owner)
	else:
		new.set_owner(old.owner)
	
	old.get_parent().remove_child(old)
	old.free()
		
	DirAccess.open(new_filename).remove(new_filename)
	
	tree_count += 1

func _get_files_recursive(root, begins_with='', ends_with='', actor_tags=null):
	
	var files = []
	var dirs = [root]
	
	var file_to_add
	var highest_tag_count = 0
	
	while not dirs.is_empty():
		
		var dir = DirAccess.open(dirs.pop_front())
		dir.list_dir_begin()
		
		while true:
			
			var file = dir.get_next()
			
			if file.is_empty():
				break
			
			if file in ['.', '..']:
				continue
			
			if dir.current_is_dir():
				
				dirs.append('%s/%s' % [dir.get_current_dir(), file])
				continue
			
			if file.begins_with(begins_with) and (not ends_with.length() or file.ends_with(ends_with)):
				
				if actor_tags:
					
					if file.split('.')[0] != begins_with:
						continue
					
					var file_stripped = file.trim_prefix(begins_with).trim_suffix(ends_with)
					var file_tags = Array(file_stripped.split('.'))
					file_tags.erase('')
										
					var tagged = true
					var tag_count = 0
					
					for file_tag in file_tags:
						
						if file_tag == begins_with:
							continue
						
						if file_tag in actor_tags:
							tag_count += 1
						else:
							tagged = false
							break
					
					if not tagged:
						continue
										
					if file_to_add == null or tag_count > highest_tag_count:
						
						file_to_add = '%s/%s' % [dir.get_current_dir(), file]
						highest_tag_count = tag_count
					
				else:					
					files.append('%s/%s' % [dir.get_current_dir(), file])
	
	if file_to_add != null:
		files.append(file_to_add)
		
	return files

func _get_children_recursive(node, children=[]):
	
	for child in node.get_children():
		
		children.append(child)
		children = _get_children_recursive(child, children)
	
	return children

func Evaluate(node, expression, arguments):
	
	var exec = Expression.new()
	if exec.parse(expression, arguments.keys()) > 0:
		prints(expression, exec.get_error_text())
	
	var result = exec.execute(arguments.values(), node)
	
	if exec.has_execute_failed():
		prints(expression, exec.get_error_text())
	
	return result

func PreloadSchemas():
	
	var schemas = _get_files_recursive('res://Scenes/Schemas/', '', '.tscn')
	
	for schema in schemas:
		
		var packed_scene = load(schema)
		var animation_player = packed_scene.instantiate()
		packed_scene.pack(animation_player)
		
		preloader.add_resource(schema, packed_scene)

func LoadSchema(schema, owner_tags):
	
	var selected_file
	var highest_tag_count = 0
	
	for resource in preloader.get_resource_list():
		
		if not resource.begins_with(schemas_dir) or not resource.ends_with(schemas_extension):
			continue
		
		var file = resource.split('/')[-1]
		
		if file.split('.')[0] != schema:
			continue
		
		var file_stripped = file.trim_prefix(schema).trim_suffix(schemas_extension)
		var file_tags = Array(file_stripped.split('.'))
		file_tags.erase('')
				
		var tagged = true
		var tag_count = 0
		
		for file_tag in file_tags:
			
			if file_tag in owner_tags:
				tag_count += 1
			else:
				tagged = false
				break
		
		if not tagged:
			continue
				
		if selected_file == null or tag_count > highest_tag_count:
		
			selected_file = resource
			highest_tag_count = tag_count
	
	return preloader.get_resource(selected_file)

func AddWayPoint(position):

	var waypoint = load('res://Scenes/Markers/Waypoint2.tscn').instantiate()
	$'/root/Mission/Actors'.add_child(waypoint)
	waypoint.global_transform.origin = position

# func CreateEvent(actor, event_name):
	
# 	var event = load('res://Scenes/Actors/Events' + event_name + '.tscn').instantiate()
# 	$'/root/Mission/Actors'.add_child(event)
	
# 	LinkServer.Create(event, actor, 'EventMaster')

func _enter_tree():
	
	for i in range(4):
		player_data[i].gamepad = i
	
	preloader = ResourcePreloader.new()
	
	PreloadSchemas()

func _exit_tree():
	
	for thread in threads:
		thread.wait_to_finish()
