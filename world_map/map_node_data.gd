class_name MapNodeData
extends Resource

enum NodeType {
	START,
	COMBAT,
	ELITE,
	GRIMOIRE,
	ALTAR,
	BOSS
}

@export var id: String = ""
@export var title: String = ""
@export var node_type: NodeType = NodeType.COMBAT
@export var tier: int = 0
@export var position: Vector2 = Vector2.ZERO
@export var connected_node_ids: Array[String] = []
@export var encounter: EncounterData
@export var cleared: bool = false
