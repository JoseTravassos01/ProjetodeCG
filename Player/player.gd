extends CharacterBody2D

var bullet  = preload("res://Player/bullet.tscn")
var player_death_effect = preload("res://Player/player_death_effect/player_death_effect.tscn")

var facing_direction: int = 1   # 1 = direita, -1 = esquerda
var original_sprite_scale: Vector2

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var muzzle: Marker2D = $Muzzle
@onready var hit_animation_player: AnimationPlayer = $HitAnimationPlayer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D  # AJUSTE SE O CAMINHO FOR OUTRO
@onready var shoot_sound: AudioStreamPlayer2D = $ShootSound   # 🔊 SOM DO TIRO
@onready var damage_sound: AudioStreamPlayer2D = $DamageSound

# --- CONFIG SLIDE ---
const SLIDE_DURATION := 0.5        # tempo do slide em segundos
const SLIDE_SPEED := 400.0         # impulso horizontal
const SLIDE_HEIGHT_FACTOR := 0.2   # altura do collider no slide (50%)

var slide_timer: float = 0.0
var original_shape_size_y: float = 0.0
var original_shape_position: Vector2

# --- FÍSICA / MOVIMENTO ---
const GRAVITY = 1000
@export var speed: int = 1000
@export var max_horizontal_speed: int = 300
@export var slow_down_speed: int = 1700

@export var jump: int = -300
@export var jump_horizontal_speed: int = 1000
@export var max_jump_horizontal_speed: int = 300
@export var wall_slide_speed: float = 10.0
# --- KNOCKBACK (pulo pra trás quando leva dano) ---
@export var knockback_horizontal: float = 600.0
@export var knockback_vertical: float = -350.0

# --------- CONTROLE DE PULO ----------
const MAX_JUMPS := 3         # máximo de pulos
var jumps_left := MAX_JUMPS  # quantos pulos ainda pode dar
# ------------------------------------

enum State { Idle, Run, Jump, Shoot, Wall, Slide }

var current_state: State
var muzzle_position: Vector2

func _ready() -> void:
	current_state = State.Idle
	muzzle_position = muzzle.position

	# guarda escala original do sprite
	original_sprite_scale = animated_sprite_2d.scale

	# guarda tamanho e posição original do collider
	var rect_shape := collision_shape_2d.shape as RectangleShape2D
	if rect_shape:
		original_shape_size_y = rect_shape.size.y
		original_shape_position = collision_shape_2d.position


func _physics_process(delta: float) -> void:
	player_falling(delta)
	player_idle(delta)
	player_run(delta)
	player_jump(delta)
	player_wall_slide(delta)
	player_slide(delta)
	player_shooting(delta)
	player_muzzle_position()
	move_and_slide()
	player_animation()

	# sprite sempre segue a direção que está olhando
	animated_sprite_2d.flip_h = facing_direction < 0

	# reseta pulos quando encosta no chão
	if is_on_floor():
		jumps_left = MAX_JUMPS


# -------------------- MOVIMENTO BÁSICO --------------------

func player_falling(delta: float) -> void:
	if !is_on_floor():
		velocity.y += GRAVITY * delta


func player_idle(delta: float) -> void:
	if is_on_floor() and abs(velocity.x) < 5.0 and current_state not in [State.Shoot, State.Slide]:
		current_state = State.Idle


func player_run(delta: float) -> void:
	if !is_on_floor():
		return
	if current_state == State.Slide:
		return

	var direction := Input.get_axis("move_left", "move_right")

	if direction != 0:
		velocity.x += direction * speed * delta
		velocity.x = clamp(velocity.x, -max_horizontal_speed, max_horizontal_speed)

		facing_direction = 1 if direction > 0 else -1
	else:
		velocity.x = move_toward(velocity.x, 0, slow_down_speed * delta)

	if direction != 0 and current_state != State.Shoot and current_state != State.Slide:
		current_state = State.Run


# -------------------- PULO / WALL JUMP --------------------

func player_jump(delta: float) -> void:
	# não pula durante o slide (se quiser cancelar slide com pulo, dá pra mudar isso depois)
	if current_state == State.Slide:
		return

	# 1) PULO NA PAREDE
	if Input.is_action_just_pressed("move_jump") and current_state == State.Wall and !is_on_floor():
		var normal := get_wall_normal()
		var jump_dir := normal.x

		if jump_dir == 0:
			jump_dir = facing_direction

		velocity.y = jump
		velocity.x = jump_horizontal_speed * jump_dir

		jumps_left = MAX_JUMPS - 1
		current_state = State.Jump
		return

	# 2) PULO NORMAL (chão / ar com múltiplos pulos)
	if Input.is_action_just_pressed("move_jump") and jumps_left > 0:
		velocity.y = jump
		current_state = State.Jump
		jumps_left -= 1

	# NO AR: pode mover e virar pros dois lados
	if !is_on_floor() and current_state == State.Jump:
		var direction := Input.get_axis("move_left", "move_right")
		velocity.x += direction * jump_horizontal_speed * delta
		velocity.x = clamp(velocity.x, -max_jump_horizontal_speed, max_jump_horizontal_speed)

		if direction != 0:
			facing_direction = 1 if direction > 0 else -1


