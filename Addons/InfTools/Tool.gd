@tool
extends EditorPlugin

var dock
var selection


func on_selection_changed():
	
	if selection != null:
	
		var selected = selection.get_selected_nodes()

#		if selected.is_empty():
#			auto_floor = true
#		else:
#			auto_floor = not self in selected


func on_floor_pressed():
	
	if not selection.get_selected_nodes().is_empty():
		
		var selected = selection.get_selected_nodes()[0]
		
		if selected is PhysicsBody3D:
			
			var ray = RayCast3D.new()
			selected.add_child(ray)
			ray.global_transform = selected.global_transform
			ray.translate(Vector3(0, 0.1, 0)) 
			ray.target_position = Vector3(0, -100, 0)
			ray.force_raycast_update()
			
			if ray.get_collider() is PhysicsBody3D:
				selected.position = ray.get_collision_point()
			
			ray.queue_free()
	#		if $RayCast3D.get_collider() != null:
	#			position = $RayCast3D.get_collision_point()


func on_convert_pressed():
	
	return
#	var files = []
#	var dir = Directory.new()
#	dir.open(dock.get_node('ConvertInput').text)
#	dir.list_dir_begin() # TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547
#
#	while true:
#
#		var file = dir.get_next()
#
#		if file == '':
#			break
#
#		elif not file.begins_with('.') and file.ends_with('.escn'):
#
#			var anim_player = load(dock.get_node('ConvertInput').text + file).instantiate().find_child('AnimationPlayer')
#
#			var anim_source = anim_player.get_animation(anim_player.get_animation_list()[0])
#
#			file = file.replace('.escn', '')
#			ResourceSaver.save(dock.get_node('ConvertOutput').text + file + '.tres', anim_source)
#
#	dir.list_dir_end()


func on_revert_statemachines():
	
	return
#	var files = []
#	var dir = Directory.new()
#	dir.open(dock.get_node('RevertInput').text)
#	dir.list_dir_begin() # TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547
#
##	while true:
##
##		var file = dir.get_next()
##
##		if file == '':
##			break
##
##		elif not file.begins_with('.') and file.ends_with('.tscn'):
##
##			var anim_player = load(dock.get_node('RevertInput').text + file).instantiate().find_child('AnimationPlayer')
##			var anim_source = anim_player.get_animation(anim_player.get_animation_list()[0])
##
##			ResourceSaver.save(dock.get_node('RevertInput').text + file, anim_source)
##
##	dir.list_dir_end()


func on_loadanim_pressed():
	
	var current_path = EditorPlugin.new().get_editor_interface().get_current_path()
	var res = load(current_path)
	prints(res.get_track_count())
#	if not selection.get_selected_nodes().is_empty():
#
#		var selected = selection.get_selected_nodes()[0]
#
#		if selected is AnimationPlayer:
#
#			var files = []
#			var dir = Directory.new()
#			var current_path = EditorPlugin.new().get_editor_interface().get_current_path()
#
#			if current_path[-1] != '/':
#				selected.add_animation_library(
#					current_path.split('/')[-1].replace('.tres', ''), 
#					load(current_path)
#					)
#				return
#
#			dir.open(current_path)
#			dir.list_dir_begin() # TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547
#
#			while true:
#
#				var file = dir.get_next()
#
#				if file == '':
#					break
#
#				elif not file.begins_with('.') and file.ends_with('.tres'):
#
#					var anim_source = load(current_path + file)
#					file = file.replace('.tres', '')
#					selected.add_animation_library(file, anim_source)
#
#			dir.list_dir_end()


#func on_flipanim_pressed():
#
#	var files = []
#	var dir = Directory.new()
#	dir.open(dock.get_node('FlipAnimInput').text)
#	dir.list_dir_begin() # TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547
#
#	while true:
#
#		var file = dir.get_next()
#
#		if file == '':
#			break
#
#		elif not file.begins_with('.') and file.ends_with('.tres'):
#
#			var anim_source = load(dock.get_node('FlipAnimInput').text + file)
#			for track in anim_source.get_track_count():
#
#	dir.list_dir_end()


func _load_stream(selected, file, anim_name):
	
	var stream = load(file)
	file = file.replace('.wav', '')
	
	var anim = Animation.new()
	#anim_data.resource_name = file
	var track = anim.add_track(Animation.TYPE_AUDIO)
	anim.length = stream.get_length()
	anim.track_set_path(track, NodePath('AudioStreamPlayer3D'))
	anim.audio_track_insert_key(track, 0, stream)
	
	selected.add_animation_library(anim_name, anim)
#					ResourceSaver.save(
#						dock.get_node('LoadAudioOutput').text + file + '.tres', 
#						anim#selected.get_animation(file)
#						)


func on_loadaudio_pressed():
	
	return
#	if not selection.get_selected_nodes().is_empty():
#
#		var selected = selection.get_selected_nodes()[0]
#
#		if selected is AnimationPlayer:
#
#			prints(dock.get_node('LoadAudioInput').text)
#			if dock.get_node('LoadAudioInput').text.ends_with('.wav'):
#
#				_load_stream(selected, dock.get_node('LoadAudioInput').text, 
#					dock.get_node('LoadAudioInput').text.split('/')[-1].trim_suffix('.wav')
#					)
#				return
#
#
#			var files = []
#			var dir = Directory.new()
#			dir.open(dock.get_node('LoadAudioInput').text)
#			dir.list_dir_begin() # TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547
#
#			while true:
#
#				var file = dir.get_next()
#
#				if file == '':
#					break
#
#				elif not file.begins_with('.') and file.ends_with('.wav'):
#
#					_load_stream(selected, dock.get_node('LoadAudioInput').text + file, file)
#
#			dir.list_dir_end()


