extends 'res://Scripts/Response.gd'

var owner_righthand

@onready var audio = get_node_or_null('../../Audio')

func _ready():
	
	super()
	
	await get_tree().process_frame
	
	owner_righthand = owner.owner.get_node_or_null('RightHandContainer')

func _on_stimulate(stim, data):
	
	if stim == 'Damage':

		pass

	# if stim == 'Touch':
		
	# 	if data.source._has_tag('Bullet'):
			
	# 		var damage_mult = 1.0
			
	# 		if owner._has_tag('DamageMult'):
	# 			damage_mult = float(owner._get_tag('DamageMult'))
			
	# 		var damage = float(data.source._get_tag('Damage')) * damage_mult
	# 		var force = float(data.source._get_tag('Force'))
	# 		var direction = data.source.transform.basis.z.normalized()
			
	# 		ActorServer.Stim(owner.owner, 'Damage', data.source, damage, data.position, direction)
	# 		ActorServer.Stim(owner.owner, 'Push', data.source, force, data.position, direction)
			
	# 		audio._start_state('Damage')
			
	# 		var blood = ActorServer.Create(
	# 			'Particles/BloodSquirt',
	# 			data.source.position,
	# 			data.source.rotation.rotated(data.source.transform.basis.y, PI / 2)
	# 			)
			
	# 		ActorServer.Destroy(data.source)
		
	# 	elif data.source._has_tag('Melee'):
			
	# 		var disarm_chance = float(data.source._get_tag('DisarmChance'))
	# 		var damage = float(data.source._get_tag('Damage'))
	# 		var force = float(data.source._get_tag('Force'))
	# 		var hitsound = data.source._get_tag('HitSound')
	# 		var direction = data.source._get_tag('Shooter').transform.basis.z.normalized()
			
	# 		ActorServer.Stim(owner.owner, 'Damage', data.source, damage, data.position, direction)
	# 		ActorServer.Stim(owner.owner, 'Push', data.source, force, data.position, direction)
			
	# 		audio._start_state(hitsound)
			
	# 		if randf() < disarm_chance:
	# 			owner_righthand._release_front()
			
	# 		ActorServer.Destroy(data.source)
		
	# 	elif data.source._has_tag('ImpactGrenade'):
			
	# 		var shooter = data.source._get_tag('Shooter') if data.source._has_tag('Shooter') else data.source
			
	# 		ActorServer.Create('Projectiles/Explosions/Explosion1', data.source.position, data.source.rotation, null, { 'Shooter': shooter })
	# 		ActorServer.Destroy(data.source)
