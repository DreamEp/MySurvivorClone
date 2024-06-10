<!-- title:  # How to create your own game step by steps --> 
# How to create your own game step by steps

- [How to create your own game step by steps](#how-to-create-your-own-game-step-by-steps)
	- [1. Initialisation - World](#1-initialisation---world)
	- [2. Character](#2-character)
		- [2.1. Movement :](#21-movement-)
	- [3. Ennemy AI](#3-ennemy-ai)
		- [3.1. Movement :](#31-movement-)
	- [4. Annimation](#4-annimation)
		- [4.1 Facing right direction](#41-facing-right-direction)
			- [4.1.1 For our player](#411-for-our-player)
			- [4.1.2 For our kobold ennemy](#412-for-our-kobold-ennemy)
		- [4.2 Walking animation](#42-walking-animation)
			- [4.2.1 For our player](#421-for-our-player)
			- [4.2.2 For our kobold ennemy](#422-for-our-kobold-ennemy)
	- [5. Hurt box and hit box :](#5-hurt-box-and-hit-box-)
		- [5.1. HitBox :](#51-hitbox-)
		- [5.2. HurtBox :](#52-hurtbox-)
	- [6. Create an ennemy spawner :](#6-create-an-ennemy-spawner-)
		- [6.1. Create a resource/class Spawn\_info :](#61-create-a-resourceclass-spawn_info-)
		- [6.2. Create an ennemy spawner :](#62-create-an-ennemy-spawner-)
	- [5. General Settings :](#5-general-settings-)
	- [6. Lessons :](#6-lessons-)
	- [7. Review/Missunderstanding :](#7-reviewmissunderstanding-)



## 1. Initialisation - World

- Create new project
- Add a 2D Scene (Parent node - it's a place) = our World
- Add a 2D Sprite to this node (Child node - it's a texture) = our Background
	- In texture we drag our png 
	- Create a region with enabled (set W and H for size)
	- Repeat enabled so it dont messed up our initial texture and duplicate it instead
Go to Filter section to play around the graphic quality
- Save the world in a new folder of the project
		
## 2. Character

- Add a character by adding a CharacterBody2D = our Player
- Save this branch as Scene so it can get his own child and add some code to it
- Save the player to a new folder of the project
- Add a 2D Sprite to this node (Child node - it's a texture)
In texture we drag our png 
In animation we set the Hframes by number of copy (2 in our case)
- Motion mode to floating (grounded for supermario where we can fall else floating)
- Click on Node (at the right) from player script to create a group for the player
- Create a camera2D on the player so the camera moove with the player
- Create a collisionShape2D, at the right change the shape to capsuleshape

<br/>
To Code : Attach a new script to the selected node

### 2.1. Movement :

It will define how our player move (go to the code to see more details)

```GdScript
var movement_speed: float = 40.0

func movement():
	var x_move = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_move = Input.get_action_strength("down") - Input.get_action_strength("up")
	var move = Vector2(x_move, y_move)
	velocity = move.normalized()*movement_speed
	move_and_slide()

func _physics_process(delta):
	movement()	
```

## 3. Ennemy AI

- Create a new scene (+ at top of godot interface), and add CharacterBody2D = our Ennemy
- Save the player to a new folder of the project called Ennemy
- Add a 2D Sprite to this node (Child node - it's a texture)
In texture we drag our png 
In animation we set the Hframes by number of copy (2 in our case)
- Motion mode to floating (grounded for supermario where we can fall else floating)
- 3.1
- Drag the ennemy.tscn to the world scene to add the ennemy on our world
- On the 2D scene we can press alt and then moove the ennemy so it dont start on our player
- Create a collisionShape2D, at the right change the shape to capsuleshape

### 3.1. Movement :

It will define how our player move (go to the code to see more details)
We use global position to refer to the position of our player instead of the position to the parent.

```GdScript
@export var movemement_speed = 20.0

@onready var player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta):
	var direction = global_position.direction_to(player.global_position)
	velocity = direction*movemement_speed
	move_and_slide
```
## 4. Annimation

- On our player, we can set flip_h to flip horizontally (we will do it in code)
- We had a onready var sprite to refer to the sprite of our player in our script
- We can change the frame of our player in animation in the right pannel. To do it automatically :
  -  We create a new node Timer. This works as a stopwatch, 
  -  We set wait_time to 0.2 in right pannel 
  -  We set it to one shot to run only once.
- Right click on the walkTimer created and set "access as unique name"
- Then work in the script to do the walking animation as intended
- 
- For the facing animation of our ennemy Kobold we do the same as our player instead we're setting a little gap in our if condition so it don't turn permanently
- For the walking animation of our Kobold we don't do the same, since we want it to run permanently and automaticaly. 
  	- So we create a new node animation
  	- We add an animation "walk" on the bottom panel 
  	- We set it to run each 0.6 seconds (at the right) and set it as repeating
  	- We click on sprite layer then we set the frame from the right button and create it
  	- At 0.3 of our animation we change the frame to 1
  	- At 0.6 then we reset it to frame 0
  	- Reference the animation on our code in a func function _ready() which is intern to Godot working since the start we reference our walk animation

### 4.1 Facing right direction 

#### 4.1.1 For our player

We're working on the movement function of our player
```GdScript
@onready var sprite2Dplayer = $PlayerSprite2D

func movement():

""
	if move.x > 0:
		sprite2Dplayer.flip_h = true
	#Sinon on ne le flip pas si on va a gauche
	elif move.x < 0:
		sprite2Dplayer.flip_h = false
""
```
#### 4.1.2 For our kobold ennemy 

We're working on the _physics_process function of our ennemy
```GdScript
@onready var sprite2DKobold = $KoboldSprite2D

func _physics_process(_delta):

""
	if direction.x > 0.1:
		sprite2DKobold.flip_h = true
	elif direction.x < 0.1:
		sprite2DKobold.flip_h = false
""
```

### 4.2 Walking animation 

#### 4.2.1 For our player

We're working on the movement function of our player and previously created a timer node
```GdScript
@onready var walkTimer = get_node("%walkTimer")

func movement():

""
	if move != Vector2.ZERO:
		if walkTimer.is_stopped():
			if sprite2Dplayer.frame >= sprite2Dplayer.hframes - 1: 
				sprite2Dplayer.frame = 0 
			else: 
				sprite2Dplayer.frame += 1 
			walkTimer.start()
""
```

#### 4.2.2 For our kobold ennemy

We previously created an animation, time to refer it and use it in our code
```GdScript
@onready var walkAnimationPlayer = $walkAnimationPlayer

func _ready():
	walkAnimationPlayer.play("walk")
```

## 5. Hurt box and hit box : 

Hit box is the aggressive one, since we hit someone vs hurtbox we are hurting meens we took damage and not dealing them.
- We can had a health variable in both of our ennemy and player
- We create a new scene Area2D, this can detect collision but don't apply physics on it = Hitbox
- We create on this a node CollisionShape2D = Hitbox
- We add a timer on it too (set it to 0.5 and oneshot)
- We save all of this on a new folder called Utility
- Add a new script
- Do the same for the HurtBox
- In hurtbox we create a signal (built-in function) from the Area2D called area_entered
- In hitbox we create a group named attack
- We create a new signal named timeout for our timer in hurtbox/hitbox, this will be triggered when our timer is ended, in our case after 0.5 seconds
- We remove the layer/mask in our parent hitbox/hurtbox (in collision)
- We add those hurtbox and hitbox to our ennemy by dragging .tscn script  to our player and ennemy scene
  - We rightclick on hurtbox/hitbox imported and rightclick to editable children
  - For our collisiong shape we add a rectangle shape for hurtbox, same for hitbox instead it will be smaller and realy on top of the ennemy
  - We add the hurtbox to ennemy layer/mask
  - We add the hitbox to player layer/mask
- We add a hurtbox on our player aswell 
  - Set it collision to player
  - We connect the hurt signal (previously created) on player hurtbox 

### 5.1. HitBox :

It will define the hitbox of our player/ennemy by adding it to the scene of player or ennemy - the hitbox is to deal damage so it's agressive one

```GdScript
@export var damage = 1
@onready var collision = $CollisionShape2D
@onready var disableTimer = $DisableHitBoxTimer

func tempdisable():
	collision.call_deferred("set", "disabled", true)
	disableTimer.start()

func _on_disable_hit_box_timer_timeout():
	collision.call_deferred("set", "disabled", false)
```

### 5.2. HurtBox :

It will define the hurtbox of our player/ennemy by adding it to the scene of player or ennemy - the hurtbox is to received the damage

```GdScript
@onready var collision = $CollisionShape2D
@onready var disableTimer = $DisableTimer

signal hurt(damage) 

func _on_area_entered(area):
	if area.is_in_group("attack"):
		if not area.get("damage") == null: 
			match HurtBoxType:
				0: #Cooldown
					collision.call_deferred("set", "disabled", true) 
					disableTimer.start() 
				1: #HitOnce
					pass
				2: #DisableHitBox
					if area.has_method("tempdisable"): 
						area.tempdisable()
			var damage = area.damage
			emit_signal("hurt", damage) 

func _on_disable_timer_timeout():
	collision.call_deferred("set", "disabled", false)
```

## 6. Create an ennemy spawner : 

We don't need anymore our child node ennemy to be related to our world.

- Create a 2Dscene node EnemySpawner
- Add a timer
- Save this under utility
- Create a script related to our new scene
- Create a new script under utility named spawn_info, double click and add extends Resource to it.
- Go to section 6.1 to generate the code for our spawn_info script
- In our EnemySpawner node we are now able to increase size of Spawns and add a spawn_info related to it
  - We can set now the time range for our ennemy to spawn
  - The type of ennemy by dragging the kobold.tscn file to ennemy
- Connect the timer to our ennemy spawner by adding a timeout signal
- Create the relative code to ennemy_spawner in 6.2
- Drag and drop the EnnemySpawner node (.tscn) in our world

### 6.1. Create a resource/class Spawn_info :

It will define the class spawn_info and the attribute related to it

```GdScript
extends Resource

class_name Spawn_info

@export var time_start: int
@export var time_end: int
@export var ennemy: Resource
@export var enemy_num: int
@export var enemy_spawn_delay: int

var spawn_delay_counter = 0
```

### 6.2. Create an ennemy spawner :

Create the logic about ennemy spawner and the spawn location

```GdScript
@export var spawns : Array[Spawn_info] = []
@onready var player = get_tree().get_first_node_in_group("player")
var time = 0

func _on_timer_timeout():
	time += 1
	var ennemy_spawns = spawns
	for i in ennemy_spawns:
		if time >= i.time_start and time <= i.time_end:
			if i.spawn_delay_counter <= i.enemy_spawn_delay: 
				i.spawn_delay_counter += 1
			else:
				i.spawn_delay_counter = 0 
				var new_ennemy = load(str(i.ennemy.resource_path))
				var counter = 0
				while counter < i.enemy_num: 
					var ennemy_spawn = new_ennemy.instantiate() 
					ennemy_spawn.global_position = get_random_position() 
					add_child(ennemy_spawn)
					counter += 1 

func get_random_position():
	var vpr = get_viewport_rect().size * randf_range(1.1, 1.4) 
	var top_left = Vector2(player.global_position.x - vpr.x/2, player.global_position.y - vpr.y/2)
	var top_right = Vector2(player.global_position.x + vpr.x/2, player.global_position.y - vpr.y/2)
	var bottom_left = Vector2(player.global_position.x - vpr.x/2, player.global_position.y + vpr.y/2)
	var bottom_right = Vector2(player.global_position.x + vpr.x/2, player.global_position.y + vpr.y/2)
	
	var pos_side = ["up", "down", "right", "left"].pick_random() 
	var spawn_pos1 = Vector2.ZERO
	var spawn_pos2 = Vector2.ZERO
	
	match pos_side:
		"up":
			spawn_pos1 = top_left
			spawn_pos2 = top_right
		"down":
			spawn_pos1 = bottom_left
			spawn_pos2 = bottom_right
		"right":
			spawn_pos1 = top_right
			spawn_pos2 = bottom_right
		"left":
			spawn_pos1 = top_left
			spawn_pos2 = bottom_left
	
	var x_spawn = randf_range(spawn_pos1.x, spawn_pos2.x)
	var y_spawn = randf_range(spawn_pos1.y, spawn_pos2.y)
	
	return Vector2(x_spawn, y_spawn)
```

## 5. General Settings : 
	
- General/Display/Window : 
	- Set viewport (640x360) max (1280x720)
	- Stretch mode canvasitems (zoom out)

- Input Map/New Action :
	- Add up, down, left and right event
	- On this events, set our keybinds associated to those (match the key /!\ latin or physical keycode depends on which type of keyboard)

- General/Layer/2DLayer - Physics :
	- Layer1 = World
	- Layer2 = Player
	- Layer3 = Enemy
	- Layer4 = Loot
- At the top of godot interface you can switch to script or 2D visualization
- To add a signal/or a group we go to the node pannel at right

## 6. Lessons : 
	
- Refer a node, 4 ways :
  - Directly refer it with his name using $name / if we change the name or path we have to change in each area..
  - Using @onready variable and the reference $ / if we change the name or path we have to change it in one area.
  - Using @onready variable with access unique name (get_node("%name")) / long to setup but if we change the path there is nothing to change in our code but it has to be an unique name
  - Using a function to fetch the node get_tree().get_first_node_in_group("sprite_in_group") / powerfull if we don't know the exact name of the node but it long to setup.
- The Layer and Mask :
  - Layer tell us "I exist on" the following layer(s)
  - Mask tell us "I will collide with items that exist on the following layers"

## 7. Review/Missunderstanding : 
	
- position vs global position


If you want the basics texture (go to the ref)
		
Ref : https://github.com/brannotaylor/SurvivorsClone_Base

