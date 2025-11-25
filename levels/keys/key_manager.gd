extends Node

var keys: int = 0

signal keys_changed(new_value)

func add_key():
	keys += 1
	emit_signal("keys_changed", keys)

func get_keys() -> int:
	return keys
