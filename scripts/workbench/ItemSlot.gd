
class_name WorkbenchItemSlot
extends Button

signal item_selected(item_data: ItemData)

@onready var item_icon: TextureRect = $ItemIcon

var item_data: ItemData


func setup(data: ItemData) -> void:
	item_data = data
	text = data.item_name
	item_icon.texture = data.final_sprite
	tooltip_text = data.item_name


func _ready() -> void:
	pressed.connect(_on_pressed)

	if item_data != null:
		item_icon.texture = item_data.final_sprite
		tooltip_text = item_data.item_name


func _on_pressed() -> void:
	if item_data != null:
		item_selected.emit(item_data)


func _get_drag_data(_at_position: Vector2) -> Variant:
	if item_data == null:
		return null

	var preview := TextureRect.new()
	preview.texture = item_data.final_sprite
	preview.custom_minimum_size = Vector2(100, 100)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	set_drag_preview(preview)

	return item_data
