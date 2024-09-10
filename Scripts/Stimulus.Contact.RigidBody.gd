extends Node

@export_multiline var stim_data = '[\n\t{\n\t\t"stim_type": "Impact",\n\t\t"stim_intensity": 0\n\t}\n]'
@export var continuous = false

var stim_data_array = []

@onready var collision = get_node_or_null('../Collision')
@onready var physics = get_node_or_null('../Physics')

func _on_body_shape_entered(body_id, body, body_shape, local_shape):
	
	for stim_data in stim_data_array:

		var stim_type = stim_data['stim_type']
		var stim_intensity = stim_data['stim_intensity']

		ActorServer.Stim(
			body,
			stim_type,
			owner, 
			physics.speed if stim_intensity == 0 else stim_intensity,
			owner.global_transform.origin,
			physics.direction
			)

func _ready():

	var test_json_conv = JSON.new()
	test_json_conv.parse(stim_data)
	stim_data_array = test_json_conv.get_data()
	
	owner.contact_monitor = true
	owner.max_contacts_reported = 4
	
	owner.connect('body_shape_entered',Callable(self,'_on_body_shape_entered'))
