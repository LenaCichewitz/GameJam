
extends PanelContainer

signal item_dropped(data: ItemData)
signal item_clicked(data: ItemData)

@onready var item_preview: TextureRect = $Content/ItemPreview

var current_item: ItemData


func _ready() -> void:
	gui_input.connect(_on_item_preview_gui_input)


func display_item(data: ItemData) -> void:
	if data == null:
		return

	current_item = data
	_update_item_display()



func _update_item_display() -> void:
	if current_item == null:
		item_preview.texture = null
		return

	if current_item.needs_punding and current_item.closed_texture != null:
		item_preview.texture = current_item.closed_texture
	else:
		item_preview.texture = current_item.final_sprite


func _on_item_preview_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if current_item != null:
				item_clicked.emit(current_item)

# Sieht so aus als ob "_at_position" nicht gebraucht wird?
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is ItemData

# Sieht so aus als ob "_at_position" nicht gebraucht wird?
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if data is ItemData:
		display_item(data)
		item_dropped.emit(data)


func finish_pounding() -> void:
	if current_item == null:
		return

	current_item.needs_punding = false
	_update_item_display()
