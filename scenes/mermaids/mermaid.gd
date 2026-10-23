extends Node


signal mermaid_capped_corruption(mermaid_id: int)

@export var mermaid_id: int = 0
@export var mermaid_name: String
@export var mermaid_full_body: Texture2D
@export var mermaid_head_shot: Texture2D
@export_multiline var mermaid_description: String
@export var alive: bool = true
@export var recruited: bool = false

@export_range(0, 100) var corruption_increase_per_increment: float = 0

var _is_exploring: bool = false

#region save/load
func save() -> MermaidSaveData:
	return MermaidSaveData.new(mermaid_id, alive, recruited, _is_exploring, $Stats.get_corruption())


func load_data(data: MermaidSaveData):
	if mermaid_id != data.get_mermaid_id():
		return
	
	alive = data.is_alive()
	recruited = data.is_recruited()
	_is_exploring = data.is_exploring()
	if !alive || recruited:
		$Stats.set_corruption(data.get_corruption())
#endregion

#region getter/setter
func set_mermaid_exploring(is_exploring_val: bool):
	_is_exploring = is_exploring_val
	if !_is_exploring and $Stats.get_corruption() >= 100.0:
		alive = false
		mermaid_capped_corruption.emit(mermaid_id)


func is_exploring() -> bool:
	return _is_exploring


func assign_item(item: Node):
	item.reparent($Items)


func get_item_count() -> int:
	return $Items.get_children().size()


func get_items() -> Array[Node]:
	return $Items.get_children()


func get_calculated_stats() -> Dictionary:
	var output = $Stats.get_stats_as_dictionary()
	var items = $Items.get_children()
	for item in items:
		output = item.calculate_stats_from_dictionary(output)
	return output


#endregion

func increment_progress():
	$Stats.add_corruption(corruption_increase_per_increment)
	if _is_exploring:
		return
	if $Stats.get_corruption() >= 100:
		alive = false
		mermaid_capped_corruption.emit(mermaid_id)
