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

func place_tile(pos: Vector2i, size: Vector2i) -> int:
    var tile_id = next_tile_id
    next_tile_id += 1
    
    # Mark grid cells as occupied
    for y in range(pos.y, pos.y + size.y):
        for x in range(pos.x, pos.x + size.x):
            grid[y][x] = tile_id
    
    tiles[tile_id] = {"position": pos, "size": size}
    return tile_id

func get_tiles_in_row(row: int) -> Array:
    var result = []
    for tile_id in tiles:
        var tile_data = tiles[tile_id]
        # Check if tile occupies any cell in this row
        var top = tile_data.position.y
        var bottom = tile_data.position.y + tile_data.size.y - 1
        if row >= top and row <= bottom:
            result.append(tile_id)
    return result

func get_tiles_in_col(col: int) -> Array:
    var result = []
    for tile_id in tiles:
        var tile_data = tiles[tile_id]
        # Check if tile occupies any cell in this column
        var left = tile_data.position.x
        var right = tile_data.position.x + tile_data.size.x - 1
        if col >= left and col <= right:
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
    if not tiles.has(tile_id):
        print("ERROR: Tile ", tile_id, " not found in tiles dictionary")
        return
    
    var size = tiles[tile_id].size
    
    # Validate bounds before placing
    if pos.x < 0 or pos.y < 0:
        print("ERROR: Negative position not allowed: ", pos)
        return
    
    if pos.x + size.x > GRID_WIDTH or pos.y + size.y > GRID_HEIGHT:
        print("ERROR: Tile would exceed grid bounds. Pos: ", pos, ", Size: ", size)
        return
    
    tiles[tile_id].position = pos
    for y in range(pos.y, pos.y + size.y):
        for x in range(pos.x, pos.x + size.x):
            grid[y][x] = tile_id

enum Direction { LEFT, RIGHT, UP, DOWN }

func slide(direction: Direction) -> Dictionary:
    var movements = {}
    
    # Clear all tiles from grid first
    for tile_id in tiles:
        clear_tile_from_grid(tile_id)
    
    # Create a sorted list of all tiles based on direction
    var sorted_tiles = tiles.keys()
    
    match direction:
        Direction.LEFT:
            sorted_tiles.sort_custom(func(a, b): 
                return tiles[a].position.x < tiles[b].position.x)
        Direction.RIGHT:
            sorted_tiles.sort_custom(func(a, b): 
                return tiles[a].position.x + tiles[a].size.x > tiles[b].position.x + tiles[b].size.x)
        Direction.UP:
            sorted_tiles.sort_custom(func(a, b): 
                return tiles[a].position.y < tiles[b].position.y)
        Direction.DOWN:
            sorted_tiles.sort_custom(func(a, b): 
                return tiles[a].position.y + tiles[a].size.y > tiles[b].position.y + tiles[b].size.y)
    
    # Move each tile as far as possible in the given direction
    for tile_id in sorted_tiles:
        var old_pos = tiles[tile_id].position
        var tile_size = tiles[tile_id].size
        var new_pos = old_pos
        
        match direction:
            Direction.LEFT:
                # Find leftmost valid position
                for x in range(old_pos.x - 1, -1, -1):
                    if can_place_tile(Vector2i(x, old_pos.y), tile_size, tile_id):
                        new_pos.x = x
                    else:
                        break
                        
            Direction.RIGHT:
                # Find rightmost valid position  
                for x in range(old_pos.x + 1, GRID_WIDTH - tile_size.x + 1):
                    if can_place_tile(Vector2i(x, old_pos.y), tile_size, tile_id):
                        new_pos.x = x
                    else:
                        break
                        
            Direction.UP:
                # Find topmost valid position
                for y in range(old_pos.y - 1, -1, -1):
                    if can_place_tile(Vector2i(old_pos.x, y), tile_size, tile_id):
                        new_pos.y = y
                    else:
                        break
                        
            Direction.DOWN:
                # Find bottommost valid position
                for y in range(old_pos.y + 1, GRID_HEIGHT - tile_size.y + 1):
                    if can_place_tile(Vector2i(old_pos.x, y), tile_size, tile_id):
                        new_pos.y = y
                    else:
                        break
        
        # Update position and track movement
        if old_pos != new_pos:
            tiles[tile_id].position = new_pos
            movements[tile_id] = {"old": old_pos, "new": new_pos}
        
        # Place tile at its position on the grid
        place_tile_on_grid(tile_id, tiles[tile_id].position)
    
    return movements

func can_place_tile(pos: Vector2i, size: Vector2i, exclude_tile_id: int = -1) -> bool:
    # Check if rectangle is within bounds and all cells empty
    if pos.x + size.x > GRID_WIDTH or pos.y + size.y > GRID_HEIGHT:
        return false
    
    for y in range(pos.y, pos.y + size.y):
        for x in range(pos.x, pos.x + size.x):
            if grid[y][x] != -1 and grid[y][x] != exclude_tile_id:
                return false
    return true
