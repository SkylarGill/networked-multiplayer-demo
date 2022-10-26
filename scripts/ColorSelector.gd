# this is an implementation of a radio button for the colour selection control

extends Control

export(Array, Color) var colors : Array
export(PackedScene) var color_button_scene : PackedScene
export(ButtonGroup) var button_group : ButtonGroup

onready var player_body_preview : Polygon2D = $"%PlayerBodyPreview"

var images: Array
var selected_color : Color

func _ready():
	var firstButton = true
	for color in colors:
		var button : Button = color_button_scene.instance()
		
		if firstButton: 
			button.pressed = true
			player_body_preview.color = color
			selected_color = color
			firstButton = false
			
		button.modulate = color
		button.group = button_group
		button.connect("pressed", self, "_button_pressed")		
		add_child(button)
			
func _button_pressed():
	var button : BaseButton = button_group.get_pressed_button()
	selected_color = button.modulate
	player_body_preview.color = selected_color
