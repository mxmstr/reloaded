extends Node

const schemas_dir = 'res://Scenes/Schemas/'
const schemas_extension = '.schema.tscn'

@export var schema: String
@export var random = false

var animation_list = []
var attributes = {}
var animation

func _load_animations(_schema, _prefix='', parent_override=null):
	
	if _schema == null or _schema == '':
		return
	
	var owner_tags = owner.tags_dict.keys()
	var schema_animation_player = Meta.LoadSchema(_schema, owner_tags).instantiate()
	
	var _animation_list = Array(schema_animation_player.get_animation_list())
	var _attributes = {}
	
	if schema_animation_player.get('attributes'):
		var test_json_conv = JSON.new()
		test_json_conv.parse(schema_animation_player.attributes)
		_attributes = test_json_conv.get_data()
		if _attributes == null:
			push_warning(_schema)
		
	for animation_name in _animation_list:
		
		var animation_res = schema_animation_player.get_animation(animation_name)
		(get_parent() if parent_override == null else parent_override)._add_animation(animation_name, animation_res)
		
		animation_name = _prefix + animation_name
		
		if _attributes != null:
			
			if not attributes.has(animation_name):
				attributes[animation_name] = {}
			
			if _attributes.has(animation_name):
				Meta._merge_dir(attributes[animation_name], _attributes[animation_name])
			
			if '*' in _attributes.keys():
				Meta._merge_dir(attributes[animation_name], _attributes['*'])
		
		else:
			
			attributes[animation_name] = {}
	
	if random:
		randomize()
		_animation_list.shuffle()
	
	animation = _animation_list[0]
	
	return _animation_list

func _randomize_animation():
	
	if len(animation_list) > 0:
		
		randomize()
		animation_list.shuffle()
		animation = animation_list[0]

func _ready():
	
	await get_tree().process_frame
	
	animation_list = _load_animations(schema)
