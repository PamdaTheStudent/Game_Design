# Vampire Blood Wine Distillery

A top-down management sim built in Godot 4. You run a vampire blood wine distillery: move around a tilemap room, drag stations onto a grid during a build phase, then interact with them during a timed round to play crafting minigames, collect the finished wine bottle, and carry it to the King's Table before time runs out.

### Rubric Requirements (5 Required)
- ✅ **Background**: TileMap forms the floor of the distillery room ([TileMapController.gd](scripts/TileMapController.gd))
- ✅ **Unmovable object**: Boundary walls/barrels (always static); Stations become locked `StaticBody2D`s during ROUND/MINIGAME ([Wall.tscn](scenes/Wall.tscn), [Station.gd](scripts/Station.gd))
- ✅ **Movable object**: The Player ([Player.gd](scripts/Player.gd)); Stations while in BUILD phase (drag/snap to grid)
- ✅ **Collision (2+ objects)**: Player vs. walls/barrels; Player's InteractArea vs. a Station's InteractZone ([InteractZone.gd](scripts/InteractZone.gd))
- ✅ **Input (keyboard/mouse)**: WASD/arrow-key movement, `E`/left-click to interact, `Enter` to start a round, nozzle aim/suck input inside the minigame

### Stretch Challenge: Scoring System
- ✅ **Scoring**: The BubbleCatchMinigame produces a quality/potency score that becomes the round score, tracked by `GameManager` and displayed on the HUD

## Instructions for Build and Use

Steps to build and/or run the software:

1. Install [Godot 4](https://godotengine.org/download) (this project uses the standard/non-.NET build).
2. Open Godot, choose "Import", and select the `project.godot` file in this folder.
3. Press the Play button (or F5) to run the game, using `Main.tscn` as the main scene.

Instructions for using the software:

1. The game starts in **BUILD** phase — click and drag Stations to reposition them on the grid.
2. Press `Enter` to start the round (locks Stations in place and starts the timer).
3. Move with `WASD` or arrow keys. Walk up to a Station and press `E` (or left-click) to interact and launch its minigame.
4. Inside the minigame, aim the nozzle and suck up good (red) bubbles while avoiding bad ones to raise the wine's potency before time runs out.
5. Completing a minigame spawns a wine bottle at the station — walk into it to pick it up, then carry it to the King's Table and press `E` to submit it and end the round.
6. After the round ends, the game returns to BUILD phase so you can rearrange Stations and start again.

## Development Environment

To recreate the development environment, you need the following software and/or libraries with the specified versions:

* Godot Engine 4.x
* GDScript (built into Godot)
* Python 3 (only used by [tools/generate_assets.py](tools/generate_assets.py) to generate placeholder art)
* Claude Code

## Useful Websites to Learn More

I found these websites useful in developing this software:

* [Godot Docs — GDScript](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html)
* [Godot Docs — CharacterBody2D](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html)
* [Godot Docs — Signals](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html)
* Claude.AI

## Future Work

The following items I plan to fix, improve, and/or add to this project in the future:

* [ ] Add a second Station and minigame for variety
* [ ] Add win/lose feedback (e.g. quality-tier messaging) when submitting wine to the King
* [ ] Polish art assets beyond the generated placeholders
* [ ] Add sound effects and music
