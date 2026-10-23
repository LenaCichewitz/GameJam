extends Control

@onready var main_buttons: VBoxContainer = $MainButtons
@onready var titel: Label = $Titel
@onready var options: Panel = $Options

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_buttons.visible = true
	titel.visible = true
	options.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_new_game_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/management_root.tscn")

func _on_start_pressed() -> void:
	pass # Replace with function body.

func _on_setting_pressed() -> void:
	main_buttons.visible = false
	titel.visible = false
	options.visible = true

func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_exit_button_pressed() -> void:
	_ready()
