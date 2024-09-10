extends "res://Scripts/Action.gd"

@export var can_use_item = false
@export var can_zoom = false
@export var root_motion_use_model = false
@export var layer = Meta.BlendLayer.MOVEMENT

@export var lock_stance = false
@export var lock_movement = false
@export var lock_rotation = false
#@export var stance = 'Standing'
@export var align_model_to_aim = false
@export var fp_skeleton_offset = true
@export var camera_mode_state = 'Default'
@export var hud_mode_state = 'Default'
@export var input_context_list = 'Default'
@export var gravity_scale = 1.0
@export var invulnerable = false

@onready var viewport = get_node_or_null('../../Perspective/Viewport2D')
@onready var physics = get_node_or_null('../../Physics')
@onready var perspective = get_node_or_null('../../Perspective')
@onready var locomotion = get_node_or_null('../../Locomotion')
@onready var stamina = get_node_or_null('../../Stamina')
@onready var camera_rig = get_node_or_null('../../CameraRig')
@onready var camera = get_node_or_null('../../CameraRig/Camera3D')
@onready var camera_mode = get_node_or_null('../../CameraMode')
@onready var hud_mode = get_node_or_null('../../HUDMode')
@onready var anim_layer_movement = get_node_or_null('../../AnimLayerMovement')
@onready var weapon_target_lock = get_node_or_null('../../WeaponTargetLock')
@onready var bullet_time = get_node_or_null('../../BulletTime')
@onready var input_context = get_node_or_null('../../InputContext')

func _apply_attributes(_attributes):

	if not super(_attributes):
		return false

	get_parent().can_use_item = can_use_item
	get_parent().can_zoom = can_zoom
	get_parent().root_motion_use_model = root_motion_use_model
	get_parent()._set_layer(layer)

	locomotion.lock_stance = lock_stance
	locomotion.lock_rotation = lock_rotation
	locomotion.lock_movement = lock_movement
	#stance.stance = stance.StanceType[new_stance]
	#weapon_target_lock.align_model = align_model_to_aim
	physics.root_motion_use_model = root_motion_use_model
	physics.gravity_scale = gravity_scale
	#stamina.invulnerable = invulnerable
	#perspective.fp_skeleton_offset_enable = fp_skeleton_offset
	#	camera_mode._start_state(camera_mode_state)
	#hud_mode._start_state(hud_mode_state)
	input_context.input_context = input_context_list

	var time_scaled = _attributes.time_scaled if _attributes.has('time_scaled') else true

	if bullet_time and bullet_time.active and not time_scaled:
		if _attributes.has('speed'):
			_attributes.speed /= Engine.time_scale
		else:
			_attributes.speed = 1 / Engine.time_scale
	
	return true


