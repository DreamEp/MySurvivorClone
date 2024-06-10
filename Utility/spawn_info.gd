extends Resource

class_name Spawn_info

@export var time_start: int #le début du timer de spawn
@export var time_end: int #fin du timer de spawn
@export var ennemy: Resource #type d'ennemi a spawn
@export var enemy_num: int #nombre d'ennemi a spawn tous les x delai
@export var enemy_spawn_delay: int #delai entre les spawns (si je met 1, il y'a 2 secondes de délai)

var spawn_delay_counter = 0 #permet d'avoir un counter pour reset le timer
