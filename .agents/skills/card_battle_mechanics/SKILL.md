---
name: card_battle_mechanics
description: Card Battle & Encounter Mechanics Designer for HeroNecromancer. Specializes in deckbuilder architecture, card and enemy data models, turn-based battle flow state machines, intent systems, and balance frameworks.
---
# Card Battle Mechanics Specialist

Specialized role for designing and implementing card-based combat, deck mechanics, enemy behavior patterns, and combat encounter loops in Godot 4.

---

## 1. Core Architecture Directives
* **Data-Driven Cards & Enemies**: Every card and enemy action is a Godot `Resource` (`.tres`). Never hardcode damage, costs, or effects inside scenes or UI nodes.
* **Art Decoupling**: Card and enemy data resources hold optional `Texture2D` fields. If texture is `null`, UI automatically renders a fallback name, frame, and type-color icon so gameplay balance proceeds without waiting for finalized artwork.
* **Deterministic Pile Management**: Separate card collections into distinct arrays: `draw_pile`, `hand`, `discard_pile`, and `exhaust_pile`. Shuffling only occurs when drawing from an empty `draw_pile`.
* **Predictable Enemy Intent**: Enemy actions (attacks, buffs, summons) must be determined at the start of the player turn and exposed to the UI via an Intent component.

---

## 2. Resource Schemas

### Card Data (`res://battlefield/data/card_data.gd`)
```gdscript
class_name CardData
extends Resource

enum CardType { ATTACK, DEFENSE, SUMMON, SKILL }
enum TargetType { SINGLE_ENEMY, ALL_ENEMIES, SELF, ALL_ALLIES }

@export var id: String = ""
@export var title: String = ""
@export_multiline var description: String = ""
@export var cost: int = 1 # Soul/Mana cost
@export var card_type: CardType = CardType.ATTACK
@export var target_type: TargetType = TargetType.SINGLE_ENEMY
@export var value: int = 0 # Base damage, block, or summon count
@export var artwork: Texture2D = null
```

### Enemy Action & Data (`res://battlefield/data/enemy_data.gd`)
```gdscript
class_name EnemyData
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var max_health: int = 50
@export var sprite: Texture2D = null
@export var action_pattern: Array[Dictionary] = [] # e.g. [{"type": "attack", "val": 8}, {"type": "defend", "val": 6}]
```

---

## 3. Battle Flow State Machine
A standard 5-phase combat loop:

1. **BATTLE_START**: Initialize piles, instantiate combatants, apply passives.
2. **PLAYER_DRAW**: Draw standard hand size (e.g. 5 cards) from `draw_pile`. Recycle `discard_pile` if empty. Reset energy/souls.
3. **PLAYER_TURN**: Accept input. Validate energy cost and legal targets. Emit card execution events to combat resolution manager.
4. **DISCARD_PHASE**: Move unplayed non-retaining cards from `hand` to `discard_pile`.
5. **ENEMY_TURN**: Execute previewed enemy actions sequentially. Apply status updates. Determine next intents. Check win/loss conditions.

---

## 4. Milestone Execution Protocol
1. **Milestone 3 (Battle Flow)**: Implement state machine, pile managers, turn transition signals, and basic resolve pipeline with 1 dummy card and 1 dummy enemy.
2. **Milestone 1 (Card Decks)**: Create `CardData` resources, deck loader, hand visual fan layout, and discard/draw logic.
3. **Milestone 2 (Enemies)**: Create `EnemyData` resources, intent display, hitboxes, and action queues.
4. **Milestone 4 (Balancing)**: Tune energy-to-damage ratios, enemy HP curves, hand draw variance, and stage progression tables.
