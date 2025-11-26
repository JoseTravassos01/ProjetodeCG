extends Node

var max_health : int = 3
var current_health : int

signal on_health_changed(current_health : int)


func _ready() -> void:
	current_health = max_health
	# atualiza a barra na hora que o jogo começa (opcional)
	on_health_changed.emit(current_health)


func decrease_health(health_amount : int) -> void:
	current_health -= health_amount
	
	if current_health < 0:
		current_health = 0
	
	print("decrease_health called, vida:", current_health)
	on_health_changed.emit(current_health)

	if current_health == 0:
		_player_died()


func increase_health(health_amount : int) -> void:
	current_health += health_amount
	
	if current_health > max_health:
		current_health = max_health
	
	print("increase_health called, vida:", current_health)
	on_health_changed.emit(current_health)


func _player_died() -> void:
	print("Player morreu, voltando pro Level1")
	SceneManager.transition_to_scene("Level1")
