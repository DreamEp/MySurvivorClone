extends CharacterBody2D

var movement_speed: float = 40.0
@onready var sprite2Dplayer = $PlayerSprite2D #Ici on peut faire référence a notre sprite2D du personnage pour faire l'annimation
@onready var walkTimer = get_node("%walkTimer")

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
		if walkTimer.is_stopped(): #Si le walkTimer est arreté
			if sprite2Dplayer.frame >= sprite2Dplayer.hframes - 1: #Frame start to 0 and hframe at 2 that's why we set -1
				sprite2Dplayer.frame = 0 #It reset it to 0
			else: 
				sprite2Dplayer.frame += 1 #It increase the frame by 1
			walkTimer.start()

	velocity = move.normalized()*movement_speed #Définit la physique du mouvement, la vitesse etc | Normalized permet de se déplacer de la meme vitesse en diagonale sinon on serait plus rapide
	move_and_slide() #Interprete le tout pour bouger | utilise delta par défaut
	
#Function nécéssaire pour que Godot interprete la physique du personnage
#Run automatique toutes les 1/60 seconds | delta = une seconde/frame rate (permet de se déplacer aussi rapidement selon le frame rate)
func _physics_process(delta):
	movement()
