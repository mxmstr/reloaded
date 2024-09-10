extends Control

const radar_scale = 0.25
const radar_margin = 0.9

@export var viewport: NodePath

var window_width
var window_height
var render_scale
var viewport_size
var viewport_size_scaled
var radar_dots = []
var radar_pickups = []
var radius_x
var radius_y
var ammo_container

@onready var radar = get_node('Radar/TextureRect')
@onready var radar_dot = preload('res://Scenes/UI/HUD.RadarDot.tscn')
@onready var radar_ammo = preload('res://Scenes/UI/HUD.RadarAmmo.tscn')

@onready var crosshair = get_node('Crosshair')
@onready var ammo = get_node('Ammo')
@onready var bullet_time_bar = find_child('BulletTime')
@onready var health_bar = find_child('Health')

@onready var righthand = owner.get_node('../RightHandContainer')
@onready var bullet_time = owner.get_node('../BulletTime')
@onready var stamina = owner.get_node('../Stamina')
@onready var camera = owner.get_node('../CameraRig/Camera3D')
@onready var camera_raycast_target = owner.get_node('../CameraRaycastStim/Target')
@onready var pickup_factory = $'/root/Mission/Links/PVPPickupFactory'


func _on_bullet_time_changed(amount):
	
	bullet_time_bar.value = int(amount)


func _on_damaged(hp):
	
	health_bar.value = hp


func _on_ammo_added(item):
	
	_refresh_ammo()


func _on_ammo_removed(item):
	
	_refresh_ammo()


func _on_item_added(item):
	
	if item._has_tag('Firearm'):
		
		ammo.show()
		
		if ammo_container:
			ammo_container.disconnect('item_added',Callable(self,'_on_ammo_added'))
			ammo_container.disconnect('item_removed',Callable(self,'_on_ammo_removed'))
			ammo_container = null
		
	_refresh_ammo()


func _on_item_removed(item):
	
	if ammo_container:
		ammo_container.disconnect('item_added',Callable(self,'_on_ammo_added'))
		ammo_container.disconnect('item_removed',Callable(self,'_on_ammo_removed'))
		ammo_container = null
	
	_refresh_ammo()


func _is_container(node):
	
	if node.get_script() != null:
		
		var script_name = node.get_script().get_path().get_file()
		return script_name == 'Prop.Container.gd'
	
	return false


func _get_ammo_container(item):
	
	var required_tags = item.get_node('Magazine').required_tags_dict.keys()
	var container
	var best_tag_count = 0
	
	for prop in owner.owner.get_children():
		
		if _is_container(prop):
			
			var tag_count = 0
			
			for required_tag in required_tags:
				if required_tag in prop.required_tags_dict.keys():
					tag_count += 1
			
			if tag_count > best_tag_count:
				
				container = prop
				best_tag_count = tag_count
	
	return container


func _refresh_ammo():
	
	var ammo_text = ""
	
	if righthand._is_empty():
		
		ammo_text += 'Unarmed'
	
	elif righthand.items[0]._has_tag('Grenade') or not righthand.items[0].has_node('Magazine'):
		
		ammo_text += righthand.items[0].base_name
	
	else:
		
		var item = righthand.items[0]
		var chamber = item.get_node('Chamber')
		var magazine = item.get_node('Magazine')
		
		if ammo_container == null:
			
			ammo_container = _get_ammo_container(item)
			ammo_container.connect('item_added',Callable(self,'_on_ammo_added'))
			ammo_container.connect('item_removed',Callable(self,'_on_ammo_removed'))
			
			if not chamber.is_connected('item_added',Callable(self,'_on_ammo_added')):
				chamber.connect('item_added',Callable(self,'_on_ammo_added'))
			
			if not chamber.is_connected('item_removed',Callable(self,'_on_ammo_removed')):
				chamber.connect('item_removed',Callable(self,'_on_ammo_removed'))
			
			if not magazine.is_connected('item_added',Callable(self,'_on_ammo_added')):
				magazine.connect('item_added',Callable(self,'_on_ammo_added'))
			
			if not magazine.is_connected('item_removed',Callable(self,'_on_ammo_removed')):
				magazine.connect('item_removed',Callable(self,'_on_ammo_removed'))
		
		var inv_ammo = ammo_container.items.size()
		var chamber_ammo = 1 if chamber.items.size() else 0
		var mag_ammo = magazine.items.size()
		
		ammo_text += str(chamber_ammo + mag_ammo) + ' | ' + str(inv_ammo) + '\n' + item.base_name
	
	ammo.text = ammo_text


