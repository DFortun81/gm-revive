# Battlefield AI (example)

An agent-based battle simulation written in GameMaker 8.0 around 2010–2013: Horde vs. Alliance armies of
warriors, casters, healers, shamans, rogues, druids and paladins, each with their own AI and abilities, plus two
scripted bosses.

```sh
python -m gm_revive convert examples/battlefield/battlefield_3_2_0_2.gmk out/battlefield
```

Open `out/battlefield/index.html`. The battle starts paused — press **F3**. **F4** shows the help screen,
**0** / **9** spawn the bosses, **F1** restarts.

`muramasa.png` and `darkdeath.png` are loaded by the game at runtime (`sprite_replace`). The original also
replaced three boss tracks with MP3s from its folder; those aren't included here, so the game falls back to the
MIDI versions stored in the project.
