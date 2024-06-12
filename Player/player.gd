extends CharacterBody2D

var movement_speed: float = 60.0
var health = 80
var attack_speed = 0.1
var cast_speed = 0.3

var last_movement = Vector2.UP #Recupère notre précédent mouvement

#Attacks
var iceSpear = preload("res://Player/Attacks/ice_spear_area_2d.tscn")
var tornado = preload("res://Player/Attacks/tornado.tscn")

#AttacksNodes
@onready var iceSpearTimer = get_node("%IceSpearReloadTimer") #reload
@onready var iceSpearAttackTimer = get_node("%IceSpearAttackTimer") #attack speed
#@onready var tornadoTimer = get_node("%TornadoTimer") 
@onready var tornadoAttackTimer = get_node("%TornadoAttackTimer")

#IceSpear
var icespear_ammo = 0
var icespear_baseammo = 2
var icespear_reloadspeed = 3
var icespear_level = 1

#Tornado
var tornado_level = 1

#Ennemy related
var enemy_close = []

func _ready():
	attack()

@onready var sprite2Dplayer = $PlayerSprite2D #Ici on peut faire référence a notre sprite2D du personnage pour faire l'annimation
@onready var walkTimer = get_node("%walkTimer") #Ici on fait référence a notre walkTimer d'une manière différente, permet notamment d'être path sensitive

#Fonction custom pour créer notre mouvement
func movement():
	var x_move = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_move = Input.get_action_strength("down") - Input.get_action_strength("up") #Attention le mouvement sur l'axe y est inversé sur Godot donc bien faire down - up !
	var move = Vector2(x_move, y_move) #Définit le vector du mouvement en interpretant x, et y (direction) 
	
	#Ici on comare la position X du vector, si elle est positif on va a droite, et on flip alors notre personnage vers la bonne direction
	if move.x > 0:
		sprite2Dplayer.flip_h = true
	#Sinon on ne le flip pas si on va a gauche
	elif move.x < 0:
		sprite2Dplayer.flip_h = false
	
	#Ici on fait l'annimation de la marche en jouant sur les frames (2)	
	if move != Vector2.ZERO: #On verifie si on bouge ou non
		last_movement = move #On met à jour le dernier mouvement avec le nouveau
		if walkTimer.is_stopped(): #Si le walkTimer est arreté
			if sprite2Dplayer.frame >= sprite2Dplayer.hframes - 1: #Frame start to 0 and hframe at 2 that's why we set -1
				sprite2Dplayer.frame = 0 #It reset it to 0
			else: 
				sprite2Dplayer.frame += 1 #It increase the frame by 1
			walkTimer.start()

	velocity = move.normalized()*movement_speed #Définit la physique du mouvement, la vitesse etc | Normalized permet de se déplacer de la meme vitesse en diagonale sinon on serait plus rapide
	move_and_slide() #Interprete le tout pour bouger | utilise delta par défaut
	
func attack():
	if icespear_level > 0:
		iceSpearTimer.wait_time = icespear_reloadspeed #On set le reload speed ici
		if iceSpearTimer.is_stopped():
			iceSpearTimer.start()
	if tornado_level > 0:
		if tornadoAttackTimer.is_stopped():
			tornadoAttackTimer.start()
			
#Function nécéssaire pour que Godot interprete la physique du personnage
#Run automatique toutes les 1/60 seconds | delta = une seconde/frame rate (permet de se déplacer aussi rapidement selon le frame rate)
func _physics_process(_delta):
	movement()

func _on_hurt_box_hurt(damage, _angle, _knockback_amount):
	health -= damage
	print("hp : " + str(health) + " | damage : " + str(damage))

#Chargement des munitions
func _on_ice_spear_timer_timeout():
	icespear_ammo += icespear_baseammo
	iceSpearAttackTimer.start()

#Timer entre chaques tir
func _on_ice_spear_attack_timer_timeout():
	if icespear_ammo > 0:
		var icespear_attack = iceSpear.instantiate()
		icespear_attack.position = position #On utilise la position relative au parent car on shoot directement depuis le joueur pas besoins de global pos
		icespear_attack.target = get_random_target() #Ici on shoot vers un ennemi random
		icespear_attack.level = icespear_level
		add_child(icespear_attack)
		iceSpearAttackTimer.wait_time = icespear_attack.attack_speed * (1-attack_speed)
		icespear_ammo -= 1 #On enlève une munition
		if icespear_ammo > 0:
			iceSpearAttackTimer.start()
		else:
			iceSpearAttackTimer.stop()

func _on_tornado_attack_timer_timeout():
	var tornado_attack = tornado.instantiate()
	tornado_attack.position = position #On utilise la position relative au parent car on shoot directement depuis le joueur pas besoins de global pos
	tornado_attack.last_movement = last_movement #Ici on shoot vers le dernier endroit on on a marché avec un modulo
	tornado_attack.level = tornado_level
	add_child(tornado_attack)
	tornadoAttackTimer.wait_time = tornado_attack.cast_speed * (1-cast_speed)
	print("After adding child | player cast_speed %s, tornado base cast_speed %s, final attack speed for that attack %s" % [cast_speed, tornado_attack.cast_speed, tornadoAttackTimer.wait_time])
	tornadoAttackTimer.start()
		
func get_random_target():
	if enemy_close.size() > 0: #Si on a au moins un ennemi proche
		return enemy_close.pick_random().global_position #On retourne la position global d'un ennemi random sur lequel tiré
	else: 
		return Vector2.UP

func _on_enemy_detection_area_area_2d_body_entered(body):
	if not enemy_close.has(body):
		enemy_close.append(body) #On ajoute l'ennemi dans la liste a atteindre

func _on_enemy_detection_area_area_2d_body_exited(body):
	if enemy_close.has(body):
		enemy_close.erase(body) #On supprime le body de la liste quand il est présent dans la liste et s'en va de la close area
