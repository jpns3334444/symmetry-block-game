extends Node

signal theme_changed(new_theme: GameTheme)

var current_theme_name: String = ""
var available_themes: Dictionary = {}

func _ready():
	scan_themes()
	
	# Set default theme to first one found, or fallback
	if not available_themes.is_empty():
		current_theme_name = available_themes.keys()[0]
	
	print("Found themes: ", available_themes.keys())

func scan_themes():
	available_themes.clear()
	
	var dir = DirAccess.open("res://themes/")
	if not dir:
		print("No themes/ directory found!")
		return
	
	# Get all subdirectories in themes/
	var directories = dir.get_directories()
	for theme_folder in directories:
		var theme_dir = DirAccess.open("res://themes/" + theme_folder + "/")
		if theme_dir:
			var files = theme_dir.get_files()
			for file in files:
				if file.ends_with("_theme.tres"):
					var theme_resource = load("res://themes/" + theme_folder + "/" + file) as GameTheme
					if theme_resource:
						available_themes[theme_folder] = theme_resource
						print("Loaded theme: ", theme_folder)
						break


func get_current_theme() -> GameTheme:
	if available_themes.has(current_theme_name):
		return available_themes[current_theme_name]
	return null

func switch_theme(theme_name: String):
	if not available_themes.has(theme_name):
		print("Theme not found: ", theme_name)
		return false
	
	current_theme_name = theme_name
	theme_changed.emit(available_themes[theme_name])
	return true

func get_available_theme_names() -> Array:
	return available_themes.keys()
