@tool
class_name Board
extends Node2D

@export var game_theme: GameTheme

var grid_state: GridState
var visual_tiles: Dictionary

func _ready():
    grid_state = GridState.new()
    visual_tiles = {}

    apply_board_theme()
    spawn_tile(1)
    spawn_tile(2)

func apply_board_theme():
    print("apply_board_theme called")
    print("game_theme.board_background_scene: ", game_theme.board_background_scene)
    
    # Add the board visual scene as background
    if game_theme.board_background_scene:
        print("Creating board background instance")
        var board_visual = game_theme.board_background_scene.instantiate()
        print("Board visual created: ", board_visual)
        add_child(board_visual)
        print("Board visual added as child")
        move_child(board_visual, 0)  # Behind tiles
    else:
        print("No board_background_scene found!")

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
    var tile = game_theme.tile_scene.instantiate()
    
    # Scale tile based on theme tile_size
    var scale_factor = game_theme.tile_size / 100.0  # Assuming tile scene is 100x100
    tile.scale = Vector2(tile_type * scale_factor, scale_factor)
    
    tile.position = grid_to_world_position(grid_pos, Vector2i(tile_type, 1))
    add_child(tile)
    
    # Track it
    visual_tiles[tile_id] = tile

func grid_to_world_position(grid_pos: Vector2i, tile_size: Vector2i = Vector2i(1,1)) -> Vector2:
    var cell_width = 400.0 / GridState.GRID_WIDTH   
    var cell_height = 400.0 / GridState.GRID_HEIGHT 
    
    # Calculate the center of the tile's occupied area
    var tile_center_offset_x = (tile_size.x - 1) * cell_width / 2.0
    var tile_center_offset_y = (tile_size.y - 1) * cell_height / 2.0
    
    var start_x = -200.0 + cell_width / 2.0   
    var start_y = -200.0 + cell_height / 2.0  
    
    return Vector2(
        start_x + grid_pos.x * cell_width + tile_center_offset_x,
        start_y + grid_pos.y * cell_height + tile_center_offset_y
    )

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
