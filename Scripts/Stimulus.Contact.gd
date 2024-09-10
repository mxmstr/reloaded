extends Node

@export_multiline var stim_data = '[\n\t{\n\t\t"stim_type": "Impact",\n\t\t"stim_intensity": 0\n\t}\n]'
@export var one_shot = false
@export var continuous = false
@export var raycast = false

var active = true
var stim_data_array = []
var collisions = []

@onready var collision = get_node_or_null('../Collision')
@onready var physics = get_node_or_null('../Physics')

func _ready():
	
	var test_json_conv = JSON.new()
	test_json_conv.parse(stim_data)
	stim_data_array = test_json_conv.get_data()

#func _test_raycast():
#
#	var space_state = owner.get_world_3d().direct_space_state
#	var 
#
#	var result = space_state.intersect_ray(
#		collision.global_transform.origin, target_pos, [owner], owner.collision_mask
#		)
#
#
#	return

func _physics_process(delta):
	
	if not active or owner.is_queued_for_deletion() or (collision == null and collision.disabled):
		return
		
	var colliders = []
	
	for collision_ in collisions:
		colliders.append(collision_.get_collider())
		
	var new_collisions = []
	
	for collision_ in physics._get_collisions():
		
		if continuous or not collision_.get_collider() in colliders:
			
			for stim_data in stim_data_array:

				var stim_type = stim_data['stim_type']
				var stim_intensity = stim_data['stim_intensity']

				ActorServer.Stim(
					collision_.get_collider(),
					stim_type,
					owner, 
					physics._get_speed() * -1 if stim_intensity == 0 else stim_intensity,
					collision_.get_position(),
					collision_.get_normal() * -1
					)
		
		new_collisions.append(collision_)
	
	collisions = new_collisions
	
	if one_shot:
		active = false
