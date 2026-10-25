
class_name WorkbenchItemSlot
extends Button

signal item_selected(item_data: ItemData)


@onready var base_image: TextureRect = $PreviewContainer/BaseImage
@onready var dirt_image: TextureRect = $PreviewContainer/DirtImage
@onready var puzzle_image: TextureRect = $PreviewContainer/PuzzleImage

var item_data: ItemData


func setup(data: ItemData) -> void:
	item_data = data
	text = data.item_name
	tooltip_text = data.item_name
	_update_preview()



func _update_preview() -> void:
	if item_data == null:
		return

	base_image.texture = null
	dirt_image.texture = null
	puzzle_image.texture = null

	if item_data.needs_puzzling:
		puzzle_image.texture = item_data.unfinished_puzzle
		return

	if item_data.needs_punding:
		base_image.texture = item_data.closed_texture
	else:
		base_image.texture = item_data.final_sprite

	if item_data.needs_cleaning:
		dirt_image.texture = item_data.dirt_texture



func _ready() -> void:
	pressed.connect(_on_pressed)

	if item_data != null:
		_update_preview()
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
