extends CharacterBody2D

#So we can change the value of the variable directly from the right pannel on ennemy
@export var movemement_speed = 20.0

#@On ready var gets a value after the nodes are loaded we use onready var to reference nodes
#Here we take the first node of group player previously created
@onready var player = get_tree().get_first_node_in_group("player")
@onready var sprite2DKobold = $KoboldSprite2D
@onready var walkAnimationPlayer = $walkAnimationPlayer

func _ready():
	walkAnimationPlayer.play("walk") #We created the walk animation in our animation player

func _physics_process(_delta):
	var direction = global_position.direction_to(player.global_position)
	velocity = direction*movemement_speed
	move_and_slide()
	
	#There we get a gap so it don't flip permanently
	if direction.x > 0.1:
		sprite2DKobold.flip_h = true
	elif direction.x < 0.1:
		sprite2DKobold.flip_h = false
