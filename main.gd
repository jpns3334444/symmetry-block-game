extends Node2D

func _ready():
	var board = $Board  # Reference the scene Board
	
	# Set its theme from ThemeManager
	board.game_theme = ThemeManager.get_current_theme()
