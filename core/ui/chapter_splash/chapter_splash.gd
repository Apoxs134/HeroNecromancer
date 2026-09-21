class_name ChapterSplash
extends Control

signal finished

@onready var backdrop: ColorRect = $Backdrop
@onready var container: VBoxContainer = $CenterContainer/VBoxContainer
@onready var title_label: Label = $CenterContainer/VBoxContainer/TitleLabel
@onready var divider: ColorRect = $CenterContainer/VBoxContainer/Divider
@onready var subtitle_label: Label = $CenterContainer/VBoxContainer/SubtitleLabel

var _tween: Tween = null

func _ready() -> void:
	visible = false

func play_splash(title: String, subtitle: String = "") -> void:
	title_label.text = title
	subtitle_label.text = subtitle
	subtitle_label.visible = not subtitle.is_empty()
	divider.visible = not subtitle.is_empty()
	
	visible = true
	modulate.a = 1.0
	container.modulate.a = 0.0
	container.scale = Vector2.ONE
	
	if _tween and _tween.is_valid():
		_tween.kill()
		
	# Await one frame for CenterContainer to calculate layout and center perfectly
	await get_tree().process_frame
	
	_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	# Fade in splash text smoothly with zero layout jitter
	_tween.tween_property(container, "modulate:a", 1.0, 0.55)
	# Hold for dramatic effect
	_tween.tween_interval(1.1)
	# Fade out the entire splash to reveal the underlying scene
	_tween.tween_property(self, "modulate:a", 0.0, 0.45)
	_tween.tween_callback(func():
		visible = false
		finished.emit()
	)

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and (event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER or event.keycode == KEY_SPACE)) or (event is InputEventMouseButton and event.pressed):
		_skip()
		get_viewport().set_input_as_handled()

func _skip() -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "modulate:a", 0.0, 0.2)
	_tween.tween_callback(func():
		visible = false
		finished.emit()
	)
