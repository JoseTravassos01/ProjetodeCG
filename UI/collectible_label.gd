extends Label

func _ready() -> void:
	text = str(InvetoryManager.get_key_count())
	InvetoryManager.keys_changed.connect(_on_keys_changed)

func _on_keys_changed(new_value: int) -> void:
	text = str(new_value)
