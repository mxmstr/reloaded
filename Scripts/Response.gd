extends Node

func _ready():
	
	get_parent().connect('stimulate',Callable(self,'_on_stimulate'))

func _on_stimulate(stim, data): pass
