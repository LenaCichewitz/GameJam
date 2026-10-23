
extends Control

@onready var dirt_layer: TextureRect = $dirt_layer
@onready var completion_popup: AcceptDialog = $completion_popup

var current_item: ItemData
var dirt_image: Image
var dirt_image_texture: ImageTexture

var total_dirt_pixels: int = 0
var removed_dirt_pixels: int = 0
var brush_radius: int = 22
var cleaning_finished: bool = false
var is_tool_dragging: bool = false


func on_tool_drag_started(
	tool_data: ToolData,
	_global_position: Vector2
) -> void:
	is_tool_dragging = true


func on_tool_drag_moved(
	tool_data: ToolData,
	global_position: Vector2
) -> void:

	if not is_tool_dragging:
		return
	if tool_data == null:
		return
	if tool_data.tool_id != "sponge":
		return

	var local_position := (
		dirt_layer.get_global_transform().affine_inverse()
		* global_position
	)
	_clean_at_position(local_position)


func on_tool_drag_ended(
	_tool_data: ToolData,
	_global_position: Vector2
) -> void:
	is_tool_dragging = false

func _ready() -> void:

	dirt_layer.mouse_filter = Control.MOUSE_FILTER_STOP

	completion_popup.dialog_text = "CLEAN!"


func start_cleaning(data: ItemData) -> void:
	if data == null:
		return

	current_item = data
	cleaning_finished = false
	removed_dirt_pixels = 0
	total_dirt_pixels = 0


	dirt_image = data.dirt_texture.get_image()

	for y in range(dirt_image.get_height()):
		for x in range(dirt_image.get_width()):
			if dirt_image.get_pixel(x, y).a > 0.0:
				total_dirt_pixels += 1

	if total_dirt_pixels == 0:
		finish_cleaning()
		return

	dirt_image_texture = ImageTexture.create_from_image(dirt_image)
	dirt_layer.texture = dirt_image_texture

	completion_popup.hide()

func _clean_at_position(position: Vector2) -> void:
	if dirt_layer.size.x <= 0.0 or dirt_layer.size.y <= 0.0:
		return

	var pixel_x := int(position.x / dirt_layer.size.x * dirt_image.get_width())
	var pixel_y := int(position.y / dirt_layer.size.y * dirt_image.get_height())

	var radius := brush_radius

	for y in range(maxi(0, pixel_y - radius),
			mini(dirt_image.get_height(), pixel_y + radius + 1)):
		for x in range(maxi(0, pixel_x - radius),
				mini(dirt_image.get_width(), pixel_x + radius + 1)):

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
