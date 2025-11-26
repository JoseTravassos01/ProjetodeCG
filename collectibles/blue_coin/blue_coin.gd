extends Node2D

@export var award_amount : int = 1

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var label: Label = $Label
@onready var pickup_sound: AudioStreamPlayer2D = $PickupSound   # 🔊 SOM DA MOEDA

func _ready() -> void:
	label.hide()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):

		# 🔊 toca o som ao pegar a moeda
		pickup_sound.play()

		# esconde o sprite da moeda
		animated_sprite_2d.hide()

		# mostra o valor ganho
		label.text = "%s" % award_amount
		CollectibleManager.give_pickup_award(award_amount)
		label.show()

		# animação do texto subindo
		var tween = get_tree().create_tween()
		tween.tween_property(
			label, 
			"position", 
			Vector2(label.position.x, label.position.y - 10), 
			0.5
		).from_current()

		# remove a moeda depois da animação
		tween.tween_callback(queue_free)
