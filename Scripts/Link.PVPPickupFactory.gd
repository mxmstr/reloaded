extends Node

var spawn_chance = 1.0#0.8
var spawn_count = 8
var respawn_time = 15.0
var pickups = [] : get = _get_pickups, set = _set_pickups

func _set_pickups(new_pickups):
	
	pickups = new_pickups

func _get_pickups():
	
	for pickup in pickups.duplicate():
		if not is_instance_valid(pickup):
			pickups.erase(pickup)
	
	return pickups

func _on_timeout(marker):
	
	randomize()
	
	_refresh_spawn(marker)
	marker.get_node('RespawnSound').playing = true

func _on_stimulate(item, marker):
	
	pickups.erase(item)
	get_tree().create_timer(respawn_time).connect('timeout',Callable(self,'_on_timeout').bind(marker))

func _on_factory_finished(link, marker):
	
	var offset = Vector3()
	
	for output in link.outputs:
		
		output.position = marker.position + offset
		output.rotation = marker.rotation
		
		offset += Vector3(0, 0.5, 0)
	
	for output in link.outputs:
		
		if output.has_node('AreaStim'):
			
			pickups.append(output)
			output.get_node('AreaStim').connect(
				'stimulate',
				Callable(self, '_on_stimulate').bind(output, marker),
				CONNECT_ONE_SHOT
				)
			
			break

func _refresh_spawn(marker):
	
	if Meta.multi_loadout.size() == 0:
		return
	
	randomize()
	
	var weapon_path = Meta.multi_loadout[randi() % Meta.multi_loadout.size()]
	var node_name = ActorServer.preloader.get_resource('res://Scenes/Actors/' + weapon_path + '.tscn').instantiate().name
	
	for file in Meta._get_files_recursive('res://Scenes/Links/Factories/', 'Factory', '.link.tscn', [node_name]):
		
		var new_link = LinkServer.preloader.get_resource(file).instantiate()
		new_link.connect('finished',Callable(self,'_on_factory_finished').bind(new_link, marker))
		
		$'/root/Mission/Links'.call_deferred('add_child', new_link)

func _ready():
	
	await get_tree().process_frame
	
	if get_child_count() == 0:
		return
	
	for marker in get_children():
		_refresh_spawn(marker)
