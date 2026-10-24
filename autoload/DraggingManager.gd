# res://autoload/DraggingManager.gd
extends Node

var current_dragged_item: WorkbenchItem = null

func start_drag(item: WorkbenchItem) -> void:
	current_dragged_item = item

func stop_drag(item: WorkbenchItem) -> void:
	if current_dragged_item == item:
		# Signalisiere der Werkbank, dass ein Item abgelegt wurde
		var workbench = get_tree().get_first_node_in_group("workbench")
		if workbench and workbench.has_method("handle_item_dropped"):
			workbench.handle_item_dropped(item)
		current_dragged_item = null
