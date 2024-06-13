extends CharacterBody2D

var player_movement_speed: float = 60.0
var player_health = 80
var player_attack_speed = 0.1
var player_cast_speed = 0.3
var player_attack_area = 0.1

var player_experience = 0
var player_experience_level = 1
var player_collected_experience = 0

var player_last_movement = Vector2.UP #Recupère notre précédent mouvement
var player_current_sprite_color = self.modulate #"On recupere notre sprite intial"

#Attacks
var iceSpear = preload("res://Player/Attacks/ice_spear.tscn")
var tornado = preload("res://Player/Attacks/tornado.tscn")
var javelin = preload("res://Player/Attacks/javelin.tscn")

#AttacksNodes
@onready var iceSpearTimer = get_node("%IceSpearReloadTimer") #reload
@onready var iceSpearAttackTimer = get_node("%IceSpearAttackTimer") #attack speed
@onready var tornadoAttackTimer = get_node("%TornadoAttackTimer")
@onready var javelinBase = get_node("%JavelinBase")

#IceSpear
var icespear_ammo = 0
var icespear_baseammo = 2
var icespear_reloadspeed = 3
var icespear_level = 1

#Tornado
var tornado_level = 1

#Javelin
var javelin_max_spawns_limit = 1
var javelin_level = 1

#Ennemy related
var enemy_close = []


@onready var sprite2Dplayer = $PlayerSprite2D #Ici on peut faire référence a notre sprite2D du personnage pour faire l'annimation
@onready var walkTimer = get_node("%walkTimer") #Ici on fait référence a notre walkTimer d'une manière différente, permet notamment d'être path sensitive

#GUI
@onready var expBar =  get_node("%ExperienceBar")
@onready var labelLevel = get_node("%LabelLevel")
@onready var levelPanel = get_node("%LevelUp")
@onready var sndLevelUp = get_node("%snd_levelup")

@onready var upgradeOptions = get_node("%UpgradeOption")
@onready var itemOptions = preload("res://Utility/item_option.tscn")

#Se lance dès la première frame
func _ready():
	attack()
	set_expbar(player_experience, calculate_experience_cap())
	
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
		player_last_movement = move #On met à jour le dernier mouvement avec le nouveau
		if walkTimer.is_stopped(): #Si le walkTimer est arreté
			if sprite2Dplayer.frame >= sprite2Dplayer.hframes - 1: #Frame start to 0 and hframe at 2 that's why we set -1
				sprite2Dplayer.frame = 0 #It reset it to 0
			else: 
				sprite2Dplayer.frame += 1 #It increase the frame by 1
			walkTimer.start()

	velocity = move.normalized()*player_movement_speed #Définit la physique du mouvement, la vitesse etc | Normalized permet de se déplacer de la meme vitesse en diagonale sinon on serait plus rapide
	move_and_slide() #Interprete le tout pour bouger | utilise delta par défaut
	
func attack():
	if icespear_level > 0:
		iceSpearTimer.wait_time = icespear_reloadspeed #On set le reload speed ici
		if iceSpearTimer.is_stopped():
			iceSpearTimer.start()
	if tornado_level > 0:
		if tornadoAttackTimer.is_stopped():
			tornadoAttackTimer.start()
	if javelin_level > 0:
		spawn_javelin()			
				
#Function nécéssaire pour que Godot interprete la physique du personnage
#Run automatique toutes les 1/60 seconds | delta = une seconde/frame rate (permet de se déplacer aussi rapidement selon le frame rate)
func _physics_process(_delta):
	movement()

func _on_hurt_box_hurt(damage, _angle, _knockback_amount):
	player_health -= damage
	var tween_color = create_tween()
	tween_color.tween_property(self, "modulate", Color(Color.RED), 0.1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT) #Permet que lorsque le kobold subit des dégats on change rapidement sa couleur en rouge
	tween_color.tween_property(self, "modulate", player_current_sprite_color, 0.1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT) #Puis celle-ci revient à la normale
	tween_color.play()
	print("hp : " + str(player_health) + " | damage : " + str(damage))

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
		iceSpearAttackTimer.wait_time = icespear_attack.attack_speed * (1-player_attack_speed)
		icespear_ammo -= 1 #On enlève une munition
		if icespear_ammo > 0:
			iceSpearAttackTimer.start()
		else:
			iceSpearAttackTimer.stop()

func _on_tornado_attack_timer_timeout():
	var tornado_attack = tornado.instantiate()
	tornado_attack.position = position #On utilise la position relative au parent car on shoot directement depuis le joueur pas besoins de global pos
	tornado_attack.player_last_movement = player_last_movement #Ici on shoot vers le dernier endroit on on a marché avec un modulo
	tornado_attack.level = tornado_level
	add_child(tornado_attack)
	tornadoAttackTimer.wait_time = tornado_attack.cast_speed * (1-player_cast_speed)
	tornadoAttackTimer.start()

