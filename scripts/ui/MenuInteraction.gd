extends Node

var PressEOn: bool 
@onready var PressE = $"Press E" #this loads the node u want in a variable
@onready var AnimationP = $AnimationPlayer
#@onready var Options = $Control/PanelContainer/Options

func _ready() -> void:
	PressEOn = false
	#Options.visible = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void: 
	if Input.is_action_just_pressed("interact", true): #ok so player just pressed e and they are allowed to pass
		if PressEOn == false:#checks if they didnt press E before to prevent spamming
				PressEOn == true #boom its on now so it wont turn on again.
				#PressE.visible = false; #makes it invisible, no need to call it now though cuz the animation fades it out
				AnimationP.play("Egoaway")#plays the animation
				
				await AnimationP.animation_finished #waits for the animation to finish
				#Options.visible = true#makes the options visible
	pass
	
