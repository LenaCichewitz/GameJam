
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
var active_cleaning_mode: Control = null
var active_restoration_mode: Node = null
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
	print("OPEN CLEANING MODE AUFGERUFEN")

	if data == null or not data.needs_cleaning:
		print("Reinigung übersprungen: Item null oder bereits sauber")
		return
	if active_restoration_mode != null:
		if active_cleaning_mode != null:
			if toolbox.tool_drag_started.is_connected(
				active_cleaning_mode.on_tool_drag_started
			):
				toolbox.tool_drag_started.disconnect(
					active_cleaning_mode.on_tool_drag_started
				)

			if toolbox.tool_drag_moved.is_connected(
				active_cleaning_mode.on_tool_drag_moved
			):
				toolbox.tool_drag_moved.disconnect(
					active_cleaning_mode.on_tool_drag_moved
				)

			if toolbox.tool_drag_ended.is_connected(
				active_cleaning_mode.on_tool_drag_ended
			):
				toolbox.tool_drag_ended.disconnect(
					active_cleaning_mode.on_tool_drag_ended
				)

		active_restoration_mode.queue_free()
		active_restoration_mode = null
		active_cleaning_mode = null

	active_cleaning_mode = CLEANING_MODE_SCENE.instantiate()
	active_restoration_mode = active_cleaning_mode
	restoration_container.add_child(active_cleaning_mode)

	toolbox.tool_drag_started.connect(
		active_cleaning_mode.on_tool_drag_started
	)
	toolbox.tool_drag_moved.connect(
		active_cleaning_mode.on_tool_drag_moved
	)
	toolbox.tool_drag_ended.connect(
		active_cleaning_mode.on_tool_drag_ended
	)

	restoration_container.visible = true
	toolbox.visible = true

	active_cleaning_mode.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	active_cleaning_mode.position = Vector2.ZERO
	active_cleaning_mode.size = restoration_container.size
	print("Restoration-Container Größe: ", restoration_container.size)
	print("Reinigungsmodus Größe: ", active_cleaning_mode.size)
	print("Dirt Texture vor Start: ", data.dirt_texture)
	active_cleaning_mode.call_deferred("start_cleaning", data)




func _on_item_dropped(data: ItemData) -> void:
	item_bar.visible = false
	if data.needs_puzzling:
		open_puzzling_mode(data)
	#if data.needs_puzzling and data.needs_cleaning:
		#open_puzzling_mode(data)
	elif data.needs_cleaning:
		open_cleaning_mode(data)


func open_puzzling_mode(data: ItemData) -> void:
	if data == null:
		return

	if active_restoration_mode != null:
		if active_cleaning_mode != null:
			active_restoration_mode.queue_free()
			active_restoration_mode = null
			active_cleaning_mode = null
		else:
			active_restoration_mode.queue_free()
			active_restoration_mode = null

	var puzzling_mode = PUZZLING_MODE_SCENE.instantiate()
	active_restoration_mode = puzzling_mode

	restoration_container.show()
	restoration_container.add_child(puzzling_mode)

	puzzling_mode.puzzling_finished.connect(
		_on_puzzling_finished
	)

	target_box.hide_item()
	puzzling_mode.start_puzzling(data)
	print("Puzzle-Modus sichtbar: ", puzzling_mode.is_visible_in_tree())
	print("Reinigungsmodus aktiv: ", active_cleaning_mode != null)
	print("Restoration-Container: ", restoration_container.get_children())
	

func _on_puzzling_finished(data: ItemData) -> void:
	if data == null:
		return

	active_restoration_mode = null
	active_cleaning_mode = null

	_restore_item_after_puzzling.call_deferred(data)


func _restore_item_after_puzzling(data: ItemData) -> void:
	if data == null:
		return

	target_box.display_item(data)
	target_box.show_item()
	target_box.visible = true
	#restoration_container.hide()


	print("TargetBox sichtbar: ", target_box.is_visible_in_tree())
	print("ItemPreview sichtbar: ", target_box.item_preview.is_visible_in_tree())
	print("ItemPreview Größe: ", target_box.item_preview.size)
	print("ItemPreview Textur: ", target_box.item_preview.texture)
	print("TargetBox Größe: ", target_box.size)

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
