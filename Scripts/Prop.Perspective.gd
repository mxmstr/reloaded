extends SubViewportContainer

@export var mouse_device = -1
@export var keyboard_device = -1
@export var gamepad_device = -1

@onready var model = $'../Model'
@onready var viewport = get_node('Viewport2D')
@onready var ui = get_node('../UI')
@onready var rig = get_node_or_null('../CameraRig')
@onready var camera = rig.get_node('Camera3D')

func _init_viewport():
	
	var render_width = owner.get_viewport().size.x
	var render_height = owner.get_viewport().size.y
	var window_width = ProjectSettings.get_setting('display/window/size/viewport_width')
	var window_height = ProjectSettings.get_setting('display/window/size/viewport_height')
	var render_scale = ProjectSettings.get_setting('rendering/quality/filters/render_scale')
	
	if Meta.player_count == 1:
		return
	
	if Meta.player_count > 2:
		
		if owner.player_index in [0, 2]:
			ui.position.x = 0
			position.x = 0
		else:
			ui.position.x = window_width / 2
			position.x = window_width / 2

		if owner.player_index in [0, 1]:
			ui.position.y = 0
			position.y = 0
		else:
			ui.position.y = window_height / 2
			position.y = window_height / 2
		
		ui.get_node('SubViewport/Control').size.x =  window_width / 2
		ui.get_node('SubViewport/Control').size.y = window_height / 2
		size.x = window_width / 2
		size.y = window_height / 2
		viewport.size.x = render_width / 2
		viewport.size.y = render_height / 2
		viewport.size *= render_scale

	else:
		
		if owner.player_index == 0:
			ui.position.y = 0
			position.y = 0
		else:
			ui.position.y = window_height / 2
			position.y = window_height / 2

		ui.get_node('SubViewport/Control').size.x = window_width
		ui.get_node('SubViewport/Control').size.y = window_height / 2
		size.x = window_width
		size.y = window_height / 2
		viewport.size.x = render_width
		viewport.size.y = render_height / 2
		viewport.size *= render_scale

func _ready():
	
	await get_tree().process_frame
	
	_init_viewport()
	
	get_tree().root.connect('size_changed',Callable(self,'_init_viewport'))

