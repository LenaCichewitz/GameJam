
extends Node2D

var current_item: ItemData
var pieces_container: Node2D
var preview_sprite: Sprite2D

var piece_sprites: Array[Sprite2D] = []
var dragging_piece: Sprite2D = null
var drag_offset: Vector2 = Vector2.ZERO

var gluing_mode: bool = false
var glued_pieces: Array[Sprite2D] = []

var preview_scale: float = 1.0
var preview_position: Vector2 = Vector2.ZERO
var pieces_in_place: int = 0
signal puzzling_finished(data: ItemData)

@onready var completion_popup: AcceptDialog = $puzzle_complete

func _ready() -> void:
	pieces_container = $pieces_container
	completion_popup.confirmed.connect(_on_completion_confirmed)
	completion_popup.dialog_text = "PUZZLE DONE!"

func start_puzzling(data: ItemData) -> void:
	if data == null:
		return
	pieces_in_place = 0
	current_item = data
	show()
	pieces_container.show()
	_clear_pieces()
	_setup_preview()
	completion_popup.hide()
	for i in range(current_item.puzzle_pieces.size()):
		var texture: Texture2D = current_item.puzzle_pieces[i]

		if texture == null:
			continue

		var piece := Sprite2D.new()
		piece.texture = texture
		piece.position = _get_random_start_position()
		piece.scale = Vector2.ONE * preview_scale
		piece.z_index = i + 1
		#piece.z_index = 1 if i == 1 else 0
		piece.set_meta("piece_index", i)

		pieces_container.add_child(piece)
		print(
			"Puzzle-Teil hinzugefügt: ",
			piece.texture,
			" | sichtbar: ",
			piece.is_visible_in_tree(),
			" | Position: ",
			piece.position
		)
		piece_sprites.append(piece)


func _setup_preview() -> void:
	if preview_sprite != null:
		preview_sprite.queue_free()

	preview_sprite = Sprite2D.new()
	preview_sprite.texture = current_item.final_sprite
	preview_sprite.modulate = Color(1.0, 1.0, 1.0, 0.25)
	preview_sprite.z_index = 0

	var image_size := current_item.final_sprite.get_size()
	var available_size := get_viewport_rect().size * 0.6

	preview_scale = min(
		available_size.x / image_size.x,
		available_size.y / image_size.y
	)

	preview_position = get_viewport_rect().size / 2.0

	preview_sprite.position = preview_position
	preview_sprite.scale = Vector2.ONE * preview_scale

	pieces_container.add_child(preview_sprite)
	pieces_container.move_child(preview_sprite, 0)


func _get_target_position(_index: int) -> Vector2:
	if not is_instance_valid(preview_sprite):
		return Vector2.ZERO

	return preview_sprite.position

#func _get_target_position(index: int) -> Vector2:
	#if not is_instance_valid(preview_sprite):
		#return Vector2.ZERO
#
	## Sichtbare Bounding Boxes in den Einzeltexturen.
	## Reihenfolge: 0 = Klinge, 1 = Griff.
	#var source_boxes: Array[Rect2] = [
		#Rect2(127, 152, 237, 47),
		#Rect2(146, 119, 196, 103)
	#]
#
	## Sichtbare Bounding Boxes in der Vorlage.
	#var target_boxes: Array[Rect2] = [
		#Rect2(67, 135, 371, 65),
		#Rect2(146, 96, 198, 91)
	#]
#
	#if index < 0 or index >= source_boxes.size():
		#return preview_sprite.position
#
	#var source_center: Vector2 = (
		#source_boxes[index].position
		#+ source_boxes[index].size / 2.0
	#)
#
	#var target_center: Vector2 = (
		#target_boxes[index].position
		#+ target_boxes[index].size / 2.0
	#)
#
	#return preview_sprite.position + (
		#target_center - source_center
	#) * preview_scale


#func _get_target_position(_index: int) -> Vector2:
	#if not is_instance_valid(preview_sprite):
		#return Vector2.ZERO
#
	#return preview_sprite.position
	
	#if current_item == null:
		#return Vector2.ZERO
#
	#if index < 0 or index >= current_item.puzzle_target_positions.size():
		#return preview_sprite.position
