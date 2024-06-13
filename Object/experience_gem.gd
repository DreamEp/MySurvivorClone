extends Area2D

@export var experience = 1 #L'expérience de base donné par la gemme

var green_gem = preload("res://Textures/Items/Gems/Gem_green.png") #On load la gemme verte
var blue_gem= preload("res://Textures/Items/Gems/Gem_blue.png") #On load la gemme bleue
var red_gem = preload("res://Textures/Items/Gems/Gem_red.png") #On load la gemme rouge

var target = null #La target va être la cible de nos gemmes
var speed = -0.5 #La speed négative par défaut permet d'avoir un effet de bounce, elle va alors reculer pour revenir

@onready var sprite = $Sprite2D #On recupere notre node du sprite
@onready var collision = $CollisionShape2D #On recupere notre node de la collision
@onready var sound = $snd_collected #On recupere notre node du son

func _ready():
	if experience < 5: #Si la gemme a une experience < 5 alors on met la couleur verte par défaut
		return
	elif experience < 25:  #Si la gemme a une 5 < experience < 25 alors on met la couleur bleue
		sprite.texture = blue_gem
	else:
		sprite.texture = red_gem  #Si la gemme a une experience > 25 alors on met la couleur bleue

#Comment la gemme va réagir / se mouvoir
func _physics_process(delta):
	if target != null: #Si la target a une valeur
		global_position = global_position.move_toward(target.global_position, speed) #On fait bouger la gemme vers la target
		speed += 2 * delta #Sa speed va être divisé par le framrate

func collect():
	sound.play() #On joue le son lorsqu'on ramasse une gemme
	#sound.connect("finished", Callable(self, "_on_snd_collected_finished")) Ici on a déjà fais une connection au signal avec la fonction
	collision.call_deferred("set","disabled",true) #On enlève sa zone de collision
	sprite.visible = false #On rend la gemme invisible
	return experience #On retourne l'experience de la gemme


func _on_snd_collected_finished():
	queue_free()
