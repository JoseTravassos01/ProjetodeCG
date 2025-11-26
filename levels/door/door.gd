extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $DoorBody/CollisionShape2D


@export var next_scene: String
@export var key_id: String   # não estamos usando ainda, mas pode ficar aqui

const REQUIRED_KEYS := 7

var door_open: bool = false

func _ready() -> void:
	# Porta começa FECHADA e colidindo
	door_open = false
	animated_sprite_2d.play("close")
	collision_shape_2d.disabled = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return

	# Bloqueia completamente se estiver fechada
	if not door_open:
		# empurra o player para longe da porta (anti bug)
		body.velocity.x = 0
		body.global_position.x -= 4
		print("Porta fechada → passagem bloqueada")
		return

	# Se chegou até aqui, pode trocar de fase
	if next_scene != "":
		SceneManager.transition_to_scene(next_scene)

func _on_ativate_door_area_2d_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return

	# conta quantas chaves o player tem
	var total_keys := InvetoryManager.get_key_count()
	if total_keys < REQUIRED_KEYS:
		print("Você só tem ", total_keys, " chaves. Precisa de ", REQUIRED_KEYS, " para abrir a porta.")
		return

	if door_open:
		return  # já está aberta

	door_open = true
	print("ABRINDO PORTA com ", total_keys, " chaves.")
	animated_sprite_2d.play("open")
	# desativa a colisão da porta principal pra poder alcançar a área de saída
	collision_shape_2d.set_deferred("disabled", true)

	

func _on_ativate_door_area_2d_body_exited(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return

	# se quiser que a porta feche ao sair, descomenta o bloco abaixo:
	# if not door_open:
	#     return
	# door_open = false
	# animated_sprite_2d.play("close")
	# collision_shape_2d.set_deferred("disabled", false)
	pass
