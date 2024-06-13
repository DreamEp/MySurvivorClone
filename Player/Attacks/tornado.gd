extends Area2D

var level = 1
var pierce = 999 #Une valeur de pierce = 1, se comporte normalement
var cast_speed = 3
var base_bullet_speed = 20
var final_bullet_speed = 80
var damage = 2
var attack_area = 1.2

var tween_change_direction_time =  3
var tween_change_size_time = 3
var tween_change_bulletspeed_time = 7

var player_last_movement = Vector2.ZERO
var angle = Vector2.ZERO
var angle_less = Vector2.ZERO
var angle_more = Vector2.ZERO
var target = Vector2.ZERO

signal remove_from_array(object)

@onready var player = get_tree().get_first_node_in_group("player")

func _ready():
	match level:
		1:
			pierce = pierce
			cast_speed = cast_speed
			base_bullet_speed = base_bullet_speed
			final_bullet_speed *= 3
			damage = damage
			attack_area = attack_area
		2:
			pierce = pierce 
			cast_speed = cast_speed
			base_bullet_speed *= base_bullet_speed
			final_bullet_speed *= 4
			damage += damage
			attack_area += 0.2
	var move_to_less = Vector2.ZERO
	var move_to_more = Vector2.ZERO
	match player_last_movement: #Match ici le dernier mouvement de notre joueur
		Vector2.UP, Vector2.DOWN: #Si on se déplace vers la gauche ou la droite
			#Ici move to less sera l'objectif de la tornade qui se situe a 500 pixel sur l'axe y que notre personnage face sur la gauche avec un angle plus ou moins élevé
			#Ici move to more sera l'objectif de la tornade qui se situe a 500 pixel sur l'axe y que notre personnage face sur la droite avec un angle plus ou moins élevé
			move_to_less = global_position + Vector2(randf_range(-1, -0.25), player_last_movement.y) * 500 #On recupere la position ou la tornado spawn et on y ajoute 500 pixel dans la direction ou il va être envoyé ici a gauche
			move_to_more = global_position + Vector2(randf_range(0.25, 1), player_last_movement.y) * 500 #On recupere la position ou la tornado spawn et on y ajoute 500 pixel dans la direction ou il va être envoyé ici a droite
		Vector2.RIGHT, Vector2.LEFT: #Si on se déplace vers le haut ou le bas on fait varier que l'axe des y
			move_to_less = global_position + Vector2(player_last_movement.x, randf_range(-1, -0.25)) * 500 #On recupere la position ou la tornado spawn et on y ajoute 500 pixel dans la direction ou il va être envoyé ici a gauche
			move_to_more = global_position + Vector2(player_last_movement.x, randf_range(0.25, 1)) * 500 #On recupere la position ou la tornado spawn et on y ajoute 500 pixel dans la direction ou il va être envoyé ici a droite
		Vector2(1,-1), Vector2(1,1), Vector2(-1,1), Vector2(-1,-1): #Si on se déplace en haut a droite, bas a droite, bas a gauche, haut a gauche
			move_to_less = global_position + Vector2(player_last_movement.x, player_last_movement.y * randf_range(0,0.75)) * 500
			move_to_more = global_position + Vector2(player_last_movement.x * randf_range(0,0.75), player_last_movement.y) * 500
	#On recupere finalement ses valeurs ce qui va nous donner la direction vers laquelle doit aller notre tornade
	angle_less = global_position.direction_to(move_to_less)
	angle_more = global_position.direction_to(move_to_more) 
	
	var initial_tween = create_tween().set_parallel(true)
	initial_tween.tween_property(self, "scale", Vector2(1,1) * attack_area, tween_change_size_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT) #Augmente la taille de la tornade
	initial_tween.tween_property(self, "base_bullet_speed", final_bullet_speed, tween_change_bulletspeed_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT) #On fait la variation ici, elle atteint donc la max speed en 10 sec
	initial_tween.play()
	
	var tween = create_tween() #Permet de créer un effet sur le projectile ici	
	var set_angle = randi_range(0, 1) #On flip aléatoirement de quel côté la tornade commence a aller
	if set_angle == 1:
		angle = angle_less
		tween.tween_property(self, "angle", angle_more, tween_change_direction_time)
		tween.tween_property(self, "angle", angle_less, tween_change_direction_time)
	else :
		angle = angle_more
		tween.tween_property(self, "angle", angle_less, tween_change_direction_time)
		tween.tween_property(self, "angle", angle_more, tween_change_direction_time)
	tween.set_loops()
	tween.play()

#Définit le comportement de la tornade ( on va faire varier l'angle ppar exemple)
func _physics_process(delta):
	position += angle * base_bullet_speed * delta

func _on_timer_timeout():
	emit_signal("remove_from_array", self)
	queue_free()
	
