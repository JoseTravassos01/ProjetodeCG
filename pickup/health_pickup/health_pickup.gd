extends Node2D

@export var pickup_amount: int = 1

@onready var pickup_sound: AudioStreamPlayer2D = $PickupSound

func _on_health_pickup_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		# 🔊 som de pegar vida
		pickup_sound.play()

		# aumenta a vida do player
		HealthManagert.increase_health(pickup_amount)

		# espera um tiquinho pro som não cortar na hora
		await get_tree().create_timer(0.15).timeout

		queue_free()
