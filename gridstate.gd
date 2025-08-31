class_name GridState
extends RefCounted

const GRID_WIDTH = 4
const GRID_HEIGHT = 4

var grid: Array[Array] # grid[y][x] = tile_id or -1 for empty
var tiles: Dictionary # tile_id -> {position: Vector2i, size: Vector2i}
var next_tile_id: int = 0

func _init():
	# Initialize empty grid
	grid = []
	for y in GRID_HEIGHT:
		var row = []
		row.resize(GRID_WIDTH)
		row.fill(-1)  # -1 means empty
		grid.append(row)

func can_place_tile(pos: Vector2i, size: Vector2i) -> bool:
	# Check if rectangle is within bounds and all cells empty
	if pos.x + size.x > GRID_WIDTH or pos.y + size.y > GRID_HEIGHT:
		return false
	
	for y in range(pos.y, pos.y + size.y):
		for x in range(pos.x, pos.x + size.x):
			if grid[y][x] != -1:
				return false
	return true

func place_tile(pos: Vector2i, size: Vector2i) -> int:
	var tile_id = next_tile_id
	next_tile_id += 1
	
	# Mark grid cells as occupied
	for y in range(pos.y, pos.y + size.y):
		for x in range(pos.x, pos.x + size.x):
			grid[y][x] = tile_id
	
	tiles[tile_id] = {"position": pos, "size": size}
	return tile_id

func slide_line(tile_ids: Array, line_index: int, is_horizontal: bool, toward_zero: bool, movements: Dictionary):
	if tile_ids.is_empty():
		return

	# Sort tiles by position 
	if is_horizontal:
		if toward_zero:
			tile_ids.sort_custom(func(a, b): return tiles[a].position.x < tiles[b].position.x)
		else:
			tile_ids.sort_custom(func(a, b): return tiles[a].position.x > tiles[b].position.x)
	else:
		if toward_zero:
			tile_ids.sort_custom(func(a, b): return tiles[a].position.y < tiles[b].position.y)
		else:
			tile_ids.sort_custom(func(a, b): return tiles[a].position.y > tiles[b].position.y)
	
	# Calculate starting position and direction
	var target_pos: int
	var direction_multiplier: int
	
	if toward_zero:
		target_pos = 0
		direction_multiplier = 1
	else:
		if is_horizontal:
			target_pos = GRID_WIDTH - 1
			direction_multiplier = -1
		else:
			target_pos = GRID_HEIGHT - 1
			direction_multiplier = -1
	
	# Slide each tile
	for tile_id in tile_ids:
		var old_pos = tiles[tile_id].position
		var tile_size = tiles[tile_id].size
		var new_pos: Vector2i
		
		# Calculate new position
		if is_horizontal:
			if toward_zero:
				new_pos = Vector2i(target_pos, line_index)
				target_pos += tile_size.x
			else:
				new_pos = Vector2i(target_pos - tile_size.x + 1, line_index)
				target_pos -= tile_size.x
		else:
			if toward_zero:
				new_pos = Vector2i(line_index, target_pos)
				target_pos += tile_size.y
			else:
				new_pos = Vector2i(line_index, target_pos - tile_size.y + 1)
				target_pos -= tile_size.y
		
		# Move tile if position changed
		if old_pos != new_pos:
			clear_tile_from_grid(tile_id)
			place_tile_on_grid(tile_id, new_pos)
			movements[tile_id] = {"old": old_pos, "new": new_pos}

func get_tiles_in_row(row: int) -> Array:
	var result = []
	for tile_id in tiles:
		if tiles[tile_id].position.y == row:
			result.append(tile_id)
	return result

func get_tiles_in_col(col: int) -> Array:
	var result = []
	for tile_id in tiles:
		if tiles[tile_id].position.x == col:
			result.append(tile_id)
	return result

func remove_tile(tile_id: int):
	if not tiles.has(tile_id):
		return
		
	var tile = tiles[tile_id]
	# Clear grid cells
	for y in range(tile.position.y, tile.position.y + tile.size.y):
		for x in range(tile.position.x, tile.position.x + tile.size.x):
			grid[y][x] = -1
	
	tiles.erase(tile_id)

func clear_tile_from_grid(tile_id: int):
	var tile_data = tiles[tile_id]
	for y in range(tile_data.position.y, tile_data.position.y + tile_data.size.y):
		for x in range(tile_data.position.x, tile_data.position.x + tile_data.size.x):
			grid[y][x] = -1

func place_tile_on_grid(tile_id: int, pos: Vector2i):
	var size = tiles[tile_id].size
	tiles[tile_id].position = pos
	for y in range(pos.y, pos.y + size.y):
		for x in range(pos.x, pos.x + size.x):
			grid[y][x] = tile_id

enum Direction { LEFT, RIGHT, UP, DOWN }

func slide(direction: Direction) -> Dictionary:
	var movements = {}
	
	match direction:
		Direction.LEFT:
			for row in range(GRID_HEIGHT):
				slide_line(get_tiles_in_row(row), row, true, true, movements)
		Direction.RIGHT:
			for row in range(GRID_HEIGHT):
				slide_line(get_tiles_in_row(row), row, true, false, movements)
		Direction.UP:
			for col in range(GRID_WIDTH):
				slide_line(get_tiles_in_col(col), col, false, true, movements)
		Direction.DOWN:
			for col in range(GRID_WIDTH):
				slide_line(get_tiles_in_col(col), col, false, false, movements)
	
	return movements
