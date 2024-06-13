extends Node2D

@onready var path_follow_2d = $Path2D/PathFollow2D

@export var creatures: Array[PackedScene] 
@export var mobs_per_minute : float = 60

var cooldown := 0.0
	
func _process(delta):
	#temporizador
	cooldown -= delta
	
	if cooldown > 0: return
	
	#frequencia de mobs por minuto
	var interval = 60.0 / mobs_per_minute
	cooldown = interval
	
	#instanciar uma criatura no mundo
	var index = randi_range(0, creatures.size() - 1)
	var creature_scene = creatures[index]
	var creature = creature_scene.instantiate()
	creature.global_position = get_point()
	get_parent().add_child(creature)
	


func get_point():
	path_follow_2d.progress_ratio = randf()
	
	return path_follow_2d.global_position
	
