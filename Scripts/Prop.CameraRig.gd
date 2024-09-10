extends Node3D

@export var viewport: NodePath

@export var path: NodePath
@export var bone_name: String

@export var clamp_camera = true
@export var cam_max_x = 0.0
@export var cam_max_y = PI / 2
@export var camera_offset: Vector3
@export var position_offset = Vector3()
@export var rotation_degrees_offset = Vector3()

var root

@onready var camera = get_node_or_null('Camera3D')

func _clamp_camera():
	
	if clamp_camera:
		
		camera.rotation.x = clamp(camera.rotation.x, -cam_max_y, cam_max_y)
		camera.rotation.y = clamp(camera.rotation.y, -cam_max_x, cam_max_x)

func _rotate_camera(delta_x, delta_y):
	
	#camera.rotation.x += delta_x
	rotation.x += delta_x
	camera.rotation.y += delta_y
	
	_clamp_camera()

func _align_to_camera():
	
	var target = owner.global_transform.origin + camera.global_transform.basis.z
	target.y = owner.global_transform.origin.y
	owner.look_at(target, Vector3(0, 1, 0))
	
	camera.rotation.y = 0

func _reset_camera():
	
	if root != null:
		
		root.queue_free()
		root = null
	
	if path != null and not path.is_empty():
		
		root = BoneAttachment3D.new()
		get_node(path).add_child(root)
	
		if bone_name != '':
			root.bone_name = bone_name
	
	_clamp_camera()

func _ready():
	
	_reset_camera()
	
	await get_tree().process_frame
	
	#$Camera3D.set_viewport(get_node(viewport))
	camera.current = true
	camera.position = camera_offset

func _process(delta):

	if root:# and position_offset and rotation_degrees_offset:

		if position_offset == null or rotation_degrees_offset == null:
			return

#		root.rotation_degrees = Vector3(0, 180, 0)

		global_transform.origin = root.global_transform.origin

		var target_pos = global_transform.origin + root.global_transform.basis.z
		look_at(target_pos, -root.global_transform.basis.y)
#		rotate_x(deg_to_rad(rotation_degrees_offset.x))
#		rotate_y(deg_to_rad(rotation_degrees_offset.y))
#		rotate_z(deg_to_rad(rotation_degrees_offset.z))
#
#		translate_object_local(position_offset)

		#global_transform.basis = Basis(root.global_transform.basis.get_rotation_quaternion())#.rotated(root.global_transform.basis.y, deg_to_rad(180))
#		global_transform.basis = root.global_transform.basis.rotated(root.global_transform.basis.z, deg_to_rad(180))
	
#	_clamp_camera()
