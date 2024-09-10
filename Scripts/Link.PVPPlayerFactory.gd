extends Node

var player_points = [0, 0, 0, 0]
var player_deaths = [0, 0, 0, 0]
var team_points = [0, 0, 0, 0, 0]
var actors = []
var markers = []

signal player_died
signal player_scored
signal player_won
signal team_scored
signal team_won

func _on_action(state, data, player):
	
	if state == 'Die':
		
		$Stinger.play('DEATH')
		call_deferred('_on_player_died', player, data)

func _on_player_died(player, data):
	
	player_deaths[player.player_index] += 1
	emit_signal('player_died', player.player_index, player_deaths[player.player_index])
		
	var behavior = player.get_node('Behavior')
	
	if data.has('shooter'):
		
		var shooter = data.shooter
		var shooter_team = 0
		
		if shooter == null or shooter == player:
			return
		
		if shooter._has_tag('Team'):
			shooter_team = int(shooter._get_tag('Team'))
#		elif shooter._has_tag('Shooter') and shooter._get_tag('Shooter')._has_tag('Team'):
#			shooter_team = int(shooter._get_tag('Shooter')._get_tag('Team'))
		
		var player_team = int(player._get_tag('Team'))
		
		if shooter_team > 0 and shooter_team != player_team:
			
			team_points[shooter_team] += 1
			emit_signal('team_scored', shooter_team, team_points[shooter_team])
			
			if team_points[shooter_team] >= Meta.multi_points_to_win:
				
				emit_signal('team_won', Meta.Team.keys()[shooter_team], team_points)
				
				_suspend_players()
				_play_victory_music()
			
		else:
			
			player_points[shooter.player_index] += 1
			emit_signal('player_scored', shooter.player_index, player_points[shooter.player_index])
			
			if player_points[shooter.player_index] >= Meta.multi_points_to_win:
				
				emit_signal('player_won', shooter.base_name, player_points)
				
				_suspend_players()
				_play_victory_music()

func _play_fight_music():
	
	var animation_list = Array($FightMusic.get_animation_list())
	randomize()
	animation_list.shuffle()
	
	$FightMusic.play(animation_list[0])

func _play_victory_music():
	
	$FightMusic.stop()
	$VictoryMusic.play($VictoryMusic.get_animation_list()[0])

func _suspend_players():
	
	for actor in actors:
		actor.get_node('Behavior')._start_state('Victory')

func _respawn(actor):
	
	var sorted_markers = markers.duplicate()
	sorted_markers.sort_custom(Callable(Meta.SortActors.new(actor),'_descending'))
	sorted_markers.slice(0, 2)
	var marker = sorted_markers[randi() % 3]
#	var current_pos = actor.global_transform.origin
#	var marker_idx = randi() % markers.size()
#	var marker = markers[marker_idx]
	var data = Meta.player_data[actor.player_index]
	
	actor.global_transform.origin = marker.global_transform.origin
	actor.rotation = marker.rotation
	actor.get_node('Stamina').hp = data.hp
	actor.get_node('Behavior').endless = false
	actor.get_node('Behavior')._start_state('Default')

func _add_viewport(actor, data):
	
	var perspective = actor.get_node('Perspective')
	var ui = actor.get_node('UI')
	
	#perspective._init_viewport()
	#perspective.get_node('Viewport2D').world_3d = get_tree().root.world_3d
	#perspective.mouse_device = data.mouse
	#perspective.keyboard_device = data.keyboard
	#perspective.gamepad_device = data.gamepad

func _ready():
	
	if is_queued_for_deletion():
		return
#
#	if not Meta.multi:
#		return
		
	#await get_tree().process_frame
	
	for child in get_children():
		if 'RespawnMarker' in child.name:
			markers.append(child)
		
	for i in range(Meta.player_count):
		
		var data = Meta.player_data[i]
		var marker = markers[i]
		
		var actor = ActorServer.Create(data.character, marker.global_transform.origin, marker.rotation)
		actor.player_index = i
		actor.get_node('Stamina').hp = data.hp
		#actor.get_node('WeaponTargetLock').auto_aim = data.auto_aim
		#actor.get_node('Bot').active = data.bot
		actor._set_tag('Team', str(data.team))
		
		_add_viewport(actor, data)
		
		actors.append(actor)
		
	_play_fight_music()
		
	await get_tree().process_frame
	
	for i in range(Meta.player_count):
		
		var data = Meta.player_data[i]
		actors[i].get_node('Behavior').connect('action_started',Callable(self,'_on_action').bind(actors[i]))
	
