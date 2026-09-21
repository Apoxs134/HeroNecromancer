extends Control

@onready var title_label: Label = $Title
@onready var details_label: Label = $DetailsLabel
@onready var finish_button: Button = $FinishButton
@onready var retreat_button: Button = $RetreatButton

@onready var event_overlay: ColorRect = $EventOverlay
@onready var event_speaker_label: Label = $EventOverlay/Panel/SpeakerLabel
@onready var event_message_label: Label = $EventOverlay/Panel/MessageLabel

var event_lines: Array = []
var current_event_line_index: int = 0

# Scalable database of level parameters
const BATTLE_LEVELS = {
	"battle_1": {
		"name": "The Dark Forest",
		"enemies": ["Skeleton Scout", "Zombie"],
		"difficulty": "Easy"
	},
	"battle_2": {
		"name": "Necromancer's Keep",
		"enemies": ["Lich Prince", "Death Knight", "Bone Dragon"],
		"difficulty": "Hard"
	}
}

func _ready() -> void:
	retreat_button.pressed.connect(_on_retreat_pressed)
	finish_button.pressed.connect(_on_finish_pressed)
	
	# Load specific battlefield details based on parameter
	var battle_id = GameManager.active_params.get("battle_id", "battle_1")
	load_battle(battle_id)
	
	# Trigger a sample start-of-battle event for demo purposes
	show_event([
		{"speaker": "Commander", "text": "Ambush! Protect the Necromancer at all costs!"},
		{"speaker": "Zombie", "text": "Urrgghh... protect... master..."}
	])

func _input(event: InputEvent) -> void:
	if event_overlay.visible and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		advance_event()
		get_viewport().set_input_as_handled()

func show_event(lines: Array) -> void:
	event_lines = lines
	current_event_line_index = 0
	if event_lines.size() > 0:
		event_overlay.visible = true
		display_event_line()
	else:
		event_overlay.visible = false

func display_event_line() -> void:
	if current_event_line_index < event_lines.size():
		var line = event_lines[current_event_line_index]
		event_speaker_label.text = line.get("speaker", "Event")
		event_message_label.text = line.get("text", "")
	else:
		event_overlay.visible = false

func advance_event() -> void:
	current_event_line_index += 1
	display_event_line()


func load_battle(battle_id: String) -> void:
	print("Loading battlefield layout for: ", battle_id)
	
	if BATTLE_LEVELS.has(battle_id):
		var info = BATTLE_LEVELS[battle_id]
		title_label.text = info["name"]
		details_label.text = "Difficulty: " + info["difficulty"] + "\n\nEnemies:\n"
		for enemy in info["enemies"]:
			details_label.text += "- " + enemy + "\n"
	else:
		title_label.text = "Unknown Battlefield"
		details_label.text = "No level data found for " + battle_id

func _on_finish_pressed() -> void:
	print("Battle Completed successfully!")
	# Transition back to World Map
	GameManager.switch_state(GameManager.GameState.WORLD_MAP)

func _on_retreat_pressed() -> void:
	print("Retreating from battle...")
	# Return to map
	GameManager.switch_state(GameManager.GameState.WORLD_MAP)
