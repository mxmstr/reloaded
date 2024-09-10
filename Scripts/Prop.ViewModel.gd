extends Node3D

const viewmodel_offset = 5
const worldmodel_offset = 15

var has_skeleton = false
var hidden_bones = []
var hidden_bone_ids = []
var follow_camera_bone_id
var follow_camera_offset = Vector3()
var follow_camera_torso_origin
var follow_camera_torso_delta = Vector3()

var actor
var actor_model
var model
var container
var container_root
var item_position_offset
var item_rotation_offset
var world_skeleton
var vm_skeleton

@onready var contains_link = load('res://Scripts/Link.Contains.gd')
@onready var behavior = get_node_or_null('../Behavior')
@onready var perspective = get_node_or_null('../Perspective')
@onready var camera_rig = get_node_or_null('../CameraRig')
@onready var camera = get_node_or_null('../CameraRig/Camera3D')

signal blended_skeletons


func _init_duplicate_meshes():
	
	# TODO
	if not is_instance_valid(actor):
		return
	
	actor_model = actor.get_node('Model')
	
	if actor_model.get_children().size() and actor_model.get_child(0) and actor_model.get_child(0) is Skeleton3D:
		world_skeleton = actor_model.get_child(0)
	
	var actor_instance = ActorServer.preloader.get_resource('res://Scenes/Actors/' + actor.system_path + '.tscn').instantiate()
	var model_instance = actor_instance.get_node('Model')
	
	if model_instance is MeshInstance3D:
		model_instance.cast_shadow = 0
	
	for child in model_instance.get_children():
		if child is MeshInstance3D:
			child.cast_shadow = 0
	
	actor_instance.remove_child(model_instance)
	add_child(model_instance)
	
	model = model_instance
	model.transform = actor_model.transform
	
	if model_instance.get_children().size() and model_instance.get_child(0) and model_instance.get_child(0) is Skeleton3D:
		
		vm_skeleton = model_instance.get_child(0)
		
		for idx in range(vm_skeleton.get_bone_count()):
			if vm_skeleton.get_bone_name(idx) in hidden_bones:
				hidden_bone_ids.append(idx)
	
	#actor_model.visible = false


func _cull_mask_bits(world_mesh, view_mesh):
	
	camera.set_cull_mask_value(viewmodel_offset, false)
	view_mesh.set_layer_mask_value(viewmodel_offset, false)
	
	camera.set_cull_mask_value(worldmodel_offset, true)
	world_mesh.set_layer_mask_value(worldmodel_offset, false)
	
	
	# Make my camera render only the viewmodel
	camera.set_cull_mask_value(viewmodel_offset + owner.player_index, true)
	view_mesh.set_layer_mask_value(0, false)
	view_mesh.set_layer_mask_value(viewmodel_offset + owner.player_index, true)
	
	camera.set_cull_mask_value(worldmodel_offset + owner.player_index, false)
	world_mesh.set_layer_mask_value(0, false)
	world_mesh.set_layer_mask_value(worldmodel_offset + owner.player_index, true)


func _init_mesh_layers():
	
	if world_skeleton:
		
		for w_child in world_skeleton.get_children():
			
			if not w_child is MeshInstance3D:
				continue
			
			var path_to_child = actor_model.get_path_to(w_child)
			var vm_child = model.get_node(path_to_child)
			
			_cull_mask_bits(w_child, vm_child)
	
	else:
		
		if actor_model is MeshInstance3D:
			_cull_mask_bits(actor_model, model)
		
		for w_child in actor_model.get_children():
			
			if not w_child is MeshInstance3D:
				continue
			
			var path_to_child = actor_model.get_path_to(w_child)
			var vm_child = model.get_node(path_to_child)
			
			_cull_mask_bits(w_child, vm_child)


func _uncull_mask_bits(world_mesh):
	
	# TODO owner can be null
	world_mesh.set_layer_mask_value(0, true)
	world_mesh.set_layer_mask_value(worldmodel_offset + owner.player_index, false)


