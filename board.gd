class_name Board
extends Node2D

var grid_state: GridState
var visual_tiles: Dictionary  # tile_id -> Tile node

const CELL_SIZE = 100
const GRID_OFFSET = Vector2(50, 50)  # Where grid starts on screen

func _ready():
    grid_state = GridState.new()
    visual_tiles = {}
    
    # Spawn a couple test tiles
    spawn_tile(1)
    spawn_tile(2)

func spawn_tile(tile_type: int):
    # Find empty spots that can fit this tile size
    var possible_positions = []
    var tile_size = Vector2i(tile_type, 1)
    
    for y in GridState.GRID_HEIGHT:
        for x in GridState.GRID_WIDTH:
            var pos = Vector2i(x, y)
            if grid_state.can_place_tile(pos, tile_size):
                possible_positions.append(pos)
    
    if possible_positions.is_empty():
        print("No space for new tile!")
        return
    
    # Pick random valid position
    var grid_pos = possible_positions[randi() % possible_positions.size()]
    
    # Add to logic
    var tile_id = grid_state.place_tile(grid_pos, tile_size)
    
    # Create visual
    var tile = Tile.new()
    tile.setup(tile_id, tile_type)
    tile.position = grid_to_world_position(grid_pos)
    add_child(tile)
    
    # Track it
    visual_tiles[tile_id] = tile

func grid_to_world_position(grid_pos: Vector2i) -> Vector2:
    return GRID_OFFSET + Vector2(grid_pos.x * CELL_SIZE, grid_pos.y * CELL_SIZE)

func _input(event: InputEvent):
    var movements = {}
    if event.is_action_pressed("ui_left"):
        movements = grid_state.slide(GridState.Direction.LEFT)
        animate_movements(movements)
    elif event.is_action_pressed("ui_right"):
        movements = grid_state.slide(GridState.Direction.RIGHT)
        animate_movements(movements)
    elif event.is_action_pressed("ui_up"):
        movements = grid_state.slide(GridState.Direction.UP)
        animate_movements(movements)
    elif event.is_action_pressed("ui_down"):
        movements = grid_state.slide(GridState.Direction.DOWN)
        animate_movements(movements)
    if not movements.is_empty():  # Only spawn if tiles actually moved
        spawn_tile(randi_range(1, 3))  # Spawn random tile type


func animate_movements(movements: Dictionary):
    for tile_id in movements:
        var movement = movements[tile_id]
        var visual_tile = visual_tiles[tile_id]
        var new_world_pos = grid_to_world_position(movement.new)
        
        var tween = create_tween()
        tween.tween_property(visual_tile, "position", new_world_pos, 0.2)
