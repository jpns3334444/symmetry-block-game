@tool
extends Resource
class_name GameTheme

@export var theme_name: String = "Default"
@export var tile_scene: PackedScene
@export var board_background_scene: PackedScene
@export var placeholder_scene: PackedScene
@export var ui_theme: Theme
@export var particle_effects: Dictionary = {}
@export var sound_effects: Dictionary = {}
@export var game_settings: Dictionary = {}
@export var cell_size: int = 100
@export var tile_size: int = 90  # Add this line
@export var board_size: Vector2i = Vector2i(400, 400)
