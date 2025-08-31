class_name Tile
extends Node2D

var tile_id: int
var tile_type: int
var cell_size: int = 100

@onready var background: ColorRect

func _ready():
	background = ColorRect.new()
	add_child(background)
	update_visual()

func setup(id: int, type: int):
	tile_id = id
	tile_type = type
	if background:
		update_visual()

func apply_theme_data(theme_data: Dictionary):
	# Let themes override colors, sizes, etc. via data
	if theme_data.has("cell_size"):
		cell_size = theme_data.cell_size
	if theme_data.has("colors") and theme_data.colors.has(tile_type):
		background.color = theme_data.colors[tile_type]
	update_visual()

func update_visual():
	if not background:
		return
	var grid_size = Vector2i(tile_type, 1)
	var pixel_size = Vector2(grid_size.x * cell_size, grid_size.y * cell_size)
	background.size = pixel_size
	background.position = -pixel_size / 2
