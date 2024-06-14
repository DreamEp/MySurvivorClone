extends Area2D

@export_enum("Cooldown", "HitOnce", "DisableHitBox") var HurtBoxType = 0 #Ici en mettant la variable a 0, on fait référence a Coldown

@onready var collision = $CollisionShape2D
@onready var disableTimer = $DisableTimer

signal hurt(damage, angle, knockback, armor_penetration, magic_penetration) #On crée notre propre signal custom qui prend des dommage en argument + un angle + un kknockkback

var hit_once_array = []

#Ici on essaie de détecter si la hitbox(area) entre dans la hurtbox
#area = ce qui entre dans l'area
func _on_area_entered(area_entering):
	if area_entering.is_in_group("attack"):
		if area_entering.get("damage") != null: #On regarde si notre variable area a la variable damage
			match HurtBoxType:
				0: #Cooldown
					collision.call_deferred("set", "disabled", true) #On set notre shape2D a disabled
					disableTimer.start() #On start alors notre timer
				1: #HitOnce
					if hit_once_array.has(area_entering) == false:
						hit_once_array.append(area_entering)
						if area_entering.has_signal("remove_from_array"):
							if not area_entering.is_connected("remove_from_array", Callable(self, "remove_from_list")):
								area_entering.connect("remove_from_array", Callable(self, "remove_from_list"))
					else: 
						return
				2: #DisableHitBox
					if area_entering.has_method("tempdisable"): #On check si hit_box a bien une méthode tempdisable
						area_entering.tempdisable()
			var damage = area_entering.damage
			var angle = Vector2.ZERO
			var knockback = 1
			var armor_penetration = 0
			var magic_penetration = 0
			if area_entering.get("angle") != null: #On check si ce qui entre dans l'area a un angle (on peut mettre not puis null)
				angle = area_entering.angle #On recupere l'angle de l'objet entrant
			if area_entering.get("knockback_amount") != null:
				knockback = area_entering.knockback_amount #On recupere le knockback de l'objet entrant pour l'ajouter dans le signal de degat
			if area_entering.get("armor_penetration") != null:
				armor_penetration = area_entering.armor_penetration
			if area_entering.get("magic_penetration") != null:
				magic_penetration = area_entering.magic_penetration
			emit_signal("hurt", damage, angle, knockback, armor_penetration, magic_penetration) #Ici on émet notre signal custom avec les dommages, dans notre cas lorsque on entre dans la zone hurtbox
			if area_entering.has_method("enemy_hit"): #Si la personne/projectile qui entre dans l'area a une méthode ennemy hit
				area_entering.enemy_hit(1) #On call cette méthode

func remove_from_list(object):
	if hit_once_array.has(object):
		hit_once_array.erase(object)
		
func _on_disable_timer_timeout():
	collision.call_deferred("set", "disabled", false) #Here we set our Shape2D as disabled
