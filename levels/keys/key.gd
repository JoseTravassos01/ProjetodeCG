extends Node2D

@export var key_id: String   # ex: "Key1", "Key2", ..., "Key7"

@onready var pickup_sound: AudioStreamPlayer2D = $PickupSound   # 🔊 SOM DA CHAVE

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):

		# 🔊 toca som ao pegar a chave
		pickup_sound.play()

		# adiciona a chave ao inventário
		InvetoryManager.add_key("Key", key_id)

		# espera o som terminar antes de sumir
		await get_tree().create_timer(0.15).timeout

		queue_free()
