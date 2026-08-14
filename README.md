# Game of Life

An interactive implementation of Conway's Game of Life I made as a study/training to get used to Godot nodes and signals. Code is a bit clunky, but feel free to use it if it is interesting to you for any of your projects.

## Showcase:

![Acorn 630 Cycles Showcase](showcase/acorn-630-cycles.png)

---

## Controls & Navigation

| Action | Control | Description |
| :--- | :--- | :--- |
| **Draw / Erase** | `Left Click (LMB)` | Click or drag on the grid to toggle cells on/off manually. |
| **Pan Field** | `Right Click (RMB)` | Click and drag with the right mouse button to move across the canvas. |
| **Zoom** | `Mouse Wheel` | Scroll up to zoom in, scroll down to zoom out. |
| **Preset Selection** | `Right Panel Click` | Click any pattern name on the right-hand menu to load it into the view. |
| **Exit Game** | `ESC` | Instantly close and exit the application. |

---

## On-Screen UI & Controls

### Left Control Bar

* **Start / Stop**: Toggles the active simulation loop on or off.
* **Step +1**: Advances the simulation by exactly one generation step (useful when paused).
* **Reset**: Clears active cells or resets the canvas state back to last preset.
* **Save As...**: Saves your current board pattern configuration in res://presets/ - doesn't work when compiled as binary (duh). It is a big buggy.
* **Cycles Counter** *(Bottom-Left)*: Real-time display showing the current generation count.

### Right -> Preset Menu

Selected presets I find interesting and mesmerising. You can add more with the save-button. 

### ToDo:

- [ ] Fix Save-as to correctly update the index of the new preset and load it.
- [ ] Add more presets
- [ ] Improve the Deep ocean tile set in the background with 2x or 4x entries for more deep-ocean like feeling, add option to choose between Deep Ocean and Petri Dish color set.


### Disclaimer

Part of this README is AI generated. I am lazy! :joy:
