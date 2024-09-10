@tool # Needed so it runs in editor.
extends EditorScenePostImport

func _set_owner(child, new_owner):
	
	child.owner = new_owner
	
	for _child in child.get_children():
		_set_owner(_child, new_owner)

func _post_import(scene):
	
	var skeleton = scene.get_child(0).duplicate()
	skeleton.name = scene.name
	
	for child in skeleton.get_children():
		_set_owner(child, skeleton)
	
	return skeleton
