extends Area3D

@export_multiline var stim_data = '[\n\t{\n\t\t"stim_type": "Impact",\n\t\t"stim_intensity": 0\n\t}\n]'

var stim_data_array = []
var collision_disabled = false

@onready var collision = get_node_or_null('../Collision')
@onready var physics = get_node_or_null('../Physics')

signal stimulate

func _on_body_entered(body):
	
	if collision == null or collision.disabled:
		return

	if body in physics.collision_exceptions:
		return

	for stim_data in stim_data_array:

		var stim_type = stim_data['stim_type']
		var stim_intensity = stim_data['stim_intensity']
		
		ActorServer.Stim(body, stim_type, owner)

	emit_signal('stimulate')

func _on_body_exited(body):

	pass

func _ready():

	var test_json_conv = JSON.new()
	test_json_conv.parse(stim_data)
	stim_data_array = test_json_conv.get_data()

	connect('body_entered',Callable(self,'_on_body_entered'))
	connect('body_exited',Callable(self,'_on_body_exited'))

func _physics_process(delta):
	
	if collision and collision.disabled:
		collision_disabled = true
	
	elif collision_disabled and collision and not collision.disabled:
		
		for body in get_overlapping_bodies():
			_on_body_entered(body)
		
		collision_disabled = false
	
