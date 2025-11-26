extends CharacterBody2D

# ---------- CONFIG VIDA / DANO ----------
@export var max_health: int = 10      # tiros pra morrer
@export var damage_amount: int = 1   # quanto de dano ele dá no player

# ---------- CONFIG MOVIMENTO ----------
@export var move_speed: float = 30.0        # velocidade de perseguição
@export var chase_distance: float = 400.0   # distância pra começar a perseguir (ajusta no Inspector)

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var enemy_death_effect = preload("res://enemy/anime_death_effect.tscn")

var current_health: int
var player: Node2D

enum State { Idle, Chase, Dead }
var state: State = State.Idle


func _ready() -> void:
	current_health = max_health

	# garante grupo Enemy
	if not is_in_group("Enemy"):
		add_to_group("Enemy")

	# procura o player pelo grupo "Player"
	var players := get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player = players[0] as Node2D
	else:
		push_warning("Alien: nenhum node no grupo 'Player' foi encontrado.")


func _physics_process(delta: float) -> void:
	if state == State.Dead:
		return

	if player == null:
		velocity = Vector2.ZERO
		update_animation()
		return

	# vetor até o player
	var to_player: Vector2 = player.global_position - global_position
	var distance: float = to_player.length()

	# decide se fica parado ou persegue
	if distance <= chase_distance:
		state = State.Chase
	else:
		state = State.Idle

	# movimentação
	match state:
		State.Idle:
			velocity = Vector2.ZERO
		State.Chase:
			velocity = to_player.normalized() * move_speed

	# virar pro lado do player
	if to_player.x != 0.0:
		animated_sprite_2d.flip_h = to_player.x > 0.0

	# movimento simples em qualquer direção
	global_position += velocity * delta

	update_animation()


# ---------- DANO / MORTE ----------

# usado pelo player pra saber quanto de dano leva ao encostar
func get_damage_amount() -> int:
	return damage_amount


# chamado pela bullet quando acerta o inimigo
func take_damage(amount: int) -> void:
	if state == State.Dead:
		return

	current_health -= amount
	print("Alien levou ", amount, " de dano. Vida atual: ", current_health)

	if current_health <= 0:
		die()


func die() -> void:
	if state == State.Dead:
		return

	state = State.Dead
	print("Alien morreu")

	# spawna efeito de morte
	var effect := enemy_death_effect.instantiate()
	get_parent().add_child(effect)

	# alinha a explosão com o sprite do alien
	effect.global_position = animated_sprite_2d.global_position

	# (opcional) esconde o sprite antes de sumir
	animated_sprite_2d.visible = false

	# remove o inimigo
	queue_free()


# ---------- ANIMAÇÃO BEM SIMPLES ----------

func update_animation() -> void:
	if state == State.Dead:
		return

	match state:
		State.Idle:
			if animated_sprite_2d.sprite_frames.has_animation("idle"):
				if animated_sprite_2d.animation != "idle":
					animated_sprite_2d.play("idle")
		State.Chase:
			if animated_sprite_2d.sprite_frames.has_animation("andar"):
				if animated_sprite_2d.animation != "andar":
					animated_sprite_2d.play("andar")
