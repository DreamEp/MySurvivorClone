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
	- [5 General Settings :](#5-general-settings-)



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
- There is 4 ways to refer our nodes:
  - Directly refer it with his name using $name / if we change the name or path we have to change in each area..
  - Using @onready variable and the reference $ / if we change the name or path we have to change it in one area.
  - Using @onready variable with access unique name (get_node("%name")) / long to setup but if we change the path there is nothing to change in our code but it has to be an unique name
  - Using a function to fetch the node get_tree().get_first_node_in_group("sprite_in_group") / powerfull if we don't know the exact name of the node but it long to setup.

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

## 5 General Settings : 
	
- General/Display/Window : 
	- Set viewport (640x360) max (1280x720)
	- Stretch mode canvasitems (zoom out)

- Input Map/New Action :
	- Add up, down, left and right event
	- On this events, set our keybinds associated to those (match the key /!\ latin or physical keycode depends on which type of keyboard)

- At the top of godot interface you can switch to script or 2D visualization


If you want the basics texture (go to the ref)
		
Ref : https://github.com/brannotaylor/SurvivorsClone_Base

