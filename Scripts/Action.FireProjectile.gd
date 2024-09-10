extends "res://Scripts/Action.gd"

@onready var reception = get_node_or_null('../../Reception')
@onready var chamber = get_node_or_null('../../Chamber')
@onready var magazine = get_node_or_null('../../Magazine')

func _fire_effect(effect_path):
	
	prints(effect_path)
	ActorServer.Create(effect_path, owner.position, owner.rotation)

func _clone_and_shoot():
	
	if chamber._is_empty():
		return
	
	var item = chamber.items[0]
	var item_clone = chamber._create_and_launch_item(item.system_path)
	
	prints('clone', chamber.root)

func _shoot_array_threaded(count):
	
	var item = chamber._release_front()
	
	for i in range(count):
		
		var thread = Thread.new()
		thread.start(Callable(self,'_shoot_array').bind([item.system_path]))
		
		Meta.threads.append(thread)

func _shoot_array(count):
	
#	var system_path = userdata[0]
	var item = chamber._release_front()
#
#	_clone_and_shoot(item, count - 1)
	
	for i in range(count):
		
		var item_clone = chamber._create_and_launch_item(item.system_path)

func _state_start():

	super()
	
	reception._reflect('UseReact')


func _ready():
	
	await super()
	
	attributes[animation_list[0]].speed = float(owner._get_tag('FireRate'))
