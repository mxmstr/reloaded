@tool
extends Node3D

var paths = {}
var path_color = Color(0, 0, 0, 1)
var to_path_color = Color(1, 1, 1, 1)

var line_material = StandardMaterial3D.new()


#func update_waypoint_path(waypoint):
#
#	if Engine.editor_hint:
#
#		if waypoint.next == null:
#
#			paths[waypoint.name] = []
#
#		else:
#
#			var begin = waypoint.position
#			var end = waypoint.get_next_ref().position
#			var path = Array(get_simple_path(begin, end, true))
#
#			path.invert()
#			#path = [begin] + path + [end]
#			paths[waypoint.name] = path
#
#			#print([begin, end, path[0], path[-1]])
#			#print(path)
#
#			$NavGeometry.clear()
#
##			for path in paths.values():
##
##				$NavGeometry.begin(Mesh.PRIMITIVE_LINE_STRIP, null)
##				$NavGeometry.set_color(Color(1, 1, 1, 1))
##
##				for vertex in path:
##					$NavGeometry.add_vertex(vertex + Vector3(0, 0.5, 0))
##
##				$NavGeometry.end()
#
#
#func _ready():
#
#	pass#print(get_path())
#
#
#func _process(delta):
#
#	var new_path_color = path_color.lerp(to_path_color, delta * 10)
#	if str(path_color) == str(new_path_color):
#		if to_path_color == Color(1, 1, 1, 1):
#			to_path_color = Color(0, 0, 0, 1)
#		elif to_path_color == Color(0, 0, 0, 1):
#			to_path_color = Color(1, 1, 1, 1)
#
#	path_color = new_path_color
