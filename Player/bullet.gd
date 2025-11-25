extends AnimatedSprite2D

var bullet_impact_effect = preload("res://Player/bullet_impact_effect.tscn")

var speed : int = 600
var direction : int 
var damage_amount : int = 1



func _physics_process(delta):
	move_local_x(direction * speed * delta)


func _on_timer_timeout():
	queue_free()


func _on_hitbox_area_entered(area):
	print("Bullet area entered: ", area.name)

	# se a área (por ex: hurtbox) for do inimigo
	if area.is_in_group("Enemy"):
		var enemy: Node = area.get_parent()
		if enemy and enemy.has_method("take_damage"):
			enemy.take_damage(damage_amount)

	bullet_impact()
	
func get_damage_amount() -> int:
	return damage_amount


func _on_hitbox_body_entered(body):
	print("Bullet body entered: ", body.name)

	# se bater diretamente no corpo do inimigo
	if body.is_in_group("Enemy") and body.has_method("take_damage"):
		body.take_damage(damage_amount)

	bullet_impact()

func bullet_impact():
	var impact := bullet_impact_effect.instantiate() as Node2D

	# 1) adiciona no mesmo parent da bala (level / cena atual)
	get_parent().add_child(impact)

	# 2) agora sim, usa a POSIÇÃO GLOBAL da bala
	impact.global_position = global_position

	# 3) apaga a bala
	queue_free()
