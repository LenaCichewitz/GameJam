
extends Control

@export var available_items: Array[ItemData] = []

@onready var item_bar: HBoxContainer = $MainLayout/ItemBar
@onready var target_box = $MainLayout/WorkArea/TargetBox

var item_slot_scene: PackedScene = preload(
    "res://scenes/workbench/ItemSlot.tscn"
)


func _ready() -> void:
	print("Workbench gestartet")
	print("Anzahl verfügbarer Items: ", available_items.size())

	for data in available_items:
		if data == null:
			continue

		var slot = item_slot_scene.instantiate()
		item_bar.add_child(slot)

		slot.call("setup", data)
		slot.connect(
			"item_selected",
			_on_item_selected
		)

		print("Item hinzugefügt: ", data.item_name)


func _on_item_selected(data: ItemData) -> void:
	target_box.call("display_item", data)