func on_loadmap_pressed():
	
	for node in selection.get_selected_nodes():
		
		if node is MeshInstance3D and node.visible:
			
			var map = node.get_node('../../')
			
			node = node.duplicate()
			map.add_child(node)
			node.create_trimesh_collision()
			
			var shape = node.get_child(0).get_node('CollisionShape3D')
			shape.name = node.name
			shape.get_parent().remove_child(shape)
			map.add_child(shape)
			shape.global_transform = node.global_transform
			shape.set_owner(map.owner)
			node.queue_free()
			
	
#	if not selection.get_selected_nodes().is_empty():
#
#		var selected = selection.get_selected_nodes()[0]
#		var map = load(dock.get_node('LoadMapInput').text).instantiate()
#
#		for child in map.get_children():
#
#			if child is MeshInstance3D:
#
#				var model = child.duplicate()
#				var scaling = model.scale
#
#				model.create_trimesh_collision()
#
#				var body = model.get_child(0)
#				var collision = body.get_node('CollisionShape3D')
#				var receptor = load('res://Scenes/Components/Properties/Reception.property.tscn').instantiate()
#
#				model.remove_child(body)
#				selected.add_child(body)
#				body.add_child(model)
#				body.remove_child(collision)
#				body.add_child(collision)
#				body.add_child(receptor)
#
#				model.scale = Vector3(1, 1, 1)
#				body.scale = scaling
#				body.collision_layer = 4
#
#				body.name = model.name
#				model.name = 'Model'
#				collision.name = 'Collision'
#
#				body.owner = get_tree().get_edited_scene_root()
#				model.owner = get_tree().get_edited_scene_root()
#				collision.owner = get_tree().get_edited_scene_root()
#				receptor.owner = get_tree().get_edited_scene_root()
#
#				break


func _evaluate(node, expression, arguments):
	
	var exec = Expression.new()
	
	if exec.parse(expression, arguments.keys()) > 0:
		prints(expression, exec.get_error_text())
	
	var result = exec.execute(arguments.values(), node)
	
	if exec.has_execute_failed():
		prints(expression, exec.get_error_text())
	
	return result


func on_evaluate_pressed():
	
	return
#	if not selection.get_selected_nodes().is_empty():
#
#		var selected = selection.get_selected_nodes()[0]
#		print(selected.name, dock.get_node('ArgumentsInput').text)
#		var test_json_conv = JSON.new()
#		test_json_conv.parse(dock.get_node('ArgumentsInput').text)))
#		print(_evaluate(selected, dock.get_node('ExpressionInput').text, test_json_conv.get_data()


func _on_print_transform():
	return
#
#	if not selection.get_selected_nodes().is_empty():
#
#		var selected = selection.get_selected_nodes()[0]
#		print(selected.position.x, ',', selected.position.y, ',', selected.position.z)
#		print(selected.rotation_degrees.x, ',', selected.rotation_degrees.y, ',', selected.rotation_degrees.z)


func on_convert_anim_pressed():
	
	var dir = DirAccess.open('res://Animations/')
	dir.list_dir_begin()
	
	while true:
		
		var file = dir.get_next()
		
		if file.is_empty():
			break
		
		if file in ['.', '..']:
			continue
		
		if dir.current_is_dir():
			continue
		
		if not file.ends_with('.glb'):
			continue
		
		
		var res = load('%s/%s' % [dir.get_current_dir(), file])
		
		if not res:
			continue
		
		var anim_player = res.instantiate().get_node('AnimationPlayer')
		
		#prints(anim_player.get_animation_list())
		
		for anim_name in anim_player.get_animation_list():
			
			var anim_source = anim_player.get_animation(anim_name)
			#prints(anim_source)
			
			anim_name = file.replace('.glb', '')
#			anim_name = anim_name.replace('kf2001', '').replace('kf2', '')
			
			for i in range(anim_source.get_track_count()):
				
				var path = anim_source.track_get_path(i)
				#prints(path)
				var bone = String(path).split(':')[-1]
				anim_source.track_set_path(i, NodePath('.:' + bone))
				
				#prints(NodePath('/'.join(names)))
			
			#prints('res://Animations/converted/' + anim_name + '.tres')
			ResourceSaver.save(anim_source, 'res://Animations/converted/' + anim_name + '.tres')


func _ready():
	
	pass


func _enter_tree():
	
	dock = preload("res://Addons/InfTools/Toolbox.tscn").instantiate()
	dock.get_node('Floor').connect('button_down',Callable(self,'on_floor_pressed'))
	dock.get_node('Convert').connect('button_down',Callable(self,'on_convert_pressed'))
	dock.get_node('LoadAnim').connect('button_down',Callable(self,'on_loadanim_pressed'))
	dock.get_node('LoadAudio').connect('button_down',Callable(self,'on_loadaudio_pressed'))
	dock.get_node('LoadMap').connect('button_down',Callable(self,'on_loadmap_pressed'))
#	dock.get_node('Evaluate').connect('button_down',Callable(self,'on_evaluate_pressed'))
	dock.get_node('PrintTransform').connect('button_down',Callable(self,'_on_print_transform'))
	dock.get_node('ConvertAnimButton').connect('button_down',Callable(self,'on_convert_anim_pressed'))
	
	selection = EditorPlugin.new().get_editor_interface().get_selection()
	selection.connect('selection_changed',Callable(self,'on_selection_changed'))
	
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock)


func _exit_tree():
	
	remove_control_from_docks(dock)
	dock.free()
