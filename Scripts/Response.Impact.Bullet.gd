extends 'res://Scripts/Response.gd'

func _on_stimulate(stim, data):
	
	if stim == 'Impact':
		
		if data.source._has_tag('Map'):
			
			owner.position = data.position
			
			#Meta.AddActor('Particles/Smoke', owner.position)
			#Meta.AddActor('Particles/Sparks', owner.position, null, data.direction)
			
			ActorServer.Destroy(owner)
		
		elif data.source._has_tag('Hitbox'):
			
			ActorServer.Create('Particles/BloodSquirt', owner.position, null, data.direction)
			ActorServer.Destroy(owner)
			
