
extends Button

# Gibt das nicht Probleme? Die selben Signale werden auch in toolbox genutzt
signal tool_drag_started(tool_data: ToolData, global_position: Vector2)
signal tool_drag_moved(tool_data: ToolData, global_position: Vector2)
signal tool_drag_ended(tool_data: ToolData, global_position: Vector2)

var tool_data: ToolData
var is_dragging: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

func setup(data: ToolData) -> void:
	tool_data = data
	tooltip_text = data.tool_name
	flat = true
	
	var icon_node := get_node("tool_icon") as TextureRect
	icon_node.texture = data.tool_icon
	icon_node.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _input(event: InputEvent) -> void:
	if tool_data == null:
		return

	if event is InputEventMouseButton:
		if event.button_index != MOUSE_BUTTON_LEFT:
			return

		if event.pressed:
			var mouse_position := get_global_mouse_position()

			if get_global_rect().has_point(mouse_position):
				is_dragging = true
				tool_drag_started.emit(tool_data, mouse_position)
		elif is_dragging:
			is_dragging = false
			tool_drag_ended.emit(
				tool_data,
				get_global_mouse_position()
			)

	elif event is InputEventMouseMotion and is_dragging:
		tool_drag_moved.emit(
			tool_data,
			get_global_mouse_position()
		)
