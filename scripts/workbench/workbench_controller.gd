
extends Control

@export var available_items: Array[ItemData] = []

@onready var item_bar: HBoxContainer = $MainLayout/ItemBar
@onready var target_box = $MainLayout/WorkArea/TargetBox

var selected_tool: ToolData = null
var pounding_hits: Dictionary = {}

const CLEANING_MODE_SCENE: PackedScene = preload(
    "res://scenes/restorations/cleaning/cleaning_mode.tscn"
)
const PUZZLING_MODE_SCENE = preload(
    "res://scenes/restorations/puzzling/puzzling_mode.tscn"
)

@onready var restoration_container: Control = $restoration_container
@onready var toolbox: Control = $toolbox

var active_restoration_mode: Control = null

var item_slot_scene: PackedScene = preload(
    "res://scenes/workbench/item_slot.tscn"
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
	target_box.item_clicked.connect(_on_target_item_clicked)
	toolbox.tool_drag_started.connect(_on_tool_selected)

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
	item_bar.visible = false
	if data.needs_puzzling:
		open_puzzling_mode(data)
	if data.needs_cleaning:
		open_cleaning_mode(data)


func open_puzzling_mode(data: ItemData)-> void: 
	var puzzling_mode = PUZZLING_MODE_SCENE.instantiate()
	
	restoration_container.show()
	restoration_container.add_child(puzzling_mode)
	puzzling_mode.puzzling_finished.connect(_on_puzzling_finished)
	target_box.hide_item()
	puzzling_mode.start_puzzling(data) 
	
func _on_puzzling_finished(data: ItemData) -> void:
	target_box.display_item(data)
	item_bar.show()	
	
func _on_exit_button_pressed() -> void:
	pass #TODO: show manager_root again 
	
func _on_tool_selected(tool_data: ToolData, _position: Vector2) -> void:
	selected_tool = tool_data

func _on_target_item_clicked(data: ItemData) -> void:
	if selected_tool == null or selected_tool.tool_id != "hammer":
		return

	if not data.needs_punding:
		return

	var item_key := data.get_instance_id()
	var hits: int = pounding_hits.get(item_key, 0) + 1
	pounding_hits[item_key] = hits

	print("Pundings", hits, " / ", data.required_pounding_hits)

	if hits >= data.required_pounding_hits:
		data.needs_punding = false
		target_box.finish_pounding()
		pounding_hits.erase(item_key)
		print("Removed Shell", data.item_name)


func _on_item_button_pressed() -> void:
	if item_bar.visible ==false:
		item_bar.visible = true
	else:
		item_bar.visible = false
