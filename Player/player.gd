extends CharacterBody2D

var movement_speed: float = 40.0

#Fonction custom pour créer notre mouvement
func movement():
	var x_move = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_move = Input.get_action_strength("down") - Input.get_action_strength("up") #Attention le mouvement sur l'axe y est inversé sur Godot donc bien faire down - up !
	var move = Vector2(x_move, y_move) #Définit le vector du mouvement en interpretant x, et y (direction) 
	velocity = move.normalized()*movement_speed #Définit la physique du mouvement, la vitesse etc | Normalized permet de se déplacer de la meme vitesse en diagonale sinon on serait plus rapide
	move_and_slide() #Interprete le tout pour bouger | utilise delta par défaut
	
#Function nécéssaire pour que Godot interprete la physique du personnage
#Run automatique toutes les 1/60 seconds | delta = une seconde/frame rate (permet de se déplacer aussi rapidement selon le frame rate)
func _physics_process(delta):
	movement()
