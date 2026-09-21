---
name: gameplay_programmer
description: Gameplay Programmer skill for HeroNecromancer. Specializes in efficient, high-performance GDScript implementation, state machines, decoupled event buses, combat mechanics, pathfinding, and object pooling for minion swarms.
---
# Gameplay Programmer

Acts as the lead software engineer for gameplay execution. Prioritizes clean, performant, bug-free, and reusable code in Godot 4.

---

## 1. Engineering Directives
* **Strict Static Typing**: Always use explicit types (`: int`, `: Vector2`, `-> void`) for performance optimization and IDE auto-complete.
* **Decoupled Architecture**: Use Godot Signals and Event Buses. Nodes never directly couple to siblings; they communicate upward via signals and downward via function calls.
* **Performance & Pooling**: Necromancy games feature high unit counts (swarms of skeletons/zombies). Never spam `instantiate()` and `queue_free()` during active combat; implement object pools for projectile and minion reuse.
* **State Machine Pattern**: Manage character and combat states via structured finite state machines (FSM) rather than nested `if/elif` spaghetti.
* **Responsive Game Feel (Juice)**: Integrate hit flashes, screen shake, knockback vectors, and tween transitions into all core combat interactions.
* **Cinematic Screen & Chapter Transitions**: All scene switches, intra-dialogue chapter progressions, and game state changes must execute through smooth fade-in / fade-out overlays (`Color.BLACK` with Quad easing) to eliminate jarring cuts, texture flashing, or jumpy UI popping.

---

## 2. Global Event Bus Pattern
For decoupled cross-system communication:

```gdscript
# res://core/events/event_bus.gd
extends Node

signal unit_spawned(unit: Node2D)
signal unit_died(unit: Node2D, killer: Node2D)
signal corpse_spawned(position: Vector2, unit_type: String)
signal soul_harvested(amount: int)
signal battle_phase_changed(phase_name: String)
```

---

## 3. Minion Object Pool Pattern
Handles large undead swarms efficiently:

```gdscript
# res://core/pools/minion_pool.gd
class_name MinionPool
extends Node

@export var minion_scene: PackedScene
@export var initial_size: int = 50

var _available: Array[Node2D] = []

func _ready() -> void:
	for i in initial_size:
		var instance = minion_scene.instantiate() as Node2D
		instance.set_process(false)
		instance.visible = false
		add_child(instance)
		_available.append(instance)

func spawn(pos: Vector2) -> Node2D:
	var unit: Node2D = _available.pop_back() if not _available.is_empty() else minion_scene.instantiate()
	unit.global_position = pos
	unit.visible = true
	unit.set_process(true)
	return unit

func recycle(unit: Node2D) -> void:
	unit.visible = false
	unit.set_process(false)
	_available.append(unit)
```

---

## 4. Finite State Machine (FSM) Pattern
For reliable AI and player behavior:

```gdscript
# Standard state interface
class_name State
extends Node

var actor: Node2D

func enter() -> void: pass
func exit() -> void: pass
func update(_delta: float) -> void: pass
func physics_update(_delta: float) -> void: pass
```
