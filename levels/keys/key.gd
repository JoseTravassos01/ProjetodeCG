extends Node2D

@export var key_id: String   # ex: "Key1", "Key2", ..., "Key7"

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		InvetoryManager.add_key("Key", key_id)
		queue_free()
