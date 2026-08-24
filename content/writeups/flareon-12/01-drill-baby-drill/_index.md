---
title: "01 - Drill Baby Drill!"
layout: "Notes"
overview: "Published draft: map positions, bear collection, and XOR flag decoding."
status: "Draft complete"
---

## Overview

I began by opening the game and exploring the maps. Each level has rocks to avoid and a teddy bear hidden at a specific horizontal position. The goal is to drill straight down at the correct X coordinate, recover every bear, and finish the last level.

## Finding the flag routine

After reviewing the source, I found the `GenerateFlagText` function. When a bear is collected, the game adds `player.x` to `bear_sum`; on the final level it passes that value to `GenerateFlagText` and shows the result on the victory screen.

![The bear collection path adds the player X coordinate to `bear_sum` and sends it to `GenerateFlagText`.](/images/flareon-12/01-drill-baby-drill/Bear_Mode.png)

The X coordinates are the lengths of the level names:

```text
California      = 10
Ohio            =  4
Death Valley    = 11
Mexico          =  6
The Grand Canyon = 16
```

The flag routine shifts the total right by eight bits, then XORs each encoded character with that key plus its index.

![`GenerateFlagText` derives the XOR key from the accumulated value.](/images/flareon-12/01-drill-baby-drill/GenerateFlagText.png)

## Solving it

I wrote a short script that calculates the value from the level-name lengths and performs the same XOR loop. The result matches the in-game victory screen.

![The local solver output.](/images/flareon-12/01-drill-baby-drill/Solve_by_Script.png)

![The completed game displays the flag on the victory screen.](/images/flareon-12/01-drill-baby-drill/Solve_by_Game.png)

## Downloads

<a href="/downloads/writeups/flareon-12/01-drill-baby-drill/solve.py" download>Download the solver script</a>

<a href="/downloads/writeups/flareon-12/01-drill-baby-drill/sample-task.txt" download>Download the placeholder task-file attachment</a>

Future files for this task can be placed in `static/downloads/writeups/flareon-12/01-drill-baby-drill/` and linked here.
