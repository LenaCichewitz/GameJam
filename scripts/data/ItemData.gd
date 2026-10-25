class_name ItemData
extends Resource

@export var item_id: int = 0
@export var item_name: String = "item_name"
@export var final_sprite: Texture2D
@export var item_restored: bool = true

@export_group("Tasks")
@export var needs_cleaning: bool = true
@export var dirt_texture: Texture2D 
@export var uncleaned_sprite: Texture2D

@export var needs_puzzling: bool = false
@export var puzzle_pieces: Array[Texture2D] = []
@export var puzzle_target_positions: Array[Vector2] = []
@export var unfinished_puzzle: Texture2D  

@export var needs_punding: bool = true
@export var closed_texture: Texture2D 
@export_range(1, 50, 1) var required_pounding_hits: int = 3

func is_fully_restored() -> bool:
	return (
		not needs_cleaning
		and not needs_puzzling
		and not needs_punding
	)
