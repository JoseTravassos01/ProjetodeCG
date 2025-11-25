extends CanvasLayer

@onready var collectible_label = $MarginContainer/VBoxContainer/HBoxContainer/CollectibleLabel

func _ready():
	# mostra o valor atual das moedas ao carregar a HUD
	collectible_label.text = str(CollectibleManager.total_award_amount)

	# conecta o sinal para atualizar quando pegar mais moedas
	CollectibleManager.on_collectible_award_received.connect(on_collectible_award_received)
	

func on_collectible_award_received(total_award : int):
	collectible_label.text = str(total_award)


func _on_pause_texture_button_pressed() -> void:
	GameManager.pause_game()
