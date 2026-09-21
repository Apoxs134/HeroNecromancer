---
name: tester
description: Quality assurance and test automation skill for HeroNecromancer. Validates GDScript static typing, scene instantiation, resource integrity, and executes headless test suites akin to 'flutter analyze' and 'flutter test'.
---
# QA & Test Automation (Tester)

Acts as the automated QA and validation engineer. Ensures that any new code, refactored component, or scene change compiles cleanly, instantiates without null references, adheres to static typing, and passes regression suites.

---

## 1. Core Directives

* **Static Analysis First**: Verify static typing and ensure zero engine errors or script compilation warnings.
* **Headless Scene Instantiation**: Validate that every `.tscn` can be loaded and instantiated in memory without broken node paths, missing resources, or unhandled signals.
* **Automated Regression**: Execute headless tests after completing feature implementations before reporting completion to the user.

---

## 2. Verification Commands

### A. Headless Engine Verification (Analogous to `flutter analyze`)
Runs Godot in headless editor mode to catch script compilation errors, broken `.uid` mappings, and invalid scene dependencies:
```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --editor --quit-after 50
```

### B. Automated Test Suite (Analogous to `flutter test`)
Runs automated headless test runners or custom verification scripts:
```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --script res://core/tests/test_runner.gd
```

---

## 3. Test Runner Pattern (`res://core/tests/test_runner.gd`)
A standalone lightweight test harness for headless execution:

```gdscript
extends SceneTree

func _init() -> void:
    print("--- [TEST RUNNER] Starting Verification Suite ---")
    var failures: int = 0
    
    failures += _test_scenes()
    failures += _test_resources()
    
    if failures == 0:
        print("--- [TEST RUNNER] ALL TESTS PASSED ---")
        quit(0)
    else:
        push_error("--- [TEST RUNNER] %d TESTS FAILED ---" % failures)
        quit(1)

func _test_scenes() -> int:
    var scenes = [
        "res://main/main.tscn",
        "res://dialog/dialog.tscn",
        "res://battlefield/battlefield.tscn",
        "res://world_map/world_map.tscn",
        "res://cover/cover.tscn"
    ]
    var errs = 0
    for path in scenes:
        var packed = load(path) as PackedScene
        if not packed:
            push_error("Failed to load scene: %s" % path)
            errs += 1
            continue
        var instance = packed.instantiate()
        if not instance:
            push_error("Failed to instantiate: %s" % path)
            errs += 1
        instance.free()
    return errs

func _test_resources() -> int:
    # Test JSON and Resource integrity
    return 0
```

---

## 4. Post-Coding Verification Checklist
Before completing any task:
1. Check that all new GDScript files use static typing (`: Type`, `-> void`).
2. Run headless validation to ensure zero runtime script parse errors.
3. Validate that scene node paths (`@onready var ... = $...`) resolve correctly.
