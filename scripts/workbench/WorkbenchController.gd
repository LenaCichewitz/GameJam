
extends Control

@export var available_items: Array[ItemData] = []

@onready var item_bar: HBoxContainer = $MainLayout/ItemBar
@onready var target_box = $MainLayout/WorkArea/TargetBox

const CLEANING_MODE_SCENE: PackedScene = preload(
    "res://scenes/restorations/cleaning/cleaning_mode.tscn"
)

@onready var restoration_container: Control = $restoration_container
@onready var toolbox: Control = $toolbox

var active_restoration_mode: Control = null

var item_slot_scene: PackedScene = preload(
    "res://scenes/workbench/ItemSlot.tscn"
)


func _ready() -> void:
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
	target_box.connect("item_dropped", _on_item_dropped)

func _on_item_selected(data: ItemData) -> void:
	target_box.call("display_item", data)


func open_cleaning_mode(data: ItemData) -> void:
	if data == null or not data.needs_cleaning:
		return

	if active_restoration_mode != null:
		toolbox.tool_drag_started.disconnect(
			active_restoration_mode.on_tool_drag_started
		)
		toolbox.tool_drag_moved.disconnect(
			active_restoration_mode.on_tool_drag_moved
		)
		toolbox.tool_drag_ended.disconnect(
			active_restoration_mode.on_tool_drag_ended
		)
		active_restoration_mode.queue_free()

	active_restoration_mode = CLEANING_MODE_SCENE.instantiate()
	restoration_container.add_child(active_restoration_mode)

	toolbox.tool_drag_started.connect(
		active_restoration_mode.on_tool_drag_started
	)
	toolbox.tool_drag_moved.connect(
		active_restoration_mode.on_tool_drag_moved
	)
	toolbox.tool_drag_ended.connect(
		active_restoration_mode.on_tool_drag_ended
	)

	restoration_container.visible = true
	toolbox.visible = true

	active_restoration_mode.set_anchors_and_offsets_preset(
		Control.PRESET_TOP_LEFT
	)

	active_restoration_mode.position = (
		target_box.get_global_rect().position
		- restoration_container.global_position
	)
	active_restoration_mode.size = target_box.size

	active_restoration_mode.call_deferred("start_cleaning", data)




func _on_item_dropped(data: ItemData) -> void:
	if data.needs_cleaning:
		open_cleaning_mode(data)
