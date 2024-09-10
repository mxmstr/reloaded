extends Node

@onready var list = find_child('ListContainer')
@onready var hint = find_child('Hint')


func _on_multi_toggled(pressed):
	
	Meta.multi = pressed


func _on_coop_toggled(pressed):
	
	Meta.coop = pressed


func _ready():
	
	var files = []
	var dir = DirAccess.open('res://Scenes/')
	dir.list_dir_begin() # TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547
	
	while true:
		
		var file = dir.get_next()
		
		if file == '':
			break
			
		elif file.ends_with('.tscn'):
			
			var item = load('res://Scenes/UI/Menu.Scenes.Item.tscn').instantiate()
			item.name = file.replace('.tres', '')
			list.add_child(item)
			
			var button = item.get_node('Button')
			button.text = file.replace('.tres', '')
			button.connect('pressed',Callable(get_tree(),'change_scene_to_file').bind('res://Scenes/' + file))
	
	var multi = list.get_node('Multi/CheckBox')
	multi.connect('toggled',Callable(self,'_on_multi_toggled'))
	
	var coop = list.get_node('Coop/CheckBox')
	coop.connect('toggled',Callable(self,'_on_coop_toggled'))

