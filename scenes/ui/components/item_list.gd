extends Control

@onready var item_icon: TextureRect = $VBoxContainer/ItemIcon
@onready var item_name: Label = $VBoxContainer/ItemName
@onready var item_id: Label = $VBoxContainer/ItemId

signal item_list_pressed

func _ready():
	item_id.hide()

func setup(item : Object):
	item_icon.texture_normal = item.item_picture
	item_name.text = item.item_name
	item_id.text = item.item_id

func _on_item_icon_pressed() -> void:
	item_list_pressed.emit(item_id)
