extends Control

@onready var continue_button: Button = find_child("ContinueButton") as Button
@onready var new_game_button: Button = find_child("NewGameButton") as Button
@onready var options_button: Button = find_child("OptionsButton") as Button
@onready var credits_button: Button = find_child("CreditsButton") as Button
@onready var options_modal: Control = $OptionsModal

func _get_game_manager() -> Node:
	var tree: SceneTree = null
	if is_inside_tree():
		tree = get_tree()
	else:
		tree = Engine.get_main_loop() as SceneTree
	if tree != null and tree.root != null and tree.root.has_node("GameManager"):
		return tree.root.get_node("GameManager")
	return null

func _get_continue_button() -> Button:
	if continue_button != null:
		return continue_button
	return find_child("ContinueButton") as Button

func update_button_states() -> void:
	var gm = _get_game_manager()
	var has_save: bool = gm != null and gm.has_method("has_saved_crusade") and gm.has_saved_crusade()
	var btn = _get_continue_button()
	if btn != null:
		btn.disabled = not has_save
		btn.modulate.a = 1.0 if has_save else 0.45

func _ready() -> void:
	print("Cover scene loaded.")
	update_button_states()
	
	continue_button.pressed.connect(_on_continue_pressed)
	new_game_button.pressed.connect(_on_new_game_pressed)
	options_button.pressed.connect(_on_options_pressed)
	credits_button.pressed.connect(_on_credits_pressed)

func _on_continue_pressed() -> void:
	print("Resuming crusade...")
	var gm = _get_game_manager()
	if gm != null and gm.has_method("load_and_resume_crusade"):
		if not gm.load_and_resume_crusade():
			continue_button.disabled = true
			continue_button.modulate.a = 0.45

func _on_new_game_pressed() -> void:
	print("Starting new game...")
	var gm = _get_game_manager()
	if gm != null:
		if gm.has_method("clear_saved_crusade"):
			gm.clear_saved_crusade()
		if gm.has_method("reset_crusade"):
			gm.reset_crusade("node_0_start")
		gm.switch_state(gm.GameState.DIALOG, {"id": 0, "path": 0})
	else:
		get_tree().change_scene_to_file("res://dialog/dialog.tscn")

func _on_options_pressed() -> void:
	print("Opening options modal...")
	if options_modal != null and options_modal.has_method("open"):
		options_modal.open()
	elif options_modal != null:
		options_modal.visible = true

func _on_credits_pressed() -> void:
	print("Viewing credits from Cover menu...")
	var gm = _get_game_manager()
	if gm != null and gm.has_method("switch_state"):
		gm.switch_state(gm.GameState.CREDITS, {"from_options": true})
	else:
		get_tree().change_scene_to_file("res://credits/credits.tscn")
