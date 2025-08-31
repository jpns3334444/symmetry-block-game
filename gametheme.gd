@tool
extends Resource
class_name GameTheme

@export var theme_name: String = "Default"
@export var tile_scene: PackedScene
@export var board_background_scene: PackedScene
@export var placeholder_scene: PackedScene
@export var ui_theme: Theme  # For buttons, labels, etc.
@export var particle_effects: Dictionary = {}  # Match effects, etc.
@export var sound_effects: Dictionary = {}     # Audio theming
@export var game_settings: Dictionary = {}     # Gameplay tweaks per theme
@export var cell_size: int = 1
