class_name EncounterData
extends Resource

@export var id: String = ""
@export var title: String = ""
@export var difficulty: String = "Normal"
@export var bg_texture: Texture2D
@export var enemies: Array[String] = []
@export var tutorial_dialog: Array[Dictionary] = []
@export var next_state: GameManager.GameState = GameManager.GameState.WORLD_MAP
@export var next_dialog_id: String = ""
@export var next_encounter_tres: String = ""
@export var return_to_map: bool = true
@export var can_retreat: bool = true
