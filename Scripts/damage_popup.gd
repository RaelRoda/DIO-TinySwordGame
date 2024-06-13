extends Node2D

var value : float = 0

func _ready():
	$Node2D/Label.text = str(value)