func _revert_mesh_layers():
	
	if world_skeleton:
		
		for w_child in world_skeleton.get_children():
			
			if not w_child is MeshInstance3D:
				continue
			
			_uncull_mask_bits(w_child)
	
	else:
		
		if not is_instance_valid(actor_model):
			return
		
		if actor_model is MeshInstance3D:
			_uncull_mask_bits(actor_model)
		
		for w_child in actor_model.get_children():
			
			if not w_child is MeshInstance3D:
				continue
			
			_uncull_mask_bits(w_child)


func _init_container():

	if container == null:
		return
	
	var path_to_root = get_node('../Model').get_path_to(container.root.get_parent())
	container_root = BoneAttachment3D.new()
	
	var last_owner = owner

	get_node('../ActorViewModel/Model').get_node(path_to_root).add_child(container_root)
	get_parent().remove_child(self)
	container_root.add_child(self)

	set_owner(last_owner)

	container_root.bone_name = container.bone_name
	container_root.position = container.position_offset
	container_root.rotation_degrees = container.rotation_degrees_offset

	position = contains_link._get_item_position_offset(actor, container)
	rotation = contains_link._get_item_rotation_offset(actor, container)
	model.transform = actor_model.transform
	
	get_child(0).queue_free()


func _blend_skeletons(delta):
	
	vm_skeleton.transform = world_skeleton.transform
	model.transform = actor_model.transform
	
	for idx in range(world_skeleton.get_bone_count()):
		
		var p_world = world_skeleton.get_bone_pose(idx)
		vm_skeleton.set_bone_pose(idx, p_world)
	
	
	var torso_id = world_skeleton.find_bone('Torso')
	var torso_pose = world_skeleton.get_bone_global_pose(torso_id)
	
	if not follow_camera_torso_origin:
		follow_camera_torso_origin = torso_pose.origin
	
	vm_skeleton.set_bone_global_pose_override(torso_id, torso_pose, 1.0, true)
	
	
	for hidden_bone_id in hidden_bone_ids:

		var p_world = world_skeleton.get_bone_pose(hidden_bone_id)
		p_world.basis = p_world.basis.scaled(Vector3(0.01, 0.01, 0.01))
		
		vm_skeleton.set_bone_pose(hidden_bone_id, p_world)
	
	
	if perspective.fp_skeleton_offset_enable:
		
		var pelvis_id = world_skeleton.find_bone('Pelvis')
		var pelvis_pose = world_skeleton.get_bone_global_pose(pelvis_id)
		pelvis_pose.origin += Vector3(0, 0, -0.3)
		vm_skeleton.set_bone_global_pose_override(pelvis_id, pelvis_pose, 1.0, true)
		
		
		if follow_camera_bone_id:

			var neck_id = vm_skeleton.find_bone('Neck')
			var neck_pose = vm_skeleton.get_bone_global_pose(neck_id)
			var bone_pose = vm_skeleton.get_bone_global_pose(follow_camera_bone_id)
			var camera_offset = -camera.transform.basis.z
			camera_offset.y *= -1

			bone_pose.origin = (
				camera_rig.transform.origin - 
				(neck_pose.origin - bone_pose.origin) +
				Vector3(0, -0.2, -0.05) * camera.transform.basis +
				follow_camera_torso_delta
				)

			vm_skeleton.set_bone_global_pose_override(follow_camera_bone_id, bone_pose, 1.0, true)
		
		follow_camera_torso_delta = follow_camera_torso_delta.lerp(
			(torso_pose.origin - follow_camera_torso_origin) * 5,
			5.0 * delta
			)
		follow_camera_torso_origin = torso_pose.origin
	
	else:
		
		vm_skeleton.clear_bones_global_pose_override()
	
	emit_signal('blended_skeletons')


func _destroy():
	
	model.queue_free()
	
	if container_root:
		container_root.queue_free()
	
	queue_free()


func _enter_tree():
	
	return
	
	_init_duplicate_meshes()


func _ready():
	
	return
	
	if owner == null:
		await get_tree().process_frame
	
	owner.connect('player_index_changed',Callable(self,'_init_mesh_layers'))
	
	await get_tree().process_frame
	
#	if not is_instance_valid(actor):
#		perspective._on_item_released(actor, null)
#		return
	
	if world_skeleton and vm_skeleton:
		behavior.connect('post_advance',Callable(self,'_blend_skeletons'))
	
	_init_container()
	_init_mesh_layers()


func _exit_tree():

	_revert_mesh_layers()
