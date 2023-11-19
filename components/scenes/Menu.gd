@tool
extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	#%PlayButton.rect_scale = Vector2(0.5, 0.5)
	#%ExitButton.rect_scale = Vector2(0.5, 0.5)
	
	if Engine.is_editor_hint():
		return
		
	%PlayButton.button_down.connect(
		func():
			get_tree().change_scene_to_file("res://components/scenes/Main.tscn")
	)
	
	%ExitButton.button_down.connect(
		func():
			get_tree().quit()
	)
