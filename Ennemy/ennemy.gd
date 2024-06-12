extends CharacterBody2D

#So we can change the value of the variable directly from the right pannel on ennemy
@export var movemement_speed = 20
@export var health = 10
@export var knockback_recovery = 3 #Reduit le knockback

var knockback = Vector2.ZERO

#@On ready var gets a value after the nodes are loaded we use onready var to reference nodes
#Here we take the first node of group player previously created
@onready var player = get_tree().get_first_node_in_group("player")
@onready var sprite2DKobold = $KoboldSprite2D
@onready var walkAnimationPlayer = $walkAnimationPlayer
@onready var snd_hit = $snd_hit

var death_anim = preload("res://Ennemy/explosion.tscn")

signal remove_from_array(object) #Création d'un nouveau signal pour supprimer un objet d'un array, permet notamment de supprimer l'objet une fois qu'il a été queu_free

func _ready():
	walkAnimationPlayer.play("walk") #We created the walk animation in our animation player

func _physics_process(_delta):
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
	var direction = global_position.direction_to(player.global_position)
	velocity = direction*movemement_speed
	velocity += knockback
	move_and_slide()
	
	#There we get a gap so it don't flip permanently
	if direction.x > 0.1:
		sprite2DKobold.flip_h = true
	elif direction.x < 0.1:
		sprite2DKobold.flip_h = false

func death():
	emit_signal("remove_from_array", self)
	var enemy_death = death_anim.instantiate()
	enemy_death.scale = sprite2DKobold.scale
	enemy_death.global_position = global_position
	get_parent().call_deferred("add_child", enemy_death) #Comme l'ennemi va disparaitre on va spawn l'explosion sur le parent explosion sachant qu'on a set sa position a global position de l'ennemi auparavant
	queue_free() #On supprime l'ennemi si sa vie = 0

func _on_hurt_box_hurt(damage, angle, knockback_amount):
	health -= damage
	knockback = angle * knockback_amount #Quand sa hurtbox est touché on applique le knockback si il y en a un
	if health <= 0:
		death()
	else:
		snd_hit.play()
