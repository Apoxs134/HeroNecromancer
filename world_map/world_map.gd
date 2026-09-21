extends Control

@onready var dialog_1_button: Button = $VBoxContainer/Dialog1Button
@onready var dialog_2_button: Button = $VBoxContainer/Dialog2Button
@onready var battle_1_button: Button = $VBoxContainer/Battle1Button
@onready var battle_2_button: Button = $VBoxContainer/Battle2Button
@onready var back_button: Button = $BackButton

func _ready() -> void:
	print("World Map loaded.")
	dialog_1_button.pressed.connect(func(): _on_dialog_selected("intro_scene"))
	dialog_2_button.pressed.connect(func(): _on_dialog_selected("victory_scene"))
	battle_1_button.pressed.connect(func(): _on_battle_selected("battle_1"))
	battle_2_button.pressed.connect(func(): _on_battle_selected("battle_2"))
	back_button.pressed.connect(_on_back_pressed)

func _on_dialog_selected(dialog_id: String) -> void:
	print("Selected dialog: ", dialog_id)
	GameManager.switch_state(GameManager.GameState.DIALOG, {"dialog_id": dialog_id})

func _on_battle_selected(battle_id: String) -> void:
	print("Selected battle: ", battle_id)
	GameManager.switch_state(GameManager.GameState.BATTLEFIELD, {"battle_id": battle_id})

func _on_back_pressed() -> void:
	GameManager.switch_state(GameManager.GameState.COVER)
