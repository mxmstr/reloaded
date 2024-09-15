extends RayCast3D

const shoulder_bone_name = 'shoulders'

var model
var camera
var camera_raycast
var camera_raycast_target
var perspective

var enemies = []
var visible_enemies = []
var targeted_enemy
var targeted_enemy_bone
var shoulder_bone
var auto_aim = false
var equipped = false
var align_model = false

@onready var behavior = get_node_or_null('../Behavior')
@onready var physics = get_node_or_null('../Physics')
@onready var stamina = get_node_or_null('../Stamina')
@onready var bullet_time = get_node_or_null('../BulletTime')
@onready var right_hand = get_node_or_null('../RightHandContainer')
@onready var left_hand = get_node_or_null('../LeftHandContainer')
@onready var right_punch = get_node_or_null('../RightPunchContainer')
@onready var left_punch = get_node_or_null('../LeftPunchContainer')
@onready var right_kick = get_node_or_null('../RightKickContainer')
@onready var left_kick = get_node_or_null('../LeftKickContainer')

func _on_fire(projectile):
	
	if not is_instance_valid(projectile): return
	
	var direction = projectile.global_transform.origin.direction_to(camera_raycast_target.global_transform.origin)
	var target_pos = projectile.global_transform.origin - direction

	if projectile._has_tag('Grenade'):
		projectile.get_node('Physics')._set_direction_local(direction * -1)
		projectile.get_node('Physics').speed = projectile.get_node('Physics').speed

	else:		
		projectile.look_at(target_pos, Vector3.UP)

func _on_punch(projectile):
	
	projectile.rotation = owner.rotation

func _on_camera_entered(_camera, actor):
	
	if _camera == camera and actor.get_node('Stamina').hp > 0:
		
		visible_enemies.append(actor)
		_select_target()

func _on_camera_exited(_camera, actor):
	
	if _camera == camera:
		
		visible_enemies.erase(actor)
		_select_target()

func _on_item_equipped(item):
	
	if item._has_tag('Firearm'):
		
		item.get_node('Chamber').connect('item_released',Callable(self,'_on_fire'))
		
		if item._has_tag('AutoAim'):
			equipped = true
			_select_target()
		else:
			equipped = false

func _on_lefthand_item_equipped(item):
	
	if item._has_tag('Firearm'):
		item.get_node('Chamber').connect('item_released',Callable(self,'_on_fire'))

func _on_item_dequipped(item):
	
	if is_instance_valid(item) and item._has_tag('Firearm'):
		
		item.get_node('Chamber').disconnect('item_released',Callable(self,'_on_fire'))
		
		if item._has_tag('Grenade') and item.get_node('Behavior').current_state == 'FireProjectile':
			_on_fire(item)
	
	equipped = false
	targeted_enemy = null
	targeted_enemy_bone = null

func _on_lefthand_item_dequipped(item):
	
	if is_instance_valid(item) and item._has_tag('Firearm'):
		item.get_node('Chamber').disconnect('item_released',Callable(self,'_on_fire'))

func _select_target():
	
	if not visible_enemies.size():
		targeted_enemy = null
		targeted_enemy_bone = null
		return
		
	var closest_enemy
	var closest_distance
	
	for enemy in visible_enemies:
		
		var alive = enemy.get_node('Stamina').hp > 0
		var height = enemy.get_node('Collision').shape.size.y
		var screen_pos = camera.unproject_position(enemy.position + Vector3(0, height / 2, 0))
		var distance = screen_pos.distance_to(Vector2(perspective.size.x / 2, perspective.size.y / 2))
		
		if alive and (not closest_distance or distance < closest_distance):
			
			closest_distance = distance
			closest_enemy = enemy
	
	if closest_enemy:
		targeted_enemy = closest_enemy
		targeted_enemy_bone = targeted_enemy.get_node('Hitboxes')._get_bone(shoulder_bone_name)
	else:
		targeted_enemy = null
		targeted_enemy_bone = null

func _ready():
	
	model = get_node_or_null('../Model')
	camera = get_node_or_null('../CameraRig/Camera3D')
	camera_raycast = get_node_or_null('../CameraRaycastStim')
	camera_raycast_target = get_node_or_null('../CameraRaycastStim/Target')
	perspective = get_node_or_null('../Perspective')
	
	right_hand.connect('item_added',Callable(self,'_on_item_equipped'))
	right_hand.connect('item_removed',Callable(self,'_on_item_dequipped'))
	left_hand.connect('item_added',Callable(self,'_on_lefthand_item_equipped'))
	left_hand.connect('item_removed',Callable(self,'_on_lefthand_item_dequipped'))
	right_punch.connect('item_released',Callable(self,'_on_punch'))
	left_punch.connect('item_released',Callable(self,'_on_punch'))
	right_kick.connect('item_released',Callable(self,'_on_punch'))
	left_kick.connect('item_released',Callable(self,'_on_punch'))
	
	await owner.get_node('Hitboxes').setup_finished
	
	shoulder_bone = owner.get_node('Hitboxes')._get_bone(shoulder_bone_name)
	
	for actor in $'/root/Mission'.actors:
		
		if actor != owner and actor.get('tags') and actor._has_tag('Team'):
			
			var their_team = int(actor._get_tag('Team'))
			var my_team = int(owner._get_tag('Team'))
			
			if their_team == Meta.Team.None or their_team != my_team:
				
				enemies.append(actor)
				actor.get_node('VisibleOnScreenNotifier3D').connect('screen_entered',Callable(self,'_on_camera_entered').bind(actor))
				actor.get_node('VisibleOnScreenNotifier3D').connect('screen_exited',Callable(self,'_on_camera_exited').bind(actor))

func _process(delta):
	
	var dead = stamina.hp == 0
	
	if dead:
		
		camera_raycast.move_target = true
		model.rotation = Vector3(0, 0, 0)
	
	else:
		
		var locking_on = false
		var target_pos
		
		if auto_aim and equipped and targeted_enemy:

			if not is_instance_valid(targeted_enemy) or \
				targeted_enemy.get_node('Stamina').hp == 0:
				_select_target()
				return

			if camera_raycast.get_collider() and camera_raycast.get_collider().owner in enemies:
				
				camera_raycast.move_target = true
				targeted_enemy = camera_raycast.get_collider().owner
				targeted_enemy_bone = targeted_enemy.get_node('Hitboxes')._get_bone(shoulder_bone_name)

			else:

				target_pos = targeted_enemy_bone.global_transform.origin
				#global_transform.origin = shoulder_bone.global_transform.origin

				var space_state = get_world_3d().direct_space_state
				var result = space_state.intersect_ray(
					PhysicsRayQueryParameters3D.create(shoulder_bone.global_transform.origin, target_pos, collision_mask, [owner])
					)

				if result:					
					camera_raycast.move_target = true

				else:					
					locking_on = true
					camera_raycast.move_target = false
					target_pos = camera_raycast.global_transform.origin + (camera_raycast.global_transform.origin.direction_to(target_pos).normalized() * 5)
					camera_raycast_target.global_transform.origin = camera_raycast_target.global_transform.origin.move_toward(target_pos, 100 * delta)

		else:			
			camera_raycast.move_target = true
		
		var model_pos = model.global_transform.origin
		
		if align_model and not locking_on:
			target_pos = model_pos - camera_raycast.global_transform.basis.z
		
		if align_model or locking_on:
			
			target_pos.y = model_pos.y
			
			if target_pos != model_pos:
				model.look_at(target_pos, Vector3.UP)
				model.rotate_y(deg_to_rad(180))
		
		else:			
			model.rotation = Vector3(0, 0, 0)
