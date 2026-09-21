class_name AreaProfile
extends Resource

enum AreaZone {
	CHARNEL_TRENCH,
	OUTSKIRTS_OF_MOURNING,
	GALLOWS_FIELD,
	HIGH_CITADEL
}

enum Chapter {
	CHAPTER_0_PROLOGUE,
	CHAPTER_1,
	CHAPTER_2,
	CHAPTER_3
}

enum DialogId {
	NONE,
	INTRO_SCENE,
	VICTORY_SCENE
}

@export var zone: AreaZone = AreaZone.CHARNEL_TRENCH
@export var chapter: Chapter = Chapter.CHAPTER_0_PROLOGUE
@export var target_state: GameManager.GameState = GameManager.GameState.DIALOG
@export var dialog_id: DialogId = DialogId.INTRO_SCENE
@export var encounter_index: int = 0
@export var deck: DeckData

func get_chapter_key() -> String:
	match chapter:
		Chapter.CHAPTER_0_PROLOGUE:
			return "chapter_0"
		Chapter.CHAPTER_1:
			return "chapter_1"
		Chapter.CHAPTER_2:
			return "chapter_2"
		Chapter.CHAPTER_3:
			return "chapter_3"
		_:
			return "chapter_0"

func get_dialog_key() -> String:
	match dialog_id:
		DialogId.INTRO_SCENE:
			return "intro_scene"
		DialogId.VICTORY_SCENE:
			return "victory_scene"
		_:
			return ""
