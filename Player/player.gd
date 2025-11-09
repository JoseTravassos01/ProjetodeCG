extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D

const GRAVITY = 1000
@export var speed : int = 300
@export var jump : int = -300
@export var jump_horizontal : int = 100


enum State { Idle, Run, Jump }

var current_state : State

var character_sprite : Sprite2D

func _ready():
	current_state = State.Idle


func _physics_process(delta : float):
	player_falling(delta)
	player_idle(delta)
	player_run(delta)
	player_jump(delta)
	move_and_slide()
	player_animation()

	
func player_falling(delta : float):
	if !is_on_floor():
		velocity.y += GRAVITY * delta

func player_idle(delta):
	if is_on_floor():
		current_state = State.Idle

func player_run(delta : float):
	if !is_on_floor():
		return

	var direction = Input.get_axis("move_left", "move_right")
	
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, 300)
	if direction != 0:
		current_state = State.Run
		animated_sprite_2d.flip_h = false  if  direction > 0 else true 

func player_jump(delta : float):
	if Input.is_action_just_pressed("move_jump"):
		velocity.y = jump
		current_state = State.Jump

	if !is_on_floor() and current_state == State.Jump:
		var direction = Input.get_axis("move_left", "move_right")
		velocity.x += direction * jump_horizontal * delta

func player_animation():
	if current_state == State.Idle:
		animated_sprite_2d.play("idle")
	elif current_state == State.Run:
		animated_sprite_2d.play("run")
	elif current_state == State.Jump:
		animated_sprite_2d.play("jump")

func input_movement():
	var direction : float = Input.get_axis("move_left", "move_right")
