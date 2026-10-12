#!/usr/bin/env bash
# HeroNecromancer - Simulation & Auto-Battler Launcher

GODOT_BIN="/Applications/Godot.app/Contents/MacOS/Godot"
if [ ! -f "$GODOT_BIN" ]; then
    GODOT_BIN="$(which godot 2>/dev/null)"
fi

if [ -z "$GODOT_BIN" ]; then
    echo "Error: Godot executable not found at /Applications/Godot.app or in PATH."
    exit 1
fi

case "$1" in
    crusade|campaign|run)
        echo "Running Full Crusade Multi-Profile Suite (400 runs across all 4 playstyles)..."
        "$GODOT_BIN" --headless res://core/simulation/balance_simulator.tscn -- --crusade --runs=100 --bot=all
        ;;
    sim|headless|"")
        echo "Running Headless Combat Balance Simulator (100 runs)..."
        "$GODOT_BIN" --headless res://core/simulation/balance_simulator.tscn -- --runs=100 --bot=balanced
        ;;
    auto|colosseum|spectator)
        echo "Launching Auto-Battler Colosseum (Spectator Window)..."
        "$GODOT_BIN" res://core/simulation/simulation_colosseum.tscn
        ;;
    test|pipeline)
        echo "Running Full Pipeline Test..."
        "$GODOT_BIN" --headless res://core/tests/test_chapter_1_pipeline.tscn
        ;;
    *)
        echo "Usage: $0 [crusade|sim|auto|test]"
        echo "  crusade - Run 100-run full campaign progression (10-card start -> draft rewards -> boss)"
        echo "  sim     - Run 100-batch individual encounter balance simulator"
        echo "  auto    - Launch interactive Spectator Colosseum UI window"
        echo "  test    - Run Chapter 1 scene pipeline test"
        exit 1
        ;;
esac
