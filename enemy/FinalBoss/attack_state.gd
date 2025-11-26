extends NodeState

@export var speed : int = 200

# pega o corpo e o sprite a partir do dono (o inimigo)
@onready var character_body_2d: CharacterBody2D = owner as CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = character_body_2d.get_node("AnimatedSprite2D")

var player : CharacterBody2D
var max_speed : int


func on_process(delta : float) -> void:
	pass


func on_physics_process(delta : float) -> void:
	# 1) se o inimigo não estiver válido, sai
	if character_body_2d == null or !is_instance_valid(character_body_2d):
		return

	# 2) garante que o player existe
	if player == null or !is_instance_valid(player):
		var players = get_tree().get_nodes_in_group("Player")
		if players.size() == 0:
			# não achou ninguém no grupo Player, evita o erro
			return
		player = players[0] as CharacterBody2D

	var direction : int = 0

	# 3) agora sim pode comparar as posições
	if character_body_2d.global_position.x > player.global_position.x:
		animated_sprite_2d.flip_h = false
		direction = -1
	elif character_body_2d.global_position.x < player.global_position.x:
		animated_sprite_2d.flip_h = true
		direction = 1

	animated_sprite_2d.play("attack")

	# velocidade direta, sem acumular (não desliza)
	character_body_2d.velocity.x = direction * speed
	character_body_2d.move_and_slide()


func enter() -> void:
	# tenta achar o player aqui também (extra segurança)
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player = players[0] as CharacterBody2D

	max_speed = speed + 20


func exit() -> void:
	pass
