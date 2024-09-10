extends Node3D

var preloader = ResourcePreloader.new()

var actors
var actor_pool = {}
var actor_pool_size = 1

func _preload():
	
	var actors = Meta._get_files_recursive('res://Scenes/Actors/', '', '.tscn')
	
	for actor in actors:
		
		var actor_res = load(actor)
		var actor_instance = actor_res.instantiate()

		if actor_instance.get('tags') and actor_instance._has_tag('Pooled'):
			
			actor_pool[actor_instance.system_path] = []
			
			for i in range(actor_pool_size):
				actor_pool[actor_instance.system_path].append(load(actor).instantiate())
		
		
		preloader.add_resource(actor, actor_res)

func Create(actor_path, position=null, rotation=null, direction=null, tags={}):
	
	var new_actor
	var resource_path = 'res://Scenes/Actors/' + actor_path + '.tscn'
	
	if actor_path in actor_pool:
		
		new_actor = actor_pool[actor_path][0]
		
		return ProjectileServer.Create(new_actor, position, rotation, direction, tags)
	
	else:
		
		new_actor = preloader.get_resource(resource_path).instantiate()
		
		Meta._merge_dir(new_actor.tags_dict, tags)
		$'/root/Mission/Actors'.add_child(new_actor)
		
		if position:
			new_actor.transform.origin = position
		
		if rotation:
			new_actor.rotation = rotation
		
		if direction:
			
			var target = new_actor.transform.origin - direction
			
			if Vector3.UP.cross(target - new_actor.transform.origin) != Vector3():
				new_actor.look_at(target, Vector3.UP)
		
		return new_actor

func Destroy(actor):
	
	if is_instance_valid(actor):
		
		if actor is Projectile:
			ProjectileServer.Destroy(actor)
		else:
			actor.queue_free()

func SetTag(actor, key, value):
	
	if actor is Projectile:
		ProjectileServer.SetTag(actor, key, value)
		return
	
	actor._set_tag(key, value)

func Teleport(actor, new_position):
	
	if actor is Projectile:
		actor.transform.origin = new_position
	else:
		actor.global_transform.origin = new_position

func Face(actor, new_rotation):
	
	if actor is Projectile:
		actor.transform.basis = Basis(new_rotation)
	else:
		actor.rotation = new_rotation

func EnableCollision(actor):
	
	if actor is Projectile:
		ProjectileServer.EnableCollision(actor)
		return
	
	var collision = actor.get_node_or_null('Collision')
	
	if collision:
		collision.call_deferred('set_disabled', false)

func DisableCollision(actor):
	
	if actor is Projectile:
		ProjectileServer.DisableCollision(actor)
		return
	
	var collision = actor.get_node_or_null('Collision')
	
	if collision:
		collision.call_deferred('set_disabled', true)

func Stim(actor, stim, source=self, intensity=0.0, position=Vector3(), direction=Vector3()):
	
	if not is_instance_valid(actor) or not is_instance_valid(source):
		return

	var data
	
	if actor is Projectile:
		ProjectileServer.Stim(actor, stim, source, intensity, position, direction)
	
	else:
		
		data = {
			'source': source,
			'shooter': source._get_tag('Shooter') if source._has_tag('Shooter') else null,
			'position': position,
			'direction': direction,
			'intensity': intensity
			}
		
		actor.get_node('Reception')._start_state(stim, data)

func SetDirection(actor, release_direction):
	
	if actor is Projectile:
		ProjectileServer.SetDirection(actor, release_direction)
		return
	
	var actor_physics = actor.get_node_or_null('Physics')
	
	if actor_physics == null:
		return
	
	actor_physics._set_direction(release_direction)

func SetDirectionLocal(actor, release_direction):
	
	if actor is Projectile:
		ProjectileServer.SetDirectionLocal(actor, release_direction)
		return
	
	var actor_physics = actor.get_node_or_null('Physics')
	
	if actor_physics == null:
		return
	
	actor_physics._set_direction_local(release_direction)

func SetSpeed(actor, release_speed):
	
	if actor is Projectile:
		ProjectileServer.SetSpeed(actor, release_speed)
		return
	
	var actor_physics = actor.get_node_or_null('Physics')
	
	if actor_physics == null:
		return
	
	actor_physics._set_speed(release_speed)

func SetAngularDirection(actor, new_direction):
	
	if actor is Projectile:
		ProjectileServer.SetAngularDirection(actor, new_direction)
		return
	
	var actor_physics = actor.get_node_or_null('Physics')
	
	if actor_physics == null:
		return
	
	actor_physics.angular_direction = new_direction

func AddCollisionException(actor, other):
	
	if actor is Projectile:
		ProjectileServer.AddCollisionException(actor, other)
		return
	
	if actor is PhysicsBody3D:
		
		actor.add_collision_exception_with(other)
		
		if other.has_node('Hitboxes'):
			for hitbox in other.get_node('Hitboxes').hitboxes:
				actor.add_collision_exception_with(hitbox)
	
	if actor is Area3D:
		
		actor.get_node('Physics').collision_exceptions.append(other)
		
		if other.has_node('Hitboxes'):
			for hitbox in other.get_node('Hitboxes').hitboxes:
				actor.get_node('Physics').collision_exceptions.append(hitbox)

func RemoveCollisionException(actor, other):
	
	if actor is Projectile:
		ProjectileServer.RemoveCollisionException(actor, other)
		return
	
	if actor is PhysicsBody3D:
		
		actor.remove_collision_exception_with(other)
		
		if other.has_node('Hitboxes'):
			for hitbox in other.get_node('Hitboxes').hitboxes:
				actor.remove_collision_exception_with(hitbox)
	
	if actor is Area3D:
		
		actor.get_node('Physics').collision_exceptions.erase(other)
		
		if other.has_node('Hitboxes'):
			for hitbox in other.get_node('Hitboxes').hitboxes:
				actor.get_node('Physics').collision_exceptions.erase(hitbox)

func _enter_tree():
	
	_preload()
