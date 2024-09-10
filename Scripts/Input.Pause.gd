extends "res://Scripts/Input.gd"

var hud_mode

func _on_just_activated():
	
	hud_mode._start_state('Pause')

func _ready():
	
	hud_mode = get_node_or_null('../HUDMode')
