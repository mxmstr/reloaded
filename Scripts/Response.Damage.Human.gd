extends 'res://Scripts/Response.gd'

@onready var behavior = get_node_or_null('../../Behavior')
@onready var physics = get_node_or_null('../../Physics')
@onready var stamina = get_node_or_null('../../Stamina')
@onready var right_hand = get_node_or_null('../../RightHandContainer')
@onready var inventory = get_node_or_null('../../InventoryContainer')
@onready var inv_9mm = get_node_or_null('../../Bullet9mmContainer')
@onready var inv_rifle = get_node_or_null('../../BulletRifleContainer')
@onready var inv_magnum = get_node_or_null('../../BulletMagnumContainer')
@onready var inv_shotgun = get_node_or_null('../../BulletShotgunContainer')
@onready var inv_sniper = get_node_or_null('../../BulletSniperContainer')
@onready var inv_grenade = get_node_or_null('../../BulletGrenadeContainer')
@onready var voice_audio = get_node_or_null('../../VoiceAudio')


func _on_stimulate(stim, data):
	
	if stim == 'Push' and stamina.hp > 0:
		
		var force = float(data.intensity)#data.source._get_tag('Force'))
		
		physics.velocity += force * Vector3(data.direction.x, 0, data.direction.z)
	
	
	if stim == 'Damage' and stamina.hp > 0:
		
		var damage = int(data.intensity)#data.source._get_tag('Damage'))
		stamina._damage(damage)
		
		voice_audio._start_state('Oof')
		
		if stamina.hp == 0:
			
			right_hand._release_front()
			inventory._release_all()
			
			for item_map in [[inv_9mm, 'Items/AmmoBox9mm'],
					[inv_rifle, 'Items/AmmoBoxRifle'],
					[inv_magnum, 'Items/AmmoBoxMagnum'],
					[inv_shotgun, 'Items/AmmoBoxShotgun'],
					[inv_sniper, 'Items/AmmoBoxSniper']]:
				
				if not item_map[0]._is_empty():
					
					var ammo_box = ActorServer.Create(item_map[1], inventory.global_transform.origin)
					ammo_box._set_tag('amount', str(item_map[0].items.size()))
					#inventory._exclude_recursive(ammo_box, owner)
					
					item_map[0]._delete_all()
			
			if data.source._has_tag('Explosion'):
				
				var target_pos = data.source.transform.origin
				target_pos.y = owner.transform.origin.y
				owner.look_at(target_pos, Vector3.UP)
				owner.rotate_y(deg_to_rad(180))
				
				behavior._start_state('DieExplosion', { 'shooter': data.shooter })
			
			else:
				behavior._start_state('Die', { 'shooter': data.shooter })
