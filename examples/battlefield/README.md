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
- **Consecration** — damages enemies on the consecrated ground for 8 s, which pulses gold on every damage tick; used when 2+ enemies are close
- **Holy Light / Flash of Light** — heals an ally under 45% (Flash when under 25%)
- **Divine Shield** — immune for 8 s below 20% health (2 min cooldown)
- **Blessing of Protection** — makes an endangered Healer, Caster or Shaman immune for 6 s
- **Lay on Hands** — once per battle, fully heals an ally under 15% for all the Paladin's mana
- **Hammer of Justice** — 3 s stun that interrupts casters first
- **Devotion Aura** — allies nearby take 10% less damage (auras don't stack)
- **Seal of Wisdom** — melee swings return a little mana

Divine Shield and Blessing of Protection cause 60 s of Forbearance. Every effect is undone when it ends or the
Paladin dies (`paladin_release`). Build with `--no-overrides` to get the original behaviour.

## The Druid

The original Druid healed in human form, but its Cat and Bear forms never picked a target or attacked, and the
Bear abilities only existed in a commented-out block. The overrides keep the human-form healing (Regrowth,
Nourish, Innervate) and finish the other two forms:

- **Cat form (damage, Energy):** Rake (bleed), Shred, Ferocious Bite on targets under 25%, Swipe on groups.
  Goes after casting Healers and Casters first.
- **Bear form (tank, Rage):** Growl taunts enemies attacking our Healers/Casters, Swipe hits the target and
  two enemies next to it, Ironskin (-40% damage) under 40% health, Survival Instincts (+30% health) under 25%.
- **Shapeshifting:** leaves human form when another healer is nearby and nobody is below 70% (Bear if enemies
  are already attacking it, Cat otherwise); returns to human form when an ally drops below 50% or no other
  healer is left. Shapeshifting now has a 3-second cooldown so the Druid commits to a form.
- Fixes in the original healer code: Nourish no longer piles onto a target another healer is already healing
  (`_healer_count` typo), and a `_nourish_castig` typo.

## The Caster

The original Caster's create event set up Polymorph, Blink and Blizzard (cooldowns, cast times, mana costs), and
the rest of the game already reacted to them (units avoid sheeped targets, Warriors rush mages casting
Polymorph), but the Caster's step never cast any of the three. The overrides add them:

- **Polymorph** (1 s cast): sheeps the melee unit on the mage, an enemy healer, or a caster nobody on our side
  is hitting, since any damage breaks it. One sheep at a time, never the last enemy, reaches healing range.
- **Blink:** when melee is on the mage and Mana Shield is down, teleports about casting range away from the
  attackers and leaves a Mirror Image behind, which takes over everything that was targeting the mage.
- **Blizzard** (10 s channel): on a spot with 3+ enemies; damages everything in the storm that isn't sheeped
  and stops early once only one enemy is left in it.
- Fixes the long-range target picking, which compared against an uninitialised `maxhp`.

In 300 headless 7 v 7 fights (new Caster on one side, original on the other) the new side won 185.
The game now has its own repository; this copy stays as gm-revive's test case.

## Rogue and Druid stalemates, damage meter, cooldowns

- **Rogue:** a stealthed Rogue only attacked when its side had the numbers, so the last Rogue of a team hid
  forever. It now goes in when it's the last of its side or has waited 12 s in stealth.
- **Druid alone:** with no other healer around it stayed in human form healing itself forever. It now fights
  in Bear or Cat form when nobody needs healing.
- **Damage meter** (key 4): fills in the empty `recount_damage` stub using the `global._recount_*` lists the
  original already created, plus `recount_draw` for a Recount-style panel. Fireballs, Mirror Images, totems
  and heal-over-time ticks are credited to the unit that cast them.
- **Cooldowns:** fills in the empty `job_draw_cooldowns` stub, shown for the selected unit (uses
  `variable_local_get`, which the runtime now implements).
- **J + click** spawns a Paladin (the other classes already had spawn keys).
