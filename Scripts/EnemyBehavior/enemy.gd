class_name Enemy
extends CharacterBody2D

@onready var popup_marker = $PopupMarker

@export var health: float = 10
@export var en_damage_amount: float
@export var dead_prefab: PackedScene
@export var damage_popup_prefab : PackedScene


func damage(amount: float):
	health -= amount
	print("Vida do inimigo: ", health)
	
	#piscar o node
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(self, "modulate", Color.WHITE, 0.5)
	
	#criar popup do dano tomado
	if damage_popup_prefab: #se temos a scene
		var popup = damage_popup_prefab.instantiate()
		popup.value = amount
		
		#adicionando no inimigo
		get_parent().add_child(popup)
		
		if popup_marker:
			var x_rand = randf_range(-10, 10)
			popup.global_position = popup_marker.global_position
			popup.global_position.x += x_rand
		else:
			popup.global_position = global_position
	
	if health <= 0:
		die()


func die():
	if dead_prefab:
		#instanciar morte
		var dead_scene = dead_prefab.instantiate()
		dead_scene.position = position
		get_parent().add_child(dead_scene)
		
	#destruir esse peao
	queue_free()
	
