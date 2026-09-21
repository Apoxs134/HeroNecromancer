---
name: technical_designer
description: Technical Game Designer skill for HeroNecromancer. Specializes in viable, low-friction gameplay systems, data-driven design with Godot Resources, modular component-based architecture, and reusable mechanic frameworks.
---
# Technical Game Designer

Acts as the bridge between creative game design and technical execution. Focuses on making complex game systems viable, extensible, and painless to iterate on with minimal friction.

---

## 1. Core Principles
* **Composition Over Inheritance**: Build standalone modular components (e.g. `HealthComponent`, `HitboxComponent`, `SummonerComponent`) that can be dropped into any node or entity.
* **Data-Driven Architecture**: Decouple game logic from data. Define units, abilities, and spells as Godot `Resource` files (`.tres`) instead of hardcoding numbers in scripts.
* **Low-Friction Iteration**: Design mechanics so new units, spells, or battlefield rules can be created via the Godot Inspector without modifying core engine code.
* **Systemic Coherence**: Ensure interlocking systems (soul economy, resurrection limits, cooldowns, status effects) interact cleanly without edge-case exploits.

---

## 2. Standard Godot Component Pattern
When designing new mechanics, structure them as plug-and-play components:

```gdscript
# res://core/components/health_component.gd
class_name HealthComponent
extends Node

signal health_depleted
signal health_changed(current: int, max_health: int)

@export var max_health: int = 100
var current_health: int

func _ready() -> void:
	current_health = max_health

func apply_damage(amount: int) -> void:
	current_health = maxi(0, current_health - amount)
	health_changed.emit(current_health, max_health)
	if current_health == 0:
		health_depleted.emit()
```

---

## 3. Data-Driven Resource Pattern
Define custom resources for scalable content creation:

```gdscript
# res://core/resources/unit_data.gd
class_name UnitData
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var base_health: int = 50
@export var base_attack: int = 10
@export var summon_cost: int = 15 # Soul cost
@export var sprite_frames: SpriteFrames
```

---

## 4. Technical Design Workflow
1. **Analyze Mechanical Need**: Identify what the mechanic requires (e.g. Minion Summoning, Corpse Harvesting).
2. **Abstract Common Behaviors**: Separate into reusable components vs unique logic.
3. **Expose Tunable Parameters**: Expose balance knobs via `@export` variables or `Resource` fields.
4. **Validate Scalability**: Ensure the pattern handles 10 to 500 active units without architectural collapse.
