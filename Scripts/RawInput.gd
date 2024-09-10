extends Node

enum Type {
	ABSMOTION,
	RELMOTION,
	BUTTON,
	SCROLL,
	KEYBOARD,
	DISCONNECT,
	MAX
}

enum Axis {
	X,
	Y
}

enum Wheel {
	UP = 0x0A,
	DOWN = 0x0B,
	LEFT = 0x0F,
	RIGHT = 0x0E
}

enum Scroll {
	VERTICAL,
	HORIZONTAL
}

var vkeys = []
var events = {}

signal device_activated


#func _get_status(action, mouse_device, keyboard_device):
#
#	var status = 0
#
#	for event in InputMap.action_get_events(action):
#
#		var device = mouse_device if event is InputEventMouse else keyboard_device
#		var type = Type.BUTTON if event is InputEventMouse else Type.KEYBOARD
#		var item = event.get_vbutton() if event is InputEventMouse else event.get_vkey()
#
#		#print(item) if action == 'Secondary' else null
#
#		if device == -1:
#
#			for i in Input.get_device_count():
#
#				status = events[i][type][item][0]
#
#				if status == 1:
#					return status
#
#		else:
#
#			status = events[device][type][item][0]
#
#			if status == 1:
#				return status
#
#	return status
#
#
#func _get_mousemotion(device):
#
#	if device == -1:
#
#		var offset = Vector2()
#
#		for i in Input.get_device_count():
#			offset += Vector2(
#				events[i][Type.RELMOTION][Axis.X][0],
#				events[i][Type.RELMOTION][Axis.Y][0]
#				)
#
#		return offset
#
#	else:
#
#		return Vector2(
#			events[device][Type.RELMOTION][Axis.X][0],
#			events[device][Type.RELMOTION][Axis.Y][0]
#			)
#
#
#func _ready():
#
#	return
#
##	if not RawInput:
##		return
#
#
#	var devices = Input.get_device_count()
#
#	for action in InputMap.get_actions():
#
#		for event in InputMap.action_get_events(action):
#
#			if event is InputEventKey:
#				vkeys.append(event.get_vkey())
#			elif event is InputEventMouseButton:
#				vkeys.append(event.get_vbutton())
#
#
#	for device in range(devices):
#
#		var typemap = []
#		for type in range(len(Type)):
#
#			var keycodes
#			var keycodemap = {}
#
#			if type == Type.RELMOTION:
#				keycodes = len(Axis)
#			elif type == Type.SCROLL:
#				keycodes = len(Scroll)
#			else:
#				keycodes = vkeys
#
#
#			for keycode in keycodes:
#				keycodemap[keycode] = [0, 0, 0]
#
#			typemap.append(keycodemap)
#
#		events[device] = typemap
#

#func _process(delta):
#
#	return
#
#	if not Meta.rawinput:
#		return
#
#
#	for device in Input.get_device_count():
#
#		events[device][Type.RELMOTION][Axis.X] = [0, 0, 0]
#		events[device][Type.RELMOTION][Axis.Y] = [0, 0, 0]
#
#
#	for event in Input.poll_raw():
#
#		if event.type == Type.SCROLL:
#
#			var item
#
#			if event.item == Scroll.VERTICAL:
#				item = Wheel.UP if event.value > 0 else Wheel.DOWN
#			elif event.item == Scroll.HORIZONTAL:
#				item = Wheel.RIGHT if event.value > 0 else Wheel.LEFT
#
#			event = { 'device': event.device, 'type': Type.BUTTON, 'item': item, 'value': 1, 'minval': 0, 'maxval': 0 }
#
#
#		if event.type in [Type.BUTTON, Type.KEYBOARD]:
#
#			if not event.item in vkeys:
#				return
#
#			if event.type == Type.BUTTON:
#				event.item += 1
#
#			if event.value == 1:
#				emit_signal('device_activated', event.device, event.type)
#
#
#		#print(event)
#
#		events[event.device][event.type][event.item] = [event.value, event.minval, event.maxval]
