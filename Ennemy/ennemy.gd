extends CharacterBody2D

#So we can change the value of the variable directly from the right pannel on ennemy
@export var movemement_speed = 20.0

#@On ready var gets a value after the nodes are loaded we use onready var to reference nodes
#Here we take the first node of group player previously created
@onready var player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta):
	var direction = global_position.direction_to(player.global_position)
	velocity = direction*movemement_speed
	move_and_slide()
