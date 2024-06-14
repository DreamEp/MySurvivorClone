extends Node2D

@export var spawns : Array[Spawn_info] = []
@onready var player = get_tree().get_first_node_in_group("player") #On récuppère le player
@onready var labelTimer = player.labelTimer
var time = 0
@export var pass_time = 0

func _physics_process(delta):
	pass_time += delta
	change_time()
	
#Connection au timer via un signal timeout ici ça marche toutes les secondes
func _on_timer_timeout():
	time += 1 #1 seconde
	var enemy_spawns = spawns
	for i in enemy_spawns:
		if time >= i.time_start and time <= i.time_end: #Le temps doit être compris entre le timer de départ et de fin de l'ennemi
			if i.spawn_delay_counter <= i.enemy_spawn_delay: #Si le délai de spawn est inférieur au délai de spawn de l'ennemi on ajoute 1 au délai de spawn
				i.spawn_delay_counter += 1
			else:
				i.spawn_delay_counter = 0 #Sinon on reset le délai de spawn
				var new_enemy = i.enemy #On récupère le nouvel ennemi en récupérant le path de la variable ennemi dans les spawn_info de celui-ci
				var counter = 0
				while counter < i.enemy_num: #Tant qu'on a pas le nombre d'ennemi qu'on veut
					var enemy_spawn = new_enemy.instantiate() #On fait instancie des spawns d'ennemis jusqu'a avoir le nombre voulu
					enemy_spawn.global_position = get_random_position() #On set la position du spawner de manière random
					add_child(enemy_spawn) #On ajoute l'ennemi a notre world
					counter += 1 

#Création d'une fonction custom pour set une random position pour nos ennemies
func get_random_position():
	var vpr = get_viewport_rect().size * randf_range(1.1, 1.4) #vpr = ViewPort Rect, on ne veut pas récupérer les côté du screen (pov) mais un peu de marge
	var top_left = Vector2(player.global_position.x - vpr.x/2, player.global_position.y - vpr.y/2)
	var top_right = Vector2(player.global_position.x + vpr.x/2, player.global_position.y - vpr.y/2)
	var bottom_left = Vector2(player.global_position.x - vpr.x/2, player.global_position.y + vpr.y/2)
	var bottom_right = Vector2(player.global_position.x + vpr.x/2, player.global_position.y + vpr.y/2)
	
	var pos_side = ["up", "down", "right", "left"].pick_random() #Prend une valeur random dans cet array
	var spawn_pos1 = Vector2.ZERO
	var spawn_pos2 = Vector2.ZERO
	
	match pos_side:
		"up":
			spawn_pos1 = top_left
			spawn_pos2 = top_right
		"down":
			spawn_pos1 = bottom_left
			spawn_pos2 = bottom_right
		"right":
			spawn_pos1 = top_right
			spawn_pos2 = bottom_right
		"left":
			spawn_pos1 = top_left
			spawn_pos2 = bottom_left
	
	#On prend une valeur random pour x et y entre les deux extremes
	var x_spawn = randf_range(spawn_pos1.x, spawn_pos2.x)
	var y_spawn = randf_range(spawn_pos1.y, spawn_pos2.y)
	
	#On retourne le vector ou on souhaite faire spawn l'ennemi de manière random
	return Vector2(x_spawn, y_spawn)

#On calcule ici le temps pour l'afficher dans notre jeux	
func change_time():
	time = int(pass_time)
	var m = int(time / 60.0)
	var s = time % 60
	if m < 10:
		m = str(0, m)
	if s < 10:
		s = str(0, s)
	labelTimer.text = str(m, ":", s)
