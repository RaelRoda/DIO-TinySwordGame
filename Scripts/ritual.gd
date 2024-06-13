extends Node2D

@onready var animation_player = $AnimationPlayer
@onready var area_2d = $Area2D

var damage : float = 1.0 
#criar uma função para rodar o ataque e outra para o final da inicialização
func start_attacking():
	animation_player.play("Attacking")
	
func deal_damage():
	var bodies = area_2d.get_overlapping_bodies()
	
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy : Enemy = body
			enemy.damage(damage)

func end_ritual():
	
	#pegando os objetos dentro da area
	for body in area_2d.get_overlapping_bodies():
		if body.is_in_group("player"):
			var player : Player = body
			player.is_ritual_active = false #ativando o cdr
			
	queue_free()
