extends Control

signal closed

@onready var volume_slider: HSlider = find_child("VolumeSlider") as HSlider
@onready var volume_percent_label: Label = find_child("VolumePercentLabel") as Label
@onready var mute_check: BaseButton = find_child("MuteCheck") as BaseButton
@onready var website_button: Button = find_child("WebsiteButton") as Button
@onready var close_button: Button = find_child("CloseButton") as Button
@onready var header_close_button: Button = find_child("HeaderCloseButton") as Button

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	
	if volume_slider != null:
		volume_slider.value_changed.connect(_on_volume_changed)
	if mute_check != null:
		mute_check.toggled.connect(_on_mute_toggled)
	if website_button != null:
		website_button.pressed.connect(_on_website_pressed)
	if close_button != null:
		close_button.pressed.connect(close)
	if header_close_button != null:
		header_close_button.pressed.connect(close)
		
	sync_audio_settings()

func _gui_input(event: InputEvent) -> void:
	if not visible:
		return
	var is_click = (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed) or (event is InputEventScreenTouch and event.pressed)
	if is_click:
		var tap_pos: Vector2 = event.position if event is InputEventScreenTouch else (event.global_position if "global_position" in event else event.position)
		var panel = find_child("Panel") as Control
		if panel != null and panel.get_global_rect().has_point(tap_pos):
			return
		close()

func sync_audio_settings() -> void:
	var master_idx = AudioServer.get_bus_index("Master")
	if master_idx >= 0:
		var db = AudioServer.get_bus_volume_db(master_idx)
		var val = clampf(db_to_linear(db), 0.0, 1.0)
		var is_muted = AudioServer.is_bus_mute(master_idx)
		if volume_slider != null:
			volume_slider.value = val
			volume_slider.modulate.a = 0.4 if is_muted else 1.0
		_update_volume_label(val)
		if volume_percent_label != null:
			volume_percent_label.modulate.a = 0.4 if is_muted else 1.0
		if mute_check != null:
			mute_check.button_pressed = is_muted

func _update_volume_label(val: float) -> void:
	if volume_percent_label != null:
		var pct = int(round(val * 100.0))
		volume_percent_label.text = "%d%%" % pct

func open() -> void:
	sync_audio_settings()
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = true

func close() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	closed.emit()

func _on_volume_changed(val: float) -> void:
	_update_volume_label(val)
	var master_idx = AudioServer.get_bus_index("Master")
	if master_idx >= 0:
		if val <= 0.001:
			AudioServer.set_bus_mute(master_idx, true)
		else:
			var is_muted = mute_check.button_pressed if mute_check != null else false
			AudioServer.set_bus_mute(master_idx, is_muted)
			AudioServer.set_bus_volume_db(master_idx, linear_to_db(val))

func _on_mute_toggled(is_muted: bool) -> void:
	var master_idx = AudioServer.get_bus_index("Master")
	if master_idx >= 0:
		AudioServer.set_bus_mute(master_idx, is_muted)
	if volume_slider != null:
		volume_slider.modulate.a = 0.4 if is_muted else 1.0
	if volume_percent_label != null:
		volume_percent_label.modulate.a = 0.4 if is_muted else 1.0

func _on_website_pressed() -> void:
	print("Opening Swiftral studio website...")
	OS.shell_open("https://www.swiftral.com")
