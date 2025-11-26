extends Node2D

func _ready() -> void:
	# toca o som de morte
	$DeathSound.play()

	# toca a animação se existir
	if $AnimatedSprite2D.sprite_frames.has_animation("default"):
		$AnimatedSprite2D.play("default")
	else:
		$AnimatedSprite2D.play()

	# inicia o Timer para remover o efeito depois
	$Timer.start()

func _on_Timer_timeout() -> void:
	queue_free()
