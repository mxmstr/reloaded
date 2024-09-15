extends Node

@export var source: PackedScene

var bone_attachments = []
var hitboxes = []
var bone_to_hitbox = {}

@onready var skeleton = get_node('../Model').get_child(0)

signal setup_finished

func _add_children():
	
	for child in source.instantiate().get_child(0).get_children():
		
		if child is BoneAttachment3D:
			
			var new_bone = BoneAttachment3D.new()
			new_bone.bone_name = child.bone_name
			owner.get_node('Model').get_child(0).add_child(new_bone)
			new_bone.name = child.name
			
			for hitbox in child.get_children():
				
				var export_props = {}
				
				for prop in hitbox.get_property_list():
					if prop.usage == 8199:
						export_props[prop.name] = hitbox.get(prop.name)
				
				var new_hitbox = hitbox.duplicate()
				new_bone.add_child(new_hitbox)
				
				new_hitbox.name = child.name
				
				for prop in export_props:
					new_hitbox.set(prop, export_props[prop])
				
				new_hitbox.set_owner(owner)
				
				hitboxes.append(new_hitbox)
				bone_to_hitbox[new_bone.bone_name] = new_hitbox
			
			bone_attachments.append(new_bone)

func _get_bone(bone_name):
	
	return bone_to_hitbox[bone_name]

func _ready():
	
	await get_tree().process_frame
	
	_add_children()
	
	emit_signal('setup_finished')
