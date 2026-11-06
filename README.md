# gm-revive

Bring old GameMaker games back to life in the browser.

gm-revive reads a GameMaker 6, 7 or 8 project file (`.gm6` / `.gmk`), translates its GML code into JavaScript, extracts the
sprites, sounds and fonts, and produces a folder you can open in any modern browser — no GameMaker, no Windows.

It started as a way to rescue games written in college that only ran as old Windows executables.

## Quick start

Needs Python 3.9+ (standard library only).

```sh
git clone <this repo>
cd gm-revive
python -m gm_revive convert path/to/game.gmk out/game
```

Then open `out/game/index.html`. It works straight from disk, or serve it with `python -m http.server`.

Try the bundled example:

```sh
python -m gm_revive convert examples/battlefield/battlefield_3_2_0_2.gmk out/battlefield
```

### Music (optional)

Browsers can't play MIDI, so MIDI tracks are rendered to MP3. That needs
[FluidSynth](https://www.fluidsynth.org/), [ffmpeg](https://ffmpeg.org/) and a General MIDI soundfont such as
FluidR3_GM.sf2. Point at the soundfont with `--soundfont path/to/file.sf2` or the `GM_REVIVE_SOUNDFONT`
environment variable. Without them the game still converts; MIDI tracks are just silent.

### Extra files

Many games load files from their own folder at runtime (`sprite_replace`, `sound_replace`, …). By default
`convert` copies images and audio from the project's folder into the build. Use `--files DIR` to choose another
folder, or `--no-files` to skip it.

## Overrides: changing a game without GameMaker

Put `.gml` files in a folder named after the project with `.overrides` on the end, next to the project file
(or pass `--overrides DIR`). They replace or add code at build time; the project file is never touched.

```
game.gmk
game.overrides/
  scripts/my_script.gml              replaces that script, or adds a new one
  objects/obj_player/create.gml      replaces that event, or adds it
  objects/obj_player/step_end.gml
  objects/obj_boss_new/object.json   creates a new object (or changes an existing one's properties)
  objects/obj_boss_new/create.gml    ...and its events go next to it, as for any object
```

`object.json` takes any of `sprite`, `parent`, `mask` (resource names, or `null`), `depth`, `visible`, `solid`
and `persistent`, e.g. `{"sprite": "spr_boss_zio", "parent": "obj_boss"}`. It's required for an object the
project doesn't have; new objects can be parents of other new objects, and inheritance loops are refused.

Event file names: `create`, `destroy`, `step`, `step_begin`, `step_end`, `draw`, `alarm0`–`alarm11`,
`user0`–`user15`, `room_start`, `room_end`, `game_start`, `game_end`, `animation_end`, `end_of_path`, or the raw
`<type>_<number>` form used in `game.js` (`keypress_32`, `collision_4`). `event_inherited()` works as usual.
Use `--no-overrides` to build the original game.

`examples/battlefield/battlefield_3_2_0_2.overrides` finishes the Battlefield Paladin and Druid classes this way,
reworks the other classes and adds a new boss object (`obj_boss_stitchgut`).

## Compatibility report

Got a folder full of old projects? Scan it:

```sh
python -m gm_revive report D:/old-games -o report.md
```

The report lists each project's GameMaker version and whether it converts cleanly. It also ranks what's missing
(built-in functions, drag & drop actions, extension packages) by how many projects need it, so it's clear what
to work on next.

## What's supported

| | Status |
|---|---|
| GameMaker 8.0 `.gmk` | ✅ Reads everything: scripts, objects, events, rooms, views, tiles, backgrounds, timelines, paths, sprites, sounds, fonts, constants, game info |
| GameMaker 7 `.gmk` | ✅ Decrypts and reads the same data (images are stored as BMPs; the transparent colour is applied) |
| GameMaker 8.1 `.gm81` | ❌ Detected; format is close to 8.0 |
| GameMaker 6 `.gm6` | ✅ Same layout as GM7, without the encryption |
| GameMaker 5 `.gmd` | ❌ Detected |
| GameMaker Studio `.gmx` / `.yyp` | ❌ Detected; these are plain-text formats and should be the easiest to add |
| GML code | ✅ Full GM8 syntax: `begin/end`, `:=`, `=` as comparison, `and/or/xor/not/div/mod`, `with`, `repeat`, `do…until`, `switch`, `var`, `globalvar`, 1D/2D arrays |
| Drag & drop actions | ✅ Questions, blocks, else, repeat, exit, set variable, apply-to and relative; ~90 standard actions (move, instances, sound, rooms, score/lives/health, drawing). Unknown ones are reported |
| Built-in functions | ~350 implemented — instances, drawing, sprites, surfaces, ds_list/map/grid/stack/queue/priority, paths and path motion, mp_grid path finding, collision checks, input, sound, rooms and room order, views, strings, math |
| Blocking dialogs | ✅ `show_menu`, `get_integer`, `get_string`, `show_question` pause the game and show an HTML dialog; the interrupted event re-runs with the answer. `show_message` pauses until dismissed |
| Freeze-frames and waits | ✅ `screen_refresh` / `screen_redraw` capture frames; `sleep` and `keyboard_wait` hold them; messages and the high-score table queue up in order and play back before the game continues |
| High-score table | ✅ `highscore_*` with a styled table and name entry, saved in the browser's local storage |
| Collision events | ✅ Bounding-box only (no per-pixel masks) |
| Particle systems | ✅ Types, emitters (burst/stream), automatic update and draw; built-in shapes are drawn procedurally |
| Extensions | WinSkin re-implemented; others need a JS replacement |

## How the translation works

Each script becomes `S.name(self, other, argument0, …)` and each event a function of `(self, other)`.

| GML | JavaScript |
|---|---|
| `hp -= 5` | `self.hp -= 5` |
| `other.x` / `global.score` | `other.x` / `G.score` |
| `target.hp = 0` | `B.setField(self.target, "hp", 0)` (sets every instance when `target` is an object) |
| `with (obj_enemy) { … }` | a `for` loop that rebinds `self` and `other`, so `break`, `continue` and `exit` behave like GM |
| `if (x)` | `if (B.T(self.x))` — GM treats values ≤ 0.5 as false |
| `my_script(a)` | `S.my_script(self, other, a)` |
| `draw_sprite(…)` | `B.draw_sprite(self, …)` — built-ins live on `B` in `runtime.js` |
| `obj_player`, `spr_hero` | plain constants holding the resource index |

Reading a variable that was never assigned gives 0, matching GM8's "treat uninitialized variables as 0" option.

The runtime (`gm_revive/runtime/runtime.js`) follows GM8's event order: begin step → alarms → keyboard → mouse →
step → timelines → motion → collisions → end step → animation → draw (sorted by depth).

## Project layout

```
gm_revive/
  gmk.py          .gm6/.gmk reader for GM6, GM7 and GM8 (and format detection)
  gml2js.py       GML parser and JavaScript emitter
  build.py        writes the HTML5 build
  report.py       compatibility report
  overrides.py    applies <project>.overrides folders
  rtf2html.py     game information (RTF) -> HTML help screen
  runtime/        runtime.js and the index.html template
examples/battlefield/   an example GM8 project
tests/
```

## Contributing

The fastest way to help: run `report` on your own old projects and implement whatever is at the top of the list.

**Adding a missing built-in function:** add it to `runtime.js` as `B.name = (…) => …`. If it acts on the
calling instance (like `instance_destroy` or `place_meeting`), also add its name to `SELF_FUNCS` in `gml2js.py`
so it receives `self` as its first argument. `report` and the tests pick up new functions automatically.

**Adding an extension:** implement its functions in `runtime.js` and add its name to `B._extensions`.

Run the tests (the semantic tests use Node.js if it's installed):

```sh
python -m unittest discover tests
```

## Known differences from the original games

- Blend modes are approximated with canvas composite modes (`bm_max` → screen, `bm_add` → lighter).
- `draw_text_color` uses the first colour only; primitives use linear gradients.
- Collisions use bounding boxes.
- MIDI music sounds different from the Windows MIDI synth it was written for.

## License

MIT — see [LICENSE](LICENSE). Example projects keep their original authors' rights.

GameMaker is a trademark of YoYo Games Ltd. This project is not affiliated with or endorsed by YoYo Games.
