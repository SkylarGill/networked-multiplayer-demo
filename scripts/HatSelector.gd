# this is an implementation of a carousel like control for hat selection

extends Node2D

onready var previous_hat_button = $"%PreviousHatButton"
onready var next_hat_button = $"%NextHatButton"

var hat_options : Array
export var selected_hat : String
var index : int = 0

func _ready():
	var hats = get_children()
	for hat in hats:
		if hat is Sprite:
			hat_options.append(hat)
	
	hat_options.front().show()
	selected_hat = hat_options[index].name
	
	next_hat_button.connect("pressed", self, "_increment_hat")
	previous_hat_button.connect("pressed", self, "_decrement_hat")

func _increment_hat():
	hat_options[index].hide()
	
	index += 1
	if index >= hat_options.size():
		index = 0
		
	hat_options[index].show()
	selected_hat = hat_options[index].name

func _decrement_hat():
	hat_options[index].hide()
	
	index -= 1
	if index < 0:
		index = hat_options.size() - 1
		
	hat_options[index].show()	
	selected_hat = hat_options[index].name
