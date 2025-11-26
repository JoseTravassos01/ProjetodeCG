extends AnimatedSprite2D

func _ready() -> void:
	# 🔊 toca o som de morte
	$DeathSound.play()

	# ▶ toca a animação (pelo print o nome é "enemy_death")
	# se só tiver uma animação, pode usar só play()
	if sprite_frames.has_animation("enemy_death"):
		play("enemy_death")
	else:
		play()

	# ⏱ inicia o Timer pra apagar o efeito depois
	$Timer.start()


func _on_Timer_timeout() -> void:
	# quando o timer acabar, some com o efeito
	queue_free()