# -------------------- SLIDE --------------------

func start_slide() -> void:
	if current_state == State.Slide:
		return
	if !is_on_floor():
		return

	current_state = State.Slide
	slide_timer = SLIDE_DURATION

	# aumenta o tamanho visual do sprite no slide
	animated_sprite_2d.scale = original_sprite_scale * 1.5

	velocity.y = 0.0
	velocity.x = facing_direction * SLIDE_SPEED

	var rect_shape := collision_shape_2d.shape as RectangleShape2D
	if rect_shape:
		var new_height := original_shape_size_y * 0.20
		var old_height := rect_shape.size.y

		rect_shape.size.y = new_height
		var diff := (old_height - new_height) * 0.5
		collision_shape_2d.position = original_shape_position + Vector2(0, diff)


func end_slide() -> void:
	if current_state != State.Slide:
		return

	current_state = State.Idle

	# volta a escala original do sprite
	animated_sprite_2d.scale = original_sprite_scale

	var rect_shape := collision_shape_2d.shape as RectangleShape2D
	if rect_shape:
		rect_shape.size.y = original_shape_size_y
		collision_shape_2d.position = original_shape_position


func player_slide(delta: float) -> void:
	# se está em slide, conta o tempo
	if current_state == State.Slide:
		slide_timer -= delta
		if slide_timer <= 0.0:
			end_slide()
		return

	# se NÃO está em slide: verifica input para começar
	if is_on_floor() and Input.is_action_just_pressed("slide"):
		if abs(velocity.x) > 10.0:
			start_slide()


# -------------------- WALL SLIDE --------------------

func player_wall_slide(delta: float) -> void:
	if is_on_floor():
		return
	if current_state == State.Slide:
		return

	# Se está encostado na parede e caindo, começa a "derrapar"
	if is_on_wall() and velocity.y > 0.0:
		# limita a velocidade pra descer devagar
		if velocity.y > wall_slide_speed:
			velocity.y = wall_slide_speed

		current_state = State.Wall
		jumps_left = MAX_JUMPS
	else:
		# saiu da parede, volta pro estado de pulo se ainda no ar
		if current_state == State.Wall and !is_on_floor():
			current_state = State.Jump


# -------------------- TIRO --------------------

func player_shooting(delta: float) -> void:
	var direction := input_movement()

	if direction > 0:
		facing_direction = 1
	elif direction < 0:
		facing_direction = -1

	if Input.is_action_just_pressed("shoot"):
		var bullet_instance := bullet.instantiate() as Node2D
		bullet_instance.direction = facing_direction

		get_parent().add_child(bullet_instance)
		bullet_instance.global_position = muzzle.global_position

		shoot_sound.play()  # 🔊 TOCA O SOM DO TIRO

		current_state = State.Shoot


# -------------------- MUZZLE / ANIMAÇÃO --------------------

func player_muzzle_position() -> void:
	var direction := input_movement()

	if direction > 0:
		facing_direction = 1
	elif direction < 0:
		facing_direction = -1

	if facing_direction == 1:
		muzzle.position.x = muzzle_position.x
	else:
		muzzle.position.x = -muzzle_position.x


func player_animation() -> void:
	if current_state == State.Idle:
		animated_sprite_2d.play("idle")
	elif current_state == State.Run and animated_sprite_2d.animation != "run_shoot":
		animated_sprite_2d.play("run")
	elif current_state == State.Jump:
		animated_sprite_2d.play("jump")
	elif current_state == State.Wall:
		if animated_sprite_2d.sprite_frames.has_animation("wall"):
			animated_sprite_2d.play("wall")
		else:
			animated_sprite_2d.play("jump")
	elif current_state == State.Slide:
		if animated_sprite_2d.sprite_frames.has_animation("slide"):
			animated_sprite_2d.play("slide")
		else:
			animated_sprite_2d.play("run")
	elif current_state == State.Shoot:
		# se estiver parado no chão, atira mas animação idle
		if is_on_floor() and abs(velocity.x) < 5.0:
			animated_sprite_2d.play("idle")
		else:
			animated_sprite_2d.play("run_shoot")


func input_movement() -> float:
	return Input.get_axis("move_left", "move_right")


# -------------------- KNOCKBACK / DANO --------------------

func apply_knockback() -> void:
	# joga sempre pra TRÁS (oposto de onde está olhando)
	var dir := -facing_direction
	velocity.x = dir * knockback_horizontal
	velocity.y = knockback_vertical

	current_state = State.Jump


# -------------------- MORTE --------------------

func player_death() -> void:
	var death_pos_global: Vector2 = global_position
	var parent := get_parent()

	var cam := get_node_or_null("PlayerCamera2D")
	if cam:
		if cam.get_parent() != parent:
			cam.reparent(parent)
		cam.global_position = death_pos_global

	var death_effect = player_death_effect.instantiate()
	death_effect.position = parent.to_local(death_pos_global)
	parent.add_child(death_effect)

	queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		print("enemy entered ", body.damage_amount)
		hit_animation_player.play("hit")

		# 🔊 toca som de dano
		damage_sound.play()

		HealthManagert.decrease_health(body.damage_amount)

		if HealthManagert.current_health > 0:
			apply_knockback()
		else:
			player_death()
