extends Area2D

@export_enum("Cooldown", "HitOnce", "DisableHitBox") var HurtBoxType = 0 #Ici en mettant la variable a 0, on fait référence a Coldown

@onready var collision = $CollisionShape2D
@onready var disableTimer = $DisableTimer

signal hurt(damage) #On crée notre propre signal custom qui prend des dommage en argument

#Ici on essaie de détecter si la hitbox(area) entre dans la hurtbox
#area = ce qui entre dans l'area
func _on_area_entered(area_entering):
	if area_entering.is_in_group("attack"):
		if not area_entering.get("damage") == null: #On regarde si notre variable area a la variable damage
			match HurtBoxType:
				0: #Cooldown
					collision.call_deferred("set", "disabled", true) #On set notre shape2D a disabled
					disableTimer.start() #On start alors notre timer
				1: #HitOnce
					pass
				2: #DisableHitBox
					if area_entering.has_method("tempdisable"): #On check si hit_box a bien une méthode tempdisable
						area_entering.tempdisable()
			var damage = area_entering.damage
			emit_signal("hurt", damage) #Ici on émet notre signal custom avec les dommages, dans notre cas lorsque on entre dans la zone hurtbox
			if area_entering.has_method("enemy_hit"): #Si la personne/projectile qui entre dans l'area a une méthode ennemy hit
				area_entering.enemy_hit(1) #On call cette méthode
			
func _on_disable_timer_timeout():
	collision.call_deferred("set", "disabled", false) #Here we set our Shape2D as disabled
