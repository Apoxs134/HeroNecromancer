extends Control

@onready var new_game_button: Button = $VBoxContainer/NewGameButton
@onready var load_game_button: Button = $VBoxContainer/LoadGameButton
@onready var options_button: Button = $VBoxContainer/OptionsButton

func _ready() -> void:
	print("Cover scene loaded.")
	new_game_button.pressed.connect(_on_new_game_pressed)
	load_game_button.pressed.connect(_on_load_game_pressed)
	options_button.pressed.connect(_on_options_pressed)

func _on_new_game_pressed() -> void:
	print("Starting new game...")
	GameManager.switch_state(GameManager.GameState.DIALOG, {"id": 0, "path": 0})

func _on_load_game_pressed() -> void:
	print("Loading game...")

func _on_options_pressed() -> void:
	print("Options menu...")
