
extends Control

@onready var dirt_layer: TextureRect = $dirt_layer
@onready var completion_popup: AcceptDialog = $completion_popup
@onready var item_layer: TextureRect = $item_layer

var current_item: ItemData
var dirt_image: Image
var dirt_image_texture: ImageTexture

var total_dirt_pixels: int = 0
var removed_dirt_pixels: int = 0
var brush_radius: int = 22
var cleaning_finished: bool = false
var is_tool_dragging: bool = false


func _ready() -> void:
	dirt_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	dirt_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	dirt_layer.offset_left = 0
	dirt_layer.offset_top = 0
	dirt_layer.offset_right = 0
	dirt_layer.offset_bottom = 0

	dirt_layer.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	dirt_layer.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	completion_popup.dialog_text = "CLEAN!"


func on_tool_drag_started(
	_tool_data: ToolData,
	_global_position: Vector2
) -> void:
	is_tool_dragging = true


func on_tool_drag_moved(
	tool_data: ToolData,
	drag_global_position: Vector2
) -> void:
	if not is_tool_dragging:
		return

	if tool_data == null:
		return

	if tool_data.tool_id != "sponge":
		return

	if dirt_image == null or dirt_image_texture == null:
		return

	var local_position: Vector2 = (
		dirt_layer.get_global_transform().affine_inverse()
		* drag_global_position
	)
	print("Werkzeug bewegt: ", tool_data.tool_id, " | Position: ", local_position)
	_clean_at_position(local_position)


func on_tool_drag_ended(
	_tool_data: ToolData,
	_global_position: Vector2
) -> void:
	is_tool_dragging = false


func start_cleaning(data: ItemData) -> void:
	print("Uncleaned Sprite: ", item_layer.texture)
	print("Dirt Layer Stretch: ", dirt_layer.stretch_mode)

	if data == null:
		push_warning("Kein Item zum Reinigen.")
		return

	if data.dirt_texture == null:
		push_warning("Keine Schmutztextur zugewiesen.")
		return
	print("Dirt Texture: ", data.dirt_texture)
	current_item = data
	cleaning_finished = false
	is_tool_dragging = false
	removed_dirt_pixels = 0
	total_dirt_pixels = 0

	# Das ungereinigte Grundbild anzeigen.
	if data.uncleaned_sprite != null:
		item_layer.texture = data.uncleaned_sprite
	else:
		item_layer.texture = data.final_sprite

	# Schmutztextur für das Entfernen vorbereiten.
	dirt_image = data.dirt_texture.get_image()

	for y in range(dirt_image.get_height()):
		for x in range(dirt_image.get_width()):
			if dirt_image.get_pixel(x, y).a > 0.0:
				total_dirt_pixels += 1

	dirt_image_texture = ImageTexture.create_from_image(dirt_image)
	dirt_layer.texture = dirt_image_texture

	completion_popup.hide()

	if total_dirt_pixels == 0:
		finish_cleaning()
		
	print("Uncleaned Sprite: ", item_layer.texture)
	print("Dirt Texture: ", current_item.dirt_texture)
	print("Dirt Image Größe: ", dirt_image.get_size())
	print("Dirt Layer Größe: ", dirt_layer.size)
	print("Dirt Pixel mit Alpha: ", total_dirt_pixels)

func _clean_at_position(drag_position: Vector2) -> void:
	print("Reinigungsposition: ", drag_position, " | Dirt Layer: ", dirt_layer.size)
	if dirt_image == null or dirt_image_texture == null:
		return

	if dirt_layer.size.x <= 0.0 or dirt_layer.size.y <= 0.0:
		return

	var texture_size := Vector2(
		dirt_image.get_width(),
		dirt_image.get_height()
	)
	var pixel_x := int(
		floor(drag_position.x / dirt_layer.size.x * texture_size.x)
	)
	var pixel_y := int(
		floor(drag_position.y / dirt_layer.size.y * texture_size.y)
	)

	if (
		pixel_x < 0
		or pixel_y < 0
		or pixel_x >= dirt_image.get_width()
		or pixel_y >= dirt_image.get_height()
	):
		return

	var radius := brush_radius

	for y in range(
		maxi(0, pixel_y - radius),
		mini(dirt_image.get_height(), pixel_y + radius + 1)
	):
		for x in range(
			maxi(0, pixel_x - radius),
			mini(dirt_image.get_width(), pixel_x + radius + 1)
		):
			var distance := Vector2(x - pixel_x, y - pixel_y).length()

			if distance > radius:
				continue

			var pixel := dirt_image.get_pixel(x, y)

			if pixel.a > 0.0:
				pixel.a = 0.0
				dirt_image.set_pixel(x, y, pixel)
				removed_dirt_pixels += 1

	dirt_image_texture.update(dirt_image)

	if removed_dirt_pixels >= total_dirt_pixels:
		finish_cleaning()


func finish_cleaning() -> void:
	if cleaning_finished:
		return

	cleaning_finished = true

	if current_item != null:
		current_item.needs_cleaning = false

	completion_popup.popup_centered()
