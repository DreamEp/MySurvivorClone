extends Area2D

@export var damage = 1
@onready var collision = $CollisionShape2D
@onready var disableTimer = $DisableHitBoxTimer

#On désactive la collision pendant 0.5 seconds
func tempdisable():
	collision.call_deferred("set", "disabled", true)
	disableTimer.start()

#Ici on réactive la collision à la fin du timer (ici 0.5 seconds)
func _on_disable_hit_box_timer_timeout():
	collision.call_deferred("set", "disabled", false)
