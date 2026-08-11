extends Node

const CURRENT_ART := preload("res://assets/sprites/MenuSprites/Mainmenu/MainMenu1080.png")
const NEXT_ART := preload("res://assets/sprites/MenuSprites/Mainmenu/MainMenu2.png")

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
				PressEOn = true #boom its on now so it wont turn on again.
				#PressE.visible = false; #makes it invisible, no need to call it now though cuz the animation fades it out
				AnimationP.play("Egoaway")#plays the animation

				var shatter := GlassShatter.new()
				shatter.current_texture = CURRENT_ART
				shatter.next_texture = NEXT_ART
				add_child(shatter)
				await shatter.play_shatter() #crack and fall away to reveal the next screen
				SceneManager.goto("menu2", {}, false)
	pass
	
