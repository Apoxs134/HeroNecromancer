class_name MapData
extends Resource

@export var map_id: String = ""
@export var map_name: String = ""
@export var bg_texture: Texture2D
@export var tutorial_title: String = "CRUSADE MAP NAVIGATION"
@export_multiline var tutorial_text: String = ""
@export var nodes: Array[MapNodeData] = []
@export var start_node_id: String = "node_start"
@export var end_dialog_id: String = "ending_scene"
@export var chapter_key: String = "chapter_1"

func get_node(node_id: String) -> MapNodeData:
	for n in nodes:
		if n.id == node_id:
			return n
	return null
