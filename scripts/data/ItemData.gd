class_name ItemData
extends Resource

@export var item_name: String = "perle"
@export var final_sprite: Texture2D

@export_group("Tasks")
@export var needs_cleaning: bool = true
@export var dirt_texture: Texture2D 

@export var needs_puzzling: bool = false
@export var puzzle_pieces: Array[Texture2D] = []

@export var needs_punding: bool = true
@export var closed_texture: Texture2D 
