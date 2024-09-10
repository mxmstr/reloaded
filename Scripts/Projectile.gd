class_name Projectile
extends RefCounted

var valid = true
var system_path : String
var visible = true : get = _get_visible, set = _set_visible
var transform : Transform3D
var global_transform : Transform3D : get = _get_global_transform, set = _set_global_transform
var position : Vector3 : get = _get_translation, set = _set_translation
var rotation : Vector3 : get = _get_rotation, set = _set_rotation
var direction : Vector3
var angular_direction : Vector2
var speed : float
var model : RID
var particles : RID
var particles_transform : Transform3D
var collision_disabled = false
var collision_mask : int
var collision_shape_rid : RID
var collision_exceptions : Array
var tags_dict : Dictionary


func get_parent():
	
	return ProjectileServer


func look_at(target, up):
	
	var lookat = Transform3D()
	lookat.origin = transform.origin
	lookat = lookat.looking_at(target, up)
	transform = lookat


func _set_visible(new_visible):
	
	if not valid:
		return
	
	if model:
		RenderingServer.instance_set_visible(model, new_visible)
	
	if particles:
		RenderingServer.instance_set_visible(particles, new_visible)
	
	visible = new_visible


func _get_visible():
	
	return visible


func _has_tag(tag):
	
	return tags_dict.has(tag)


func _has_tags(_tags):
	
	return tags_dict.has_all(_tags)


func _get_tag(tag):
	
	return tags_dict[tag]


func _get_tags(_tag):
	
	var matching = []
	
	for tag in tags_dict:
		if _tag in tag:
			matching.append(tags_dict[tag])
	
	return matching


func _set_tag(tag, value):
	
	tags_dict[tag] = value


func _set_global_transform(new_global_transform):
	
	transform = new_global_transform


func _get_global_transform():
	
	return transform


func _set_translation(new_translation):
	
	transform.origin = new_translation


func _get_translation():
	
	return transform.origin


func _set_rotation(new_rotation):
	
	transform.basis = Basis(new_rotation)


func _get_rotation():
	
	return transform.basis.get_euler()