#Ici on fait spawn un javelot
func spawn_javelin():
	var javelin_current_total = javelinBase.get_child_count() #On récupère le nombre de javelot déjà invoqué/spawné
	var javelin_calc_spawns = javelin_max_spawns_limit - javelin_current_total #On calcule le nombre restant a invoquer selon la limite de spawn pour les javelots
	while javelin_calc_spawns > 0: #Si elle est supérieur à 0
		var javelin_spawn = javelin.instantiate() #Alors on instancie un javelot
		javelin_spawn.global_position = global_position #On le set àà l'emplacement du joueur
		javelinBase.add_child(javelin_spawn) #On l'ajoute concrètement a notre node
		javelin_calc_spawns -= 1
		#await get_tree().create_timer(javelin_spawn.spawn_delay).timeout #On attends le timer de spawn avant d'en créer un nouveau
		
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

func _on_grab_area_area_entered(area):
	if area.is_in_group("loot"): #Si l'objet qui entre dans l'area est bien dans le groupe loot
		area.target = self #Alors on définit la target du grab a notre joueur

func _on_collect_area_area_entered(area):
	if area.is_in_group("loot"): #Si l'objet qui entre dans l'area est bien dans le groupe loot
		var gem_exp = area.collect() #La fonction collect de la gemme retourne bien l'experience de la gemme
		calculate_experience(gem_exp)

#Permet de calculer l'experience collecté puis de la rattaché a notre barre d'experience		
func calculate_experience(gem_exp):
	var exp_required = calculate_experience_cap() #Permet de calculer l'experience requise avant de level up
	player_collected_experience += gem_exp #On ajoute l'experience collecté a notre barre d'experience
	if player_experience + player_collected_experience >= exp_required: #Si l'experience collecté est supérieur a l'expérience requise pour level up
		player_collected_experience -= exp_required - player_experience #On recupere le surplus potentiel d'expérience pour le nouveau niveau
		player_experience_level += 1 #On level up notre niveau d'expérience
		player_experience = 0
		exp_required = calculate_experience_cap() #On met a jour l'experience requise
		levelup() #On call la function pour levelup qui gère le process d'upgrade etc..
		print("Level UP ! Level experience: %s, experience_collected: %s, experience: %s, experience_required: %s, triggered_amount_xp: %s"  % [player_experience_level, player_collected_experience, player_experience, exp_required, gem_exp])
	else:
		player_experience += player_collected_experience #On met a jour l'experience de notre joeur
		player_collected_experience = 0
		print("No ! Level experience: %s, experience_collected: %s, experience: %s, experience_required: %s, triggered_amount_xp: %s"  % [player_experience_level, player_collected_experience, player_experience, exp_required, gem_exp])
	set_expbar(player_experience, exp_required)
	
#Ici on fait le calcule de l'expérience collecté selon les levels, avant de level up	
func calculate_experience_cap():
	var exp_cap = player_experience_level
	if player_experience_level < 20: 
		exp_cap = player_experience_level * 5 #Permet de dire que les 20 premier niveau il faut 5 * l'xp pour level up lvl 1 : 5xp, lv 2 : 10 xp, lv 3 :15 (15+10+5=25au total)
	elif player_experience_level < 40:
		exp_cap = 95 + (player_experience - 19) * 8 #Permet de dire que les 20 à 40 niveau il faut 8 * l'xp pour level up
	else:
		exp_cap = 255 + (player_experience - 39) * 12 #Permet de dire qu'à partir du niveau 40 il faut 12 * l'xp pour level up
	return exp_cap

#Fonction qui met à jour la barre d'exp
func set_expbar(set_value = 1, set_max_value = 100):
	expBar.value = set_value
	expBar.max_value = set_max_value

#Function qui gère le menu d'affichage quand on level up (GUI)
func levelup():
	sndLevelUp.play() #On joue le son de level up
	labelLevel.text = str("Level : ", player_experience_level) #On met a jour le texte avec le level actuel
	var tween = levelPanel.create_tween() #On créer un tween sur le Pannel pour modifier sa position
	tween.tween_property(levelPanel, "position", Vector2(220, 50), 0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN) #On approche le panel de level up du centre !
	tween.play()
	levelPanel.visible = true #On rend le pannel levelUp visible que lorsqu'on level up
	var options = 0 #Compteur pour voir combien on a d'option
	var optionsmax = 3 #On set combien d'options d'upgrade max on veut afficher
	while options < optionsmax: #Tant qu'on a pas atteint la limite d'option a afficher on en créer
		var option_choice = itemOptions.instantiate() #On instancie notre objet option via ça scene
		upgradeOptions.add_child(option_choice) #On l'ajoute a notre node vboxOption
		options += 1
	get_tree().paused = true #On pause alors le jeux
	
func upgrade_character(upgrade):
	var option_children = upgradeOptions.get_children() #On recupere les différentes options du pannel
	for i in option_children: 
		i.queue_free() #On supprime chaque option du pannel
	levelPanel.visible = false #On rend invisible le pannel de monter de niveau
	levelPanel.position = Vector2(800, 50) #On replace loin le pannel pour avoir de nouveau l'effet quand il pop
	get_tree().paused = false #On met le jeux en marche à nouveau
	calculate_experience(0) #Permet de gérer plusieurs level up d'un coup
