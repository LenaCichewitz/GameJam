extends Node


@export var mermaid_id: int = 0
@export var mermaid_name: String
@export var alive: bool = true
@export var recruited: bool = false

#region save/load
func save() -> MermaidSaveData:
	return MermaidSaveData.new(mermaid_id, alive, recruited, $Stats.darkness)


func load(data: MermaidSaveData):
	if mermaid_id != data.get_mermaid_id():
		return
	
	alive = data.is_alive()
	recruited = data.is_recruited()
	if !alive || recruited:
		$Stats.darkness = data.get_darkness()
#endregion