func _notification(what):
	
	if what == NOTIFICATION_ENTER_TREE:
		
		pass#set_viewport(get_node(viewport))


func _ready():
	
	window_width = ProjectSettings.get_setting('display/window/size/viewport_width')
	window_height = ProjectSettings.get_setting('display/window/size/viewport_height')
	render_scale = 1.0#ProjectSettings.get_setting('rendering/quality/filters/render_scale')
	
	bullet_time.connect('amount_changed',Callable(self,'_on_bullet_time_changed'))
	stamina.connect('damaged',Callable(self,'_on_damaged'))
	health_bar.value = stamina.hp
	
	await get_tree().process_frame
	
	radius_x = radar.size.x / 2
	radius_y = radar.size.y / 2
	
	#set_viewport(get_node(viewport))
	
	if Meta.multi_radar:
		
		var my_team = int(owner.owner._get_tag('Team'))
		radar.modulate = Meta.TeamColors[my_team]
		
		for actor in $'/root/Mission'.actors:
			
			if actor != owner.owner and actor.get('tags') and actor._has_tag('Human'):
				
				var their_team = int(actor._get_tag('Team'))
				var dot = radar_dot.instantiate()
				
				if my_team == Meta.Team.None:
					dot.modulate = Color.RED
				else:
					dot.modulate = Meta.TeamColors[their_team]
				
				add_child(dot)
				radar_dots.append([dot, actor])
	
	else:
		
		radar.hide()
	
	righthand.connect('item_added',Callable(self,'_on_item_added'))
	righthand.connect('item_removed',Callable(self,'_on_item_removed'))

	_refresh_ammo()


func _process(delta):
	
#	radar_texture.position = size - ((radar_texture.texture.get_size() / 2))
	
	if Meta.multi_radar:
	
		var owner_position = (owner.owner.position * 10).round()
		
		if radar_pickups.size() != pickup_factory.pickups.size():
			
			for radar_pickup in radar_pickups:
				radar_pickup[0].queue_free()
			
			radar_pickups = []
			
			for pickup in pickup_factory.pickups:
				var dot = radar_ammo.instantiate()
				add_child(dot)
				radar_pickups.append([dot, pickup])
		
		
		for dot_info in radar_dots + radar_pickups:
			
			var dot = dot_info[0]
			var actor = dot_info[1]
			
			if not is_instance_valid(actor):
				continue
			
			var actor_position = (actor.position * 10).round()
			var distance_to = owner_position.distance_to(actor_position)
			var direction_to = owner_position.direction_to(actor_position) * -distance_to
			direction_to = direction_to * owner.owner.transform.basis * radar_scale
			direction_to.y = 0
			
			if direction_to.length() > (radius_x * radar_margin):
				direction_to = direction_to.normalized() * (radius_x * radar_margin)
			
			var dot_position = Vector2(radius_x + direction_to.x, radius_y + direction_to.z)
			dot.position = radar.global_position + dot_position
	
	
	viewport_size = owner.get_viewport().size * render_scale
	viewport_size_scaled = Vector2(window_width, window_height) / viewport_size
	var camera_position = camera.unproject_position(camera_raycast_target.global_transform.origin)
	camera_position *= viewport_size_scaled

	crosshair.position = camera_position - crosshair.pivot_offset
