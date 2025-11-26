extends CharacterBody2D

@export var max_health: int = 6     # 3 tiros pra morrer
@export var damage_amount: int = 1   # quanto de dano ele dá no player
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var enemy_death_effect = preload("res://enemy/anime_death_effect.tscn")
var current_health: int


func _ready() -> void:
	current_health = max_health
	# garante que está no grupo Enemy
	if not is_in_group("Enemy"):
		add_to_group("Enemy")


# usado pelo player pra saber quanto de dano leva ao encostar
func get_damage_amount() -> int:
	return damage_amount


# chamado pela bullet quando acerta o inimigo
func take_damage(amount: int) -> void:
	current_health -= amount
	print("Alien levou ", amount, " de dano. Vida atual: ", current_health)

	if current_health <= 0:
		print("Alien morreu")

		var effect := enemy_death_effect.instantiate()
		get_parent().add_child(effect)

	# alinha a explosão com o sprite do alien, não com a origem do corpo
		effect.global_position = animated_sprite_2d.global_position

		queue_free()


func _on_animated_sprite_2d_animation_finished() -> void:
	pass # Replace with function body.
