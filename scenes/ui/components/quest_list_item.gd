extends VBoxContainer


func _ready() -> void:
	$Header.toggled.connect(func(on: bool): $Body.visible = on)
	$Body.visible = false
