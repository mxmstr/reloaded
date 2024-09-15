extends Node

@export_multiline var stim_data = '[\n\t{\n\t\t"stim_type": "Impact",\n\t\t"stim_intensity": 0\n\t}\n]'
@export var one_shot = false
@export var raycast_collision_mask = 0 # (int, LAYERS_3D_PHYSICS)
@export var length = 1.0

var active = true
var stim_data_array = []

@onready var collision = get_node_or_null('../Collision')
@onready var physics = get_node_or_null('../Physics')

func _on_before_move(velocity):
	
	if not active or not physics.active or owner.is_queued_for_deletion():
		return
	
	var space_state = owner.get_world_3d().direct_space_state
	var params = PhysicsRayQueryParameters3D.create(
		owner.transform.origin,
		owner.transform.origin + velocity,
		raycast_collision_mask,
		[owner] + physics.collision_exceptions
		)
	
	var result = space_state.intersect_ray(params)
	
	if not result.is_empty():
		
		for stim_data in stim_data_array:
			
			var stim_type = stim_data['stim_type']
			var stim_intensity = stim_data['stim_intensity']

			ActorServer.Stim(
				result.collider, 
				stim_type,
				owner, 
				physics._get_speed() * -1 if stim_intensity == 0 else stim_intensity,
				result.position,
				result.normal * -1
				)

func _ready():

	var test_json_conv = JSON.new()
	test_json_conv.parse(stim_data)
	stim_data_array = test_json_conv.get_data()
	
	physics.connect('before_move',Callable(self,'_on_before_move'))
