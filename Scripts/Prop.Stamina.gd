extends Node

@export var hp = 100 : set = _set_hp

var invulnerable = false : set = _set_invulnerable

signal damaged
signal just_died


func _set_invulnerable(new_invulnerable):
	
	invulnerable = new_invulnerable


func _set_hp(new_hp):
	
	hp = new_hp
	emit_signal('damaged', hp)


func _damage(amount):
	
	if invulnerable:
		return
	
	var current = hp
	
	hp -= amount
	hp = max(hp, 0)
	
	emit_signal('damaged', hp)
	
	if current > 0 and hp == 0:
		emit_signal('just_died')
