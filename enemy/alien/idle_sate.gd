extends NodeState

@onready var character_body_2d: CharacterBody2D = get_parent().get_parent()
@onready var animated_sprite_2d: AnimatedSprite2D = character_body_2d.get_node("AnimatedSprite2D")
@export var slow_down_speed: int = 50 

func _process(delta: float) -> void:
	pass

func on_physics_process(delta: float) -> void:
	# desacelera no eixo X
	character_body_2d.velocity.x = move_toward(
		character_body_2d.velocity.x,
		0.0,
		slow_down_speed * delta
	)

	# animação de idle
	animated_sprite_2d.play("idle")

	# aplica movimento
	character_body_2d.move_and_slide()

func enter() -> void:
	pass

func exit() -> void:
	pass
