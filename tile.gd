class_name Tile
extends Node2D

var tile_id: int
var tile_type: int  # 1, 2, or 3 (determines both size and color)

const CELL_SIZE = 100
const COLORS = {
	1: Color.CYAN,
	2: Color.BLUE, 
	3: Color.DARK_BLUE
}

@onready var background: ColorRect

func _ready():
	# Create the visual background
	background = ColorRect.new()
	background.position = Vector2(-CELL_SIZE/2, -CELL_SIZE/2)
	add_child(background)
	
	update_visual()

func setup(id: int, type: int):
	tile_id = id
	tile_type = type
	
	if background:
		update_visual()

func update_visual():
	if not background:
		return
		
	# Size is based on type (type=2 means 2x1)
	var grid_size = Vector2i(tile_type, 1)
	var pixel_size = Vector2(grid_size.x * CELL_SIZE, grid_size.y * CELL_SIZE)
	
	background.size = pixel_size
	background.position = -pixel_size / 2
	
	# Color is based on type
	if COLORS.has(tile_type):
		background.color = COLORS[tile_type]
