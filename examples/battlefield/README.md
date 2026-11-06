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

## The Paladin

The original project left the Paladin as a stub (stats only, no AI — Paladins just stood around).
`battlefield_3_2_0_2.overrides/` finishes it in GML without changing the `.gmk`:

- **Judgement** — holy damage burst on the melee target (8 s cooldown)
- **Consecration** — damages enemies on the consecrated ground for 8 s; used when 2+ enemies are close
- **Holy Light / Flash of Light** — heals an ally under 45% (Flash when under 25%)
- **Divine Shield** — immune for 8 s below 20% health (2 min cooldown)
- **Blessing of Protection** — makes an endangered Healer, Caster or Shaman immune for 6 s
- **Lay on Hands** — once per battle, fully heals an ally under 15% for all the Paladin's mana
- **Hammer of Justice** — 3 s stun that interrupts casters first
- **Devotion Aura** — allies nearby take 10% less damage (auras don't stack)
- **Seal of Wisdom** — melee swings return a little mana

Divine Shield and Blessing of Protection cause 60 s of Forbearance. Every effect is undone when it ends or the
Paladin dies (`paladin_release`). Build with `--no-overrides` to get the original behaviour.
