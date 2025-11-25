extends Node

# Lista de itens gerais que você quiser guardar
var inventory : Dictionary = {}

# Quantidade de chaves
var key_count: int = 0

signal keys_changed(new_value: int)

func add_key(type: String, value: String) -> void:
	inventory[type] = value

	# Se for chave, soma no contador
	if type == "Key":
		key_count += 1
		emit_signal("keys_changed", key_count)

func get_key_count() -> int:
	return key_count
	
func reset_keys() -> void:
	key_count = 0
	emit_signal("keys_changed", key_count)
