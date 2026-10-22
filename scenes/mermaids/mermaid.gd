extends Node


signal mermaid_capped_corruption(mermaid_id: int)

@export var mermaid_id: int = 0
@export var mermaid_name: String
@export_multiline var mermaid_description: String
@export var alive: bool = true
@export var recruited: bool = false

@export_range(0, 100) var corruption_increase_per_increment: float = 0

#region save/load
func save() -> MermaidSaveData:
	return MermaidSaveData.new(mermaid_id, alive, recruited, $Stats.corruption)


func load(data: MermaidSaveData):
	if mermaid_id != data.get_mermaid_id():
		return
	
	alive = data.is_alive()
	recruited = data.is_recruited()
	if !alive || recruited:
		$Stats.corruption = data.get_corruption()
#endregion

func increment_progress():
	$Stats.corruption += corruption_increase_per_increment
	if $Stats.corruption >= 100:
		mermaid_capped_corruption.emit(mermaid_id)
