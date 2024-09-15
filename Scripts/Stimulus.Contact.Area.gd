extends Node

@export_multiline var stim_data = '[\n\t{\n\t\t"stim_type": "Impact",\n\t\t"stim_intensity": 0\n\t}\n]'
@export var one_shot = false
@export var raycast = false
@export var raycast_collision_mask = 0 # (int, LAYERS_3D_PHYSICS)

var active = true
var stim_data_array = []
var one_shot_frames = 2

@onready var collision = get_node_or_null('../Collision')
@onready var physics = get_node_or_null('../Physics')

func _on_body_shape_entered(body_id, body, body_shape, area_shape):
	
	if not active or not physics.active:
		return
	
	if body in physics.collision_exceptions:
		return
	
	if raycast:
		
		var body_collision = body.get_node_or_null('Collision')
		
		if body_collision and not _test_raycast(body):
			return
	
	for stim_data in stim_data_array:

		var stim_type = stim_data['stim_type']
		var stim_intensity = stim_data['stim_intensity']

		ActorServer.Stim(
			body,
			stim_type,
			owner, 
			physics._get_speed() * -1 if stim_intensity == 0 else stim_intensity,
			owner.transform.origin,
			owner.transform.basis.z * -1
			)

func _test_raycast(body):
	
	var space_state = owner.get_world_3d().direct_space_state
	var from_position = collision.global_transform.origin
	var to_position = body.get_node('Collision').global_transform.origin
	
	var result = space_state.intersect_ray(
		from_position,
		to_position,
		[owner] + physics.collision_exceptions, 
		owner.collision_mask#raycast_collision_mask
		)
	
	return not result.is_empty() and result.collider == body
	
#
#
#	if not space_state.intersect_ray(
#		from_position,
#		to_position,
#		[owner] + physics.collision_exceptions, 
#		raycast_collision_mask
#		).is_empty():
#		return true
#
#	return true

func _ready():
	
	var test_json_conv = JSON.new()
	test_json_conv.parse(stim_data)
	stim_data_array = test_json_conv.get_data()

	owner.connect('body_shape_entered',Callable(self,'_on_body_shape_entered'))

func _physics_process(delta):
	
	if one_shot:
		
		if one_shot_frames == 0:
			if owner.is_connected('body_shape_entered',Callable(self,'_on_body_shape_entered')):
				owner.disconnect('body_shape_entered',Callable(self,'_on_body_shape_entered'))
		else:
			one_shot_frames -= 1
