extends Node


func _ready():
	
	await get_tree().process_frame
	
	if not Meta.multi_outlines:
		return
	
	var outline
	var mesh = $'../Model'.get_child(0).get_child(0).mesh
	var team = int(owner._get_tag('Team'))
	var color = Meta.TeamColors[team]
	color.a = 0.5
	
	if Meta.multi_xray:
		outline = load('res://Shaders/OutlineXray.tres').duplicate(true)
	else:
		outline = load('res://Shaders/Outline.tres').duplicate(true)
	
	outline.set_shader_parameter('color', color)
	
	for idx in mesh.get_surface_count():
		
		mesh.surface_set_material(idx, mesh.surface_get_material(idx).duplicate(true))
		mesh.surface_get_material(idx).next_pass = outline
