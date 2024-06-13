class_name Player
extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var sword_area: Area2D = $SwordArea
@onready var hitbox_area: Area2D = $HitboxArea
@onready var health_progress_bar = $HealthProgressBar

@export_group("Status")
@export var speed: float = 3
@export var sword_damage: float = 2
@export var max_health : float = 100
@export var health: float = 100
@export var dead_prefab: PackedScene

@export_group("Ritual")
@export var ritual_damage : float = 2
@export var ritual_interval : float = 5
@export var ritual_scene : PackedScene

var input_vector : Vector2 = Vector2(0, 0)
var is_running: bool = false
var was_running: bool = false
var is_attacking: bool = false

var attack_cooldown: float = 0.0
var hitbox_cooldown: float = 0.0
var ritual_cooldown: float = 0.0
var is_ritual_active := false


signal meat_collected(value:int)

func _ready():
	GameManager.player = self
	update_health_progress_bar()
	
func _process(delta):
	GameManager.player_position = position
	read_input()
	
	#bloco de controle de attack
	update_attack_cooldown(delta)
	#input de attack
	if Input.is_action_pressed("basic_attack"):
		basic_attack()
		
	#bloco controle de animação
	play_run_idle_animation()
	rotate_sprite()
	
	update_hitbox_detection(delta)
	update_ritual(delta)


func _physics_process(delta):
	var target_velocity = input_vector * speed * 100.0
	velocity = lerp(velocity, target_velocity, 0.05)
	
	move_and_slide()

#função que atualiza o CD do attack
func update_attack_cooldown(delta: float):
	if is_attacking:
		attack_cooldown -= delta
		
		#gambiarra dokrl para acertar o tempo da animação
		if attack_cooldown <= 0.3 and attack_cooldown >= 0.29:
			deal_damage_to_enemies() #aplicando dano
				
		if attack_cooldown <= 0.0:
			is_attacking = false
			is_running = false
			animated_sprite_2d.play("idle")

#função de atualização do ritual
func update_ritual(delta: float):
	#print("ATIVO: ", is_ritual_active, "/ TEMPO: ", ritual_cooldown)
	if !is_ritual_active:
		ritual_cooldown -= delta
		
		if ritual_cooldown <= 0:
			#crio o ritual
			var ritual = ritual_scene.instantiate()
			add_child(ritual)
			ritual.damage = ritual_damage
			is_ritual_active = true #o ritual esta ativo
			ritual_cooldown = ritual_interval #setei o temporizador

#função que faz a leitura do input de movimento
func read_input():
	input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	#atualizar o is_runnin
	#saber se estou correndo
	was_running = is_running
	is_running = !input_vector.is_zero_approx()

#função que faz a animação de atack e inicia o cooldown
func basic_attack():
	if is_attacking:
		return
	#rodar animação
	animated_sprite_2d.play("attack_side_1")
	#marcar q esta atacando
	is_attacking = true
	#iniciando o CD
	attack_cooldown = 0.6
	
#função que da dano nos inimigos
func deal_damage_to_enemies():
	#pegando todos os corpos dentro da area
	var bodies = sword_area.get_overlapping_bodies()
	#fazendo validação de cada corpo da area
	for body in bodies:
		#checar se o corpo esta no grupo de inimigos
		if body.is_in_group("enemies"):
			var enemy : Enemy = body
			
			#cria uma linha da direção do player para o inimigo
			var direction_to_enemy = (enemy.position - position).normalized()
			#operador ternario
			var attack_direction: Vector2 =  Vector2.LEFT if animated_sprite_2d.flip_h else Vector2.RIGHT
			#checando o dot product com o inimigo dentro da area
			var dot_product = direction_to_enemy.dot(attack_direction)
			#se o dot for maior, ele recebe dano
			if dot_product >= 0.3:
				#aplicando o dano
				enemy.damage(sword_damage)

#função para checar se algum corpo esta na hitbox do player
func update_hitbox_detection(delta):
	#reduzir tempo do CD
	hitbox_cooldown -= delta
	if hitbox_cooldown > 0: return #encerro a função se o valor for maior q zero
	#meio sec, para q possa receber 2 dano por sec
	hitbox_cooldown = 0.5
	#aplicar dano com base no damage do inimigo / verificando hitbox
	var bodies = hitbox_area.get_overlapping_bodies()
	#validação de cada inimigo
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			
			damage(enemy.en_damage_amount)

#função para tomar dano
func damage(amount: float):
	health -= amount
	update_health_progress_bar()
	
	#piscar o node
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(self, "modulate", Color.WHITE, 0.5)
	
	if health <= 0:
		die()

#funcao de cura do player
func heal(amount: float):
	health += amount
	
	if health > max_health:
		health = max_health
		
	#atualizando a vida
	update_health_progress_bar()
	return health
	
#função de morte, criando a animação da morte	
func die():
	if dead_prefab:
		#instanciar morte
		var dead_scene = dead_prefab.instantiate()
		dead_scene.position = position
		get_parent().add_child(dead_scene)
		
	GameManager.is_player_dead = true
	#destruir o jogador
	queue_free()
	
#função para rotacionar a sprite
func rotate_sprite():	
	#espelhar a sprite com a direção
	if !is_attacking:
		if input_vector.x < 0:
			animated_sprite_2d.flip_h = true
		elif input_vector.x > 0:
			animated_sprite_2d.flip_h = false

#função para rodar as animações RUN/IDLE
func play_run_idle_animation():
	#trocar animação
	if !is_attacking:
		if was_running != is_running:
			if is_running:
				animated_sprite_2d.play("walk")
			else :
				animated_sprite_2d.play("idle")
				
func update_health_progress_bar():
	health_progress_bar.max_value = max_health
	health_progress_bar.value = health
