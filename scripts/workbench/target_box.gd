
extends PanelContainer

@onready var item_preview: TextureRect = $Content/ItemPreview
signal item_dropped(data: ItemData)

func display_item(data: ItemData) -> void:
	if data == null:
		return

	item_preview.texture = data.final_sprite


# Sieht so aus als ob "_at_position" nicht gebraucht wird?
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is ItemData

# Sieht so aus als ob "_at_position" nicht gebraucht wird?
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if data is ItemData:
		display_item(data)
		item_dropped.emit(data)
