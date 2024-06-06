How to create your own game step by step : 

I . Initialisation - World

	- Create new project
	- Add a 2D Scene (Parent node - it's a place) = our World
	- Add a 2D Sprite to this node (Child node - it's a texture) = our Background
		In texture we drag our png 
		Create a region with enabled (set W and H for size)
		Repeat enabled so it dont messed up our initial texture and duplicate it instead
		Go to Filter section to play around the graphic quality
	- Save the world in a new folder of the project
		
II . Character

	- Add a character by adding a CharacterBody2D = our Player
	- Save this branch as Scene so it can get his own child and add some code to it
	- Save the player to a new folder of the project
	- Add a 2D Sprite to this node (Child node - it's a texture)
		In texture we drag our png 
		In animation we set the Hframes by number of copy (2 in our case)
	- Motion mode to grounded (for supermario where we can fall else floating)
	
	Code :
		Attach a new script to the selected node
		
		1) Movement :
			It will define how our player moove (go to the code to see more details)
		
	

General Settings : 
	
	General/Display/Window : 
		Set viewport (640x360) max (1280x720)
		Stretch mode canvasitems (zoom out)
	
	Input Map/New Action :
		Add up, down, left and right event
		On this events, set our keybinds associated to those (match the key /!\ latin or physical keycode depends on which type of keyboard)


If you want the basics texture (go to the ref)
		
Ref : https://github.com/brannotaylor/SurvivorsClone_Base

