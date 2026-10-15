# KMushokoPixel — CP01A Visual Pilot

**Godot 4.x** 2D side-scrolling idle RPG fan project based on the **specific attached Reel**'s style, with a desktop-companion compact window and expanded preview. The artwork in this branch is original pilot art for feedback, **not yet approved final sprites**.

## Launch

1. Use Godot 4.3 or newer on Windows (Linux/macOS also supported in principle).
2. Import `project.godot` and press F5. **Artwork PNGs are included in the project release ZIP.**
3. To regenerate the same originals from text code, run `python -m pip install Pillow` then `python tools/generate_assets.py`.

## Controls

| Control | Behavior |
| --- | --- |
| `Tab` | Compact / expanded window |
| `Space` | Pause / resume walking |
| `1` | Rudeus art review overlay |
| `2` | Return to party view |
| `H` | Show/hide HUD |
| `T` | Toggle always-on-top for compact |
| Drag top strip | Reposition compact window |
| Click top-right | Toggle mode / pause |

**What exists:** a layered 2D pixel scene, four pilot characters, walk and idle animation frames, parallax and window modes. **What does not exist yet:** enemies, combat, stages, quests, progression, inventory and save files.

Project plans remain in `docs/` from CP00. See `docs/CP01A_IMPLEMENTATION.md` for acceptance tests and limitations. Never treat pilot sprites as approved until they are reviewed alongside the Reel.