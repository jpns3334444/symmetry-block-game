extends Node2D

func _ready():
	var board = Board.new()
	add_child(board)
