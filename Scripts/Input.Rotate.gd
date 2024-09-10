extends Node

const rotate_sensitivity = 2.5
const rotate_sensitivity_mult = 2.5
const aim_offset_range = 0.5
const aim_offset_sensitivity = 1.5
const angular_accel = 0.01
const angular_deaccel = 8.0
const accel_multiplier = 1

@export var positive_input: NodePath
@export var negative_input: NodePath

var right
var left
var right_last_strength = 0.0
var left_last_strength = 0.0
var direction = 0.0
var x_positive = 0.0
var x_negative = 0.0
var deltax = 0.0
var deltax_positive = 0.0
var deltax_negative = 0.0
var speed = 0.0
var speed_pos = 0.0
var speed_neg = 0.0

@onready var camera = get_node_or_null('../../CameraRig/Camera3D')
@onready var camera_raycast = get_node_or_null('../../CameraRaycastStim')
@onready var locomotion = get_node_or_null('../../Locomotion')

func _get_rotation(delta):
	
	var new_speed_pos = right.strength
	var new_speed_pos_delta = abs(new_speed_pos) - abs(speed_pos)
	var accel_power_pos = (right.strength - right_last_strength) * accel_multiplier
	var accel_pos = (angular_accel + 0) if new_speed_pos_delta >= 0 else angular_deaccel
	
	var new_speed_neg = left.strength
	var new_speed_neg_delta = abs(new_speed_neg) - abs(speed_neg)
	var accel_power_neg = (left.strength - left_last_strength) * accel_multiplier
	var accel_neg = (angular_accel + 0) if new_speed_neg_delta >= 0 else angular_deaccel
	
#	speed_pos = smoothstep(speed_pos, new_speed_pos, 3)
#	speed_neg = smoothstep(speed_neg, new_speed_neg, 3)
	speed_pos = Vector2(speed_pos, 0).lerp(
		Vector2(new_speed_pos, 0), min(accel_pos, 1.0)
		).x
	speed_neg = Vector2(speed_neg, 0).lerp(
		Vector2(new_speed_neg, 0), min(accel_neg, 1.0)
		).x
	
	right_last_strength = right.strength
	left_last_strength = left.strength
	
#	var power = abs(new_speed_pos - new_speed_neg)
#	return pow(rotate_sensitivity * (new_speed_pos - new_speed_neg), power)
	return (speed_pos - speed_neg) * rotate_sensitivity * pow(rotate_sensitivity_mult, abs(new_speed_pos - new_speed_neg))
	#return (speed_pos - speed_neg) * rotate_sensitivity

func _ready():
	
	right = get_node(positive_input)
	left = get_node(negative_input)
