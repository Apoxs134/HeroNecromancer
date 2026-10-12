extends Control

@onready var scroll_content: Control = $ScrollContainer/Content
@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var skip_button: Button = $SkipButton
@onready var finish_overlay: Control = $FinishOverlay
@onready var finish_label: Label = $FinishOverlay/FinishLabel
@onready var return_prompt: Label = $FinishOverlay/ReturnPrompt

const NORMAL_SPEED: float = 45.0
const FAST_SPEED: float = 160.0

var _scroll_pos: float = 0.0
var _is_fast_forward: bool = false
var _is_finished: bool = false
var _pulse_tween: Tween = null

func _ready() -> void:
	skip_button.pressed.connect(_on_skip_pressed)
	finish_overlay.visible = false
	scroll_container.scroll_vertical = 0
	
	# Initial delay before rolling
	await get_tree().create_timer(0.8).timeout

func _process(delta: float) -> void:
	if _is_finished:
		return
		
	var speed = FAST_SPEED if _is_fast_forward else NORMAL_SPEED
	_scroll_pos += speed * delta
	scroll_container.scroll_vertical = int(_scroll_pos)
	
	var max_scroll = scroll_content.size.y - scroll_container.size.y
	if _scroll_pos >= max_scroll and max_scroll > 0:
		_show_finish_screen()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT):
		if _is_finished:
			if not event.pressed:
				_return_to_cover()
		else:
			_is_fast_forward = event.pressed

func _on_skip_pressed() -> void:
	_show_finish_screen()

func _is_game_ended() -> bool:
	var gm = get_node_or_null("/root/GameManager")
	if gm != null:
		return gm.active_params.get("game_completed", false)
	return false

func _show_finish_screen() -> void:
	if _is_finished:
		return
	_is_finished = true
	skip_button.visible = false
	
	if _is_game_ended():
		finish_label.text = "Thank you for playing HeroNecromancer."
	else:
		finish_label.text = "Hero Necromancer"
	
	finish_overlay.visible = true
	finish_overlay.modulate.a = 0.0
	
	var tween = create_tween()
	tween.tween_property(finish_overlay, "modulate:a", 1.0, 0.8)
	
	_pulse_tween = create_tween().set_loops()
	_pulse_tween.tween_property(return_prompt, "modulate:a", 0.4, 0.9).set_trans(Tween.TRANS_SINE)
	_pulse_tween.tween_property(return_prompt, "modulate:a", 1.0, 0.9).set_trans(Tween.TRANS_SINE)

func _return_to_cover() -> void:
	print("Credits concluded. Returning to Cover...")
	if _pulse_tween and _pulse_tween.is_valid():
		_pulse_tween.kill()
	var gm = get_node_or_null("/root/GameManager")
	if gm != null:
		var game_completed: bool = gm.active_params.get("game_completed", false)
		if game_completed and gm.has_method("clear_saved_crusade"):
			gm.clear_saved_crusade()
		if gm.has_method("switch_state"):
			gm.switch_state(gm.GameState.COVER)
	else:
		get_tree().change_scene_to_file("res://cover/cover.tscn")
