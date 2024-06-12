extends Area2D

var level = 1
var pierce = 9999
var bullet_speed = 200.0
var base_return_speed = 20
var long_return_speed = 200
var max_distance_from_player = 100
var damage = 5
var knockback_amount = 100
var max_ennemy_numbers_paths = 3 #Nombre d'ennemies sur lesquels enchainés / ou bounce
var attack_area = 1.0
var salve_attack_delay = 7.0
var next_attack_delay = 3.0
var spawn_delay = 30


var target = Vector2.ZERO
var target_array = []

var angle = Vector2.ZERO
var reset_pos = Vector2.ZERO

var spr_jav_reg = preload("res://Textures/Items/Weapons/javelin_3_new.png")
var spr_jav_attacking = preload("res://Textures/Items/Weapons/javelin_3_new_attack.png")

@onready var player = get_tree().get_first_node_in_group("player")
@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var attackTimer = get_node("%AttackTimer")
@onready var changeDirectionTimer = get_node("%ChangeDirection")
@onready var resetPosTimer = get_node ("%ResetPosTimer")
@onready var snd_attack = $snd_javelin_attack

signal remove_from_array(object)

#Ici on instancie le javelot
func _ready():
	update_javelin()
	_on_reset_pos_timer_timeout()

func update_javelin():
	level = player.javelin_level
	match level:
		1:
			pierce = pierce
			bullet_speed = bullet_speed
			damage = damage
			knockback_amount = knockback_amount
			max_ennemy_numbers_paths = max_ennemy_numbers_paths
			attack_area = attack_area
			salve_attack_delay = salve_attack_delay
			next_attack_delay = next_attack_delay
			spawn_delay = spawn_delay
		2:
			pierce = pierce
			bullet_speed = bullet_speed
			damage = damage
			knockback_amount = knockback_amount
			max_ennemy_numbers_paths += 1
			attack_area = attack_area
			salve_attack_delay = salve_attack_delay	
			next_attack_delay = next_attack_delay	
			spawn_delay = spawn_delay
	
	var tween = create_tween()
	#On change la valeur scale du node parent en multipliant un vecteur 1, 1 par l'area du projectile est en disant que celui ci grossis en 3 sec,  avec un effet ease_out
	tween.tween_property(self, "scale", Vector2(1, 1) * attack_area, 3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.play()
	attackTimer.wait_time = salve_attack_delay #On set le delai entre les salves
	changeDirectionTimer.wait_time = next_attack_delay #On set le délai entre les attaques

#Cette fonction permet de déterminer le mouvement / comportement de notre javelot
func _physics_process(delta):
	if target_array.size() > 0: 	#Si le javelot a des target alors on le fait bouger vers celle-ci avec la vitesse bullet_speed
		position += angle * bullet_speed * delta
	else: #Sinon on le fait revenir doucement vers le joueur
		var player_angle = global_position.direction_to(reset_pos) #On calcule 
		var distance_dif = global_position - player.global_position #On calcule la différence de position entre le joueur et le javelot
		var return_speed = base_return_speed #On prend la valeur de speed de retour par défaut
		if abs(distance_dif.x) > max_distance_from_player or abs(distance_dif.y) > max_distance_from_player: #Si le javelot est a une distance trop élevé on change son speed de retour
			return_speed = long_return_speed #On prend alors la valeur de speed quand le javelot est loin
		position += player_angle * return_speed * delta #On fait bouger le javelot avec la vitesse de retour cette fois ci
		rotation = global_position.direction_to(player.global_position).angle() + deg_to_rad(135) #On rotate le javelot dans la bonne direction du joueur
		
#Cette fonction permet d'ajouter des ennemies a notre tableau d'ennemie afin d'atteindre le max d'ennemi 
func add_ennemy_numbers_paths():
	snd_attack.play()
	emit_signal("remove_from_array", self) #On supprime de l'array cet ennemi pour pouvoir le retoucher par la suite
	target_array.clear() #We clear the target array
	var counter = 0
	while counter < max_ennemy_numbers_paths: #Tant qu'on a pas atteint le nombre max d'ennemi a traverser
		var new_path = player.get_random_target() #On target un random ennemi en range
		target_array.append(new_path) #On ajoute cet ennemi a notre tableau
		counter += 1 #On incrémente le compteur
	enable_attack(true) #On appelle la function attaque avec true en argument pour passer en mode attaque, la collision et le sprite attaque sont activés
	target = target_array[0] #On set la target au premier ennemi du tableau
	process_path() #On appelle la fonction process path

#Cette fonction permet de process le path et de donner la direction et l'angle de l'ennemi après avoir récupérer tous les paths
func process_path():
	angle = global_position.direction_to(target) #On déplace le javelot vers la position du premier ennemi de la liste
	changeDirectionTimer.start() #On start alors notre timer avant de changement de direction
	var tween = create_tween()
	var new_rotation_degrees = angle.angle() + deg_to_rad(135) #On set la nouvelle rotation du javelot vers la target
	tween.tween_property(self, "rotation", new_rotation_degrees, 0.25).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT) #On fait le changement de position en 0.25s qui va vers la target
	tween.play()

#Cette fonction permet d'activer ou non le mode "attaque" notamment en activant la collision et le sprite attaque
func enable_attack(atk = true):
	if atk:
		collision.call_deferred("set", "disabled", false)
		sprite.texture = spr_jav_attacking
	else:
		collision.call_deferred("set", "disabled", true)
		sprite.texture = spr_jav_reg

#Quand la volée d'attaque est terminé on ajoute de nouveau des ennemis
func _on_attack_timer_timeout():
	add_ennemy_numbers_paths()

#Quand le timer du changement de direction est terminé
func _on_change_direction_timeout():
	if target_array.size() > 0: #Si il reste des target dans l'array
		target_array.remove_at(0) #On supprime le premier argument de la liste car on l'a déjà traité
		if target_array.size() > 0:  #Si la liste comporte toujours une target
			target = target_array[0] #On prend alors la première
			process_path() #On process son path, ce qui permet alors de mouvoir le javelot vers elle
			snd_attack.play() #On active le son 
			emit_signal("remove_from_array", self) #On supprime de l'array cet ennemi pour pouvoir le retoucher par la suite
		else:
			changeDirectionTimer.stop() #Si il n'y a plus d'ennemi on set le timer changement de direction en stop
			attackTimer.start() #On start le timer avant une nouvelle volée d'attaque
			enable_attack(false) #On set notre javelot en mode attaque a false
	else:
		changeDirectionTimer.stop() #Si il n'y a plus d'ennemi on set le timer changement de direction en stop
		attackTimer.start() #On start le timer avant une nouvelle volée d'attaque
		enable_attack(false) #On set notre javelot en mode attaque a false

#On fait spawn le javelot a une position random autour du héro dans les 4 directions
func _on_reset_pos_timer_timeout():
	var choose_direction = randi() % 4
	reset_pos = player.global_position
	match choose_direction:
		0:
			reset_pos.x += 50
		1:
			reset_pos.x -= 50
		2:
			reset_pos.y += 50
		3:
			reset_pos.y -= 50
