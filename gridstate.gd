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
    print("DEBUG: Placing tile ", tile_id, " at pos ", pos)
    var size = tiles[tile_id].size
    print("DEBUG: Tile size: ", size)
    print("DEBUG: Will loop y from ", pos.y, " to ", pos.y + size.y - 1)
    print("DEBUG: Will loop x from ", pos.x, " to ", pos.x + size.x - 1)
    
    tiles[tile_id].position = pos
    for y in range(pos.y, pos.y + size.y):
        for x in range(pos.x, pos.x + size.x):
            print("DEBUG: Setting grid[", y, "][", x, "] = ", tile_id)
            if y >= GRID_HEIGHT or x >= GRID_WIDTH:
                print("ERROR: Out of bounds! y=", y, " x=", x)
                return
            grid[y][x] = tile_id

enum Direction { LEFT, RIGHT, UP, DOWN }

func slide(direction: Direction) -> Dictionary:
    var movements = {}
    var is_horizontal = (direction == Direction.LEFT or direction == Direction.RIGHT)
    var toward_start = (direction == Direction.LEFT or direction == Direction.UP)
    
    var line_count = GRID_HEIGHT if is_horizontal else GRID_WIDTH
    
    for line in range(line_count):
        # Get tiles in this line
        var tiles_in_line = get_tiles_in_row(line) if is_horizontal else get_tiles_in_col(line)
        
        if toward_start:
            tiles_in_line.sort_custom(func(a, b):
                if is_horizontal:
                    return tiles[a].position.x < tiles[b].position.x
                else:
                    return tiles[a].position.y < tiles[b].position.y)
        else:
            tiles_in_line.sort_custom(func(a, b):
                if is_horizontal:
                    return tiles[a].position.x > tiles[b].position.x
                else:
                    return tiles[a].position.y > tiles[b].position.y)
        
        # Start position
        var next_pos = 0 if toward_start else (GRID_WIDTH - 1 if is_horizontal else GRID_HEIGHT - 1)
        
        for tile_id in tiles_in_line:
            var old_pos = tiles[tile_id].position
            var tile_size = tiles[tile_id].size
            
            # Calculate new position
            var new_pos: Vector2i
            if is_horizontal:
                var new_x = next_pos if toward_start else (next_pos - tile_size.x + 1)
                new_pos = Vector2i(new_x, line)
                next_pos += tile_size.x if toward_start else -tile_size.x
            else:
                var new_y = next_pos if toward_start else (next_pos - tile_size.y + 1)
                new_pos = Vector2i(line, new_y)
                next_pos += tile_size.y if toward_start else -tile_size.y
            
            # Move if position changed
            if old_pos != new_pos:
                clear_tile_from_grid(tile_id)
                place_tile_on_grid(tile_id, new_pos)
                movements[tile_id] = {"old": old_pos, "new": new_pos}
    
    return movements
