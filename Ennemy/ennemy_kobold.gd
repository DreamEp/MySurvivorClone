extends CharacterBody2D

#So we can change the value of the variable directly from the right pannel on ennemy
@export var movemement_speed = 20
@export var health = 10
@export var knockback_recovery = 3 #Reduit le knockback
@export var min_experience = 0 #Combien va nous fournir d'exp le kobold au minimum
@export var max_experience = 5 #Combien va nous fournir d'exp le kobold au minimum

var knockback = Vector2.ZERO
var kobold_current_sprite_color = self.modulate #"On recupere notre sprite intial"

#@On ready var gets a value after the nodes are loaded we use onready var to reference nodes
#Here we take the first node of group player previously created
@onready var player = get_tree().get_first_node_in_group("player")
@onready var lootBase = get_tree().get_first_node_in_group("loot") #Fais référence au node Loot de world ici
@onready var sprite2DKobold = $KoboldSprite2D
@onready var walkAnimationPlayer = $walkAnimationPlayer
@onready var snd_hit = $snd_hit

var death_anim = preload("res://Ennemy/explosion.tscn") #Preload la scene de destruction
var exp_gem = preload("res://Object/experience_gem.tscn") #Preload la scene gem

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
	var enemy_death = death_anim.instantiate() #On instancie la death animation
	enemy_death.scale = sprite2DKobold.scale #On scale sa taille sur celle du kobold
	enemy_death.global_position = global_position #On le position sur celle du kobold
	get_parent().call_deferred("add_child", enemy_death) #Comme l'ennemi va disparaitre on va spawn l'explosion sur le parent explosion sachant qu'on a set sa position a global position de l'ennemi auparavant
	var new_gem = exp_gem.instantiate() #On instancie une nouvelle gemme
	new_gem.global_position = global_position #On la positionne au niveau du kobold mort
	new_gem.experience = randi_range(min_experience, max_experience) #La gemme prend une valeur random entre le min et le max
	lootBase.call_deferred('add_child', new_gem) #On ajoute la gemme sur notre node world/loot
	queue_free() #On supprime l'ennemi si sa vie = 0

func _on_hurt_box_hurt(damage, angle, knockback_amount):
	health -= damage #On fait des dégats au kobold avec les dmg
	knockback = angle * knockback_amount #Quand sa hurtbox est touché on applique le knockback si il y en a un
	if health <= 0:
		death()
	else:
		var tween_color = create_tween() #On va changer la couleur ici
		tween_color.tween_property(self, "modulate", Color(Color.RED), 0.1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT) #Permet que lorsque le kobold subit des dégats on change rapidement sa couleur en rouge
		tween_color.tween_property(self, "modulate", kobold_current_sprite_color, 0.1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT) #Puis celle-ci revient à la normale
		tween_color.set_loops(2) #On l'applique 2 fois pour faire un effet
		tween_color.play()
		snd_hit.play()
