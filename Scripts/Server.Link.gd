extends Node

var preloader = ResourcePreloader.new()

func _preload():
	
	var links = Meta._get_files_recursive('res://Scenes/Links/', '', '.tscn')
	
	for link in links:
		preloader.add_resource(link, load(link))

func GetAll(from, to, type, data={}):
	
	if from:
		data.from_node = from
	
	if to:
		data.to_node = to
	
	var links = []
	
	for link in $'/root/Mission/Links'.get_children():
		
		if not type == link.base_name:
			continue
		
		var props_match = true
		
		for prop in data:
			
			if link.get(prop) != data[prop]:
				props_match = false
				break
		
		if not props_match:
			continue
		
		links.append(link)
	
	return links

func Create(from, to, type, data={}):
	
	data.from_node = from
	data.to_node = to
	
	var new_link = preloader.get_resource('res://Scenes/Links/' + type + '.link.tscn').instantiate()
	
	for prop in data:
		new_link.set(prop, data[prop])
	
	for link in get_children():
		if is_instance_valid(link) and not link.is_queued_for_deletion() and link._equals(new_link):
			return
	
	$'/root/Mission/Links'.add_child(new_link)
	
	return new_link

func Destroy(from, to, type, data={}):
	
	if from:
		data.from_node = from
	
	if to:
		data.to_node = to
	
	var freed = []
	
	for link in $'/root/Mission/Links'.get_children():
		
		if not type in link.name:
			continue
		
		var props_match = true
		
		for prop in data:
			if link.get(prop) != data[prop]:
				props_match = false
				break
		
		if not props_match:
			continue
		
		link._destroy()
		
		if not link.to_node in freed:
			freed.append(link.to_node)
	
	return freed

func _enter_tree():
	
	_preload()
