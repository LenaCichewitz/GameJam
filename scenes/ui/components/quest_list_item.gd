extends VBoxContainer

@onready var body: PanelContainer = $Body

func _ready() -> void:
	$Header.toggled.connect(func(on: bool): $Body.visible = on)
	$Body.visible = false
