extends Area2D

var level = 1
var health = 1
var attack_speed = 0.7
var bullet_speed = 100
var damage = 5
var knock_amount = 100
var attack_area = 1.0

var target = Vector2.ZERO
var angle = Vector2.ZERO

@onready var player = get_tree().get_first_node_in_group("player")

#Actif dès la premiere frame
func _ready():
	angle = global_position.direction_to(target) #On recupere l'angle en comparant la global position de l'ice spear avec la target
	rotation = angle.angle() + deg_to_rad(135) #On set la property rotation de l'ice spear en transforamnt les degré en radiant, par défaut l'ice spear est en -45 donc (-45+135 = 90 = icespear a l'horizontal Vector(1,0))
	match level:
		1:
			health = 2
			attack_speed = 1
			bullet_speed = 100
			damage = 5
			knock_amount = 100
			attack_area = 1.0
		2:
			health = 1
			attack_speed = 0.7
			bullet_speed = 100
			damage = 6
			knock_amount = 100
			attack_area = 1.0
	#Permet de créer un effet sur le projectile ici		
	var tween = create_tween()
	#On change la valeur scale du node parent en multipliant un vecteur 1,1 par l'area du projectile est en disant que celui ci grossis en 3 sec, avec un effet ease_out
	tween.tween_property(self, "scale", Vector2(1,1) * attack_area, 3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.play()

#Décrit la logique de l'ice spear
func _physics_process(delta):
	position += angle * bullet_speed * delta
	
#Décrit la logique lorsqu'on touche un ennemi (pour supprimer l'attaque, si on ne fait pas cette méthode alors l'attaque passe a travers
func enemy_hit(charge = 1):
	health -= charge #Si on touche on reduit la "vie' de l'ice spear par 1
	if health <= 0:
		queue_free() #la vie est nulle ou inférieur a 0 on supprime l'attaque
		
#Après 10 secondes on supprime le ice spear (dans le cas ou on miss)
func _on_timer_timeout():
	queue_free()
