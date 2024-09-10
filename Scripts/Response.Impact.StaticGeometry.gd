extends 'res://Scripts/Response.gd'

func _on_stimulate(stim, data):
	
	if stim == 'Impact':
		
		# if data.source._has_tag('Bullet'):
			
		# 	ActorServer.Teleport(data.source, data.position)
			
		# 	#Meta.AddActor('Particles/Smoke', owner.position)
		# 	var sparks = ActorServer.Create(
		# 		'Particles/Sparks', 
		# 		data.source.position, 
		# 		data.source.rotation.rotated(data.source.transform.basis.y, PI / 2)
		# 		)
			
		# 	#sparks.rotate_y(deg_to_rad(180))
			
		# 	#ActorServer.Destroy(data.source)
		
		get_parent()._reflect()
