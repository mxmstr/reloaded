extends Control


func _ready():
	
	var resume = find_child('Resume').get_node('Button')
	var exit = find_child('Exit').get_node('Button')
	
	resume.connect('pressed',Callable(owner.get_node('../HUDMode'),'_start_state').bind('Default'))
	exit.connect('pressed',Callable(get_tree(),'change_scene_to_file').bind('res://Scenes/MainMenu.tscn'))