#
	#var image_size: Vector2 = current_item.final_sprite.get_size()
	#var image_position: Vector2 = current_item.puzzle_target_positions[index]
#
	#return preview_sprite.position + (
		#image_position - image_size / 2.0
	#) * preview_scale

func _get_random_start_position() -> Vector2:
	var viewport_size := get_viewport_rect().size
	var margin := 150.0

	return Vector2(
		randf_range(margin, viewport_size.x - margin),
		randf_range(margin, viewport_size.y - margin)
	)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if gluing_mode:
				_glue_piece_at_position(get_global_mouse_position())
				get_viewport().set_input_as_handled()
				return
			if event.pressed:
				_start_drag()
			else:
				_finish_drag()
				get_viewport().set_input_as_handled()

	elif event is InputEventMouseMotion and dragging_piece != null:
		dragging_piece.global_position = (
			get_global_mouse_position() + drag_offset
		)
		get_viewport().set_input_as_handled()


func _start_drag() -> void:
	var mouse_position := get_global_mouse_position()

	for i in range(piece_sprites.size() - 1, -1, -1):
		var piece := piece_sprites[i]

		if not is_instance_valid(piece):
			continue
		if piece.get_meta("placed", false):
			continue
		if piece.texture == null:
			continue

		var local_mouse := piece.to_local(mouse_position)
		var rect := Rect2(
			-piece.texture.get_size() / 2.0,
			piece.texture.get_size()
		)

		if rect.has_point(local_mouse):
			dragging_piece = piece
			drag_offset = piece.global_position - mouse_position
			return


func _finish_drag() -> void:
	if dragging_piece == null:
		return

	if current_item != null and dragging_piece.has_meta("piece_index"):
		var index: int = dragging_piece.get_meta("piece_index")
		print("Teil ", index, " aktuelle Position: ", dragging_piece.position)
		
		var target_position := _get_target_position(index)
		var distance := dragging_piece.position.distance_to(target_position)

		if distance <= 40.0:
			dragging_piece.position = target_position
			dragging_piece.set_meta("placed", true)
			pieces_in_place += 1

	if pieces_in_place == piece_sprites.size():
		completion_popup.popup_centered()

	dragging_piece = null

func _on_completion_confirmed() -> void:
	if current_item == null:
		return

	gluing_mode = true
	glued_pieces.clear()
	

func _glue_piece_at_position(mouse_position: Vector2) -> void:
	if not gluing_mode:
		return

	for i in range(piece_sprites.size() - 1, -1, -1):
		var piece: Sprite2D = piece_sprites[i]

		if not is_instance_valid(piece):
			continue
		if not piece.get_meta("placed", false):
			continue
		if glued_pieces.has(piece):
			continue
		if piece.texture == null:
			continue

		var local_mouse := piece.to_local(mouse_position)
		var texture_size := piece.texture.get_size()
		var pixel_position := local_mouse + texture_size / 2.0

		var pixel_x := int(floor(pixel_position.x))
		var pixel_y := int(floor(pixel_position.y))

		if pixel_x < 0 or pixel_y < 0:
			continue
		if pixel_x >= texture_size.x or pixel_y >= texture_size.y:
			continue

		var image := piece.texture.get_image()
		if image == null:
			continue

		if image.get_pixel(pixel_x, pixel_y).a <= 0.1:
			continue

		glued_pieces.append(piece)
		piece.modulate = Color(0.7, 1.0, 0.7, 1.0)

		print(
			"Geklebt: ",
			glued_pieces.size(),
			" / ",
			piece_sprites.size()
		)

		if glued_pieces.size() == piece_sprites.size():
			_finish_gluing()

		return


func _finish_gluing() -> void:
	print("FINISH GLUING AUFGERUFEN!")
	print("Geklebte Teile: ", glued_pieces.size())
	print("Puzzle-Teile gesamt: ", piece_sprites.size())

	if current_item == null:
		return

	current_item.needs_puzzling = false
	puzzling_finished.emit(current_item)
	queue_free()


func _clear_pieces() -> void:
	for piece in piece_sprites:
		if is_instance_valid(piece):
			piece.queue_free()

	piece_sprites.clear()
	dragging_piece = null

	if preview_sprite != null:
		preview_sprite.queue_free()
		preview_sprite = null
