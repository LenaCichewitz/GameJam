extends Control

@onready var item_icon: TextureRect = $VBoxContainer/ItemIcon
@onready var item_name: Label = $VBoxContainer/ItemName

func setup(item : Object):
	item_icon.texture = item.item_picture
	item_name.text = item.item_name
