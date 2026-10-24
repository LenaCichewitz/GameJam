
extends Control

signal tool_drag_started(tool_data: ToolData, drag_global_position: Vector2)
signal tool_drag_moved(tool_data: ToolData, drag_global_position: Vector2)
signal tool_drag_ended(tool_data: ToolData, drag_global_position: Vector2)

@export var available_tools: Array[ToolData] = []

@onready var tool_list: VBoxContainer = $tool_panel/tool_list

const TOOL_SLOT_SCENE: PackedScene = preload(
    "res://scenes/restorations/tools/tool_slot.tscn"
)



func _ready() -> void:
	for tool_data in available_tools:
		if tool_data == null:
			continue

		var tool_slot = TOOL_SLOT_SCENE.instantiate()
		tool_list.add_child(tool_slot)
		tool_slot.setup(tool_data)

		tool_slot.tool_drag_started.connect(_on_tool_drag_started)
		tool_slot.tool_drag_moved.connect(_on_tool_drag_moved)
		tool_slot.tool_drag_ended.connect(_on_tool_drag_ended)


func _on_tool_drag_started(
	tool_data: ToolData,
	drag_global_position: Vector2
) -> void:
	tool_drag_started.emit(tool_data, drag_global_position)


func _on_tool_drag_moved(
	tool_data: ToolData,
	drag_global_position: Vector2
) -> void:
	tool_drag_moved.emit(tool_data, drag_global_position)


func _on_tool_drag_ended(
	tool_data: ToolData,
	drag_global_position: Vector2
) -> void:
	tool_drag_ended.emit(tool_data, drag_global_position)
