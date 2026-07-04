# Game Design Document (GDD)
## Rifter — A Dimension-Hopping Action RPG

| | |
|---|---|
| **Project** | Rifter |
| **Studio** | Marquee Studios |
| **Document** | GDD v1.0 |
| **Last updated** | 2026-07-04 |
| **Companion doc** | SRS.md (engineering requirements) |

> This document owns all narrative, world, mission, and design decisions. The SRS owns all software requirements. Do not contradict this document in code without updating it first.

---

# 1. Game Overview

**Rifter** is a single-player mobile action RPG in which the player controls a lone time-traveler — an original Time-Lord-archetype protagonist — who jumps between universes built from fragments of their own shattered identity. Each universe is dressed in the shape of familiar fiction. The rifter travels alone, hunted by an unknown pursuer, collecting Temporal Fragments to piece themselves back together.

**Genre:** Action RPG / narrative adventure
**Platform:** iOS + Android, landscape orientation
**Engine:** Flutter + Flame
**Tone:** Cinematic, atmospheric, lonely. Dry wit born of exhaustion. Stakes are personal, not world-ending — at least not yet.

---

# 2. Meta-Story Spine
> **LOCKED.** Nothing in any universe, cutscene, or dialogue may contradict this section without a deliberate update here first.

## 2.1 Who the Rifter is
An original character built on the Time-Lord-wanderer archetype — regeneration-capable, time/space travel, a personal travel device (naming TBD — not "TARDIS"), dry wit born of loneliness. Explicitly **not** a variant or alternate version of any licensed character. Own name, own identity (both TBD — open design thread).

## 2.2 What the universes are
Not real alternate dimensions. Not a neutral simulation. **Fragments of the Rifter's own shattered identity**, dressed in the shape of familiar fiction (Harry Potter-inspired wizarding world as pilot; future genres TBD). The worlds are simultaneously "real" (lived-in, dangerous, consequential) and "fictional" (made of story-material), because that duality *is* the answer to the game's central mystery — not a contradiction to resolve later.

## 2.3 Why the Rifter jumps
**Primary:** A search — piecing their own scattered self back together, one Temporal Fragment at a time, universe by universe.

**Secondary:** Pursuit — something in the rift network does not want those fragments reassembled and is actively working to stop them. The pursuer's identity and motive are open design threads. Candidate: the entity or event responsible for the original fragmenting.

## 2.4 What the Rifter knows going in
**Partial/selective memory loss** — not a blank-slate amnesiac, not a fully knowing fugitive.

- **Knows:** They've been fragmented. Something is actively hunting them. They must find the fragments.
- **Doesn't know:** Who they were before. What caused the fragmenting. Who the pursuer is.

This is the knowledge-state baseline for all dialogue writing, including the intro cutscene. The rifter speaks with urgency and confidence from the first scene — but not omniscience.

## 2.5 Tonal differentiator
Rifter's worlds are built from *other people's* stories colliding with the Rifter's psyche — not self-authored fiction. The rifter travels **alone**, with no co-op partner softening the isolation. Lean into loneliness and pursuer-driven tension as the things that make this distinct from comparable media (Split Fiction, etc.).

## 2.6 Open design threads
| Thread | Status |
|---|---|
| Rifter's name | Not yet decided |
| Rifter's travel device name | Not yet decided ("TARDIS-like" is placeholder) |
| Pursuer identity/motive | Open — candidate: entity responsible for original fragmenting |
| Hub state 3 "Whole(r)" — does the pursuer prevent full reassembly? | Open |

---

# 3. Visual & Audio Identity

## 3.1 Palette (locked)
- **Primary:** Deep navy / charcoal / blue-black
- **Focal glow:** Warm amber / orange — console light, underlit coat edges
- **Ambient rim:** Cool teal / green
- **Accent:** Purple — rift portals, Temporal Fragment pads
- **Text/UI:** Off-white `#E8E6DC`, amber `#FFC869`

Palette continuity is required across: main menu, cutscene panels, hub painting, player sprite, UI overlays.

## 3.2 Art style
Hand-painted / painterly. Not pixel art. Pre-rendered / AI-generated static art for backgrounds and cutscene panels; sprite sheets for characters. Top-down perspective throughout.

## 3.3 Player sprite
- `rifter_spritesheet.png` — 1024×1024px, 4×4 grid, 256×256 per frame
- Row 0: walk DOWN · Row 1: walk UP · Row 2: walk LEFT · Row 3: walk RIGHT
- Rendered at 148×148 world units; hitbox 32×32 centered
- Background removed programmatically (saturation-based masking)
- Idle: animation pauses on current frame

## 3.4 Audio profile
- **VO:** ElevenLabs Eleven v3, deep/serious male, weary-drifter character
  - Stability 30–40% · Similarity 75–80% · Style 15–25%
  - Speed by group: shock 0.88–0.92 · dread 0.78–0.85 · resolve 0.85–0.90
- **SFX:** ElevenLabs Sound Effects generator
- **Ambient:** Looped `.wav`, ducks under VO
- **Design lock:** Audio drives cutscene pacing — VO cannot be cut off mid-word

---

# 4. Hub — The Rift Hub

## 4.1 Description
The rifter's personal travel device interior — a console room that serves as the persistent space between missions. Painted, atmospheric, top-down. The space feels lived-in but damaged at the start and grows more whole as the rifter recovers Temporal Fragments.

## 4.2 Hub states (4 total)
| State | Trigger | Visual direction |
|---|---|---|
| 0 — Fractured | Game start / after intro cutscene | Damaged panel, smoke, dim/uneven lighting, mostly dark |
| 1 — Stabilizing | First Temporal Fragment milestone (~25%) | Damage repaired, lighting evens out |
| 2 — Reassembling | Mid milestone (~50–75%) | New areas visible, warmer light, hints of personal objects |
| 3 — Whole(r) | Final/near-final milestone | Full lighting, lived-in — likely never "perfect" given pursuer thread |

Transitions reuse the glitch-flicker motif from the intro cutscene.

## 4.3 Hub geometry (Tiled objects in `tardis_hub_art.tmx`)
| Object | Purpose |
|---|---|
| `spawn_point` | Player spawn — center of purple hexagonal pad |
| `console_interact` | Mission-select trigger (stub) |
| `console_collision` | Solid console block |
| `wall_collision_left/right/top` | Solid wall bounds |
| `panel_scanner` | Flavor interaction (stub) |
| `panel_sonic` | Flavor interaction (stub) |

## 4.4 Depth layering note (open)
The hub background is a single flat `SpriteComponent`. The rifter sprite renders above the light beam in the painting — visually incorrect but acceptable for pilot. Phase 4 polish: split painting into bg + fg layers, render rifter between them.

---

# 5. Intro Cutscene — "Arrival"

## 5.1 Purpose
First scene of the game. Plays on first New Game before mission select is available. Establishes the rifter's voice and knowledge state per §2.4. Pursuer is implied only — never named or shown.

## 5.2 Script
> *Black screen. Silence, then: a low electronic whine, irregular, like something straining.*
>
> **RIFTER (V.O.)** *(quiet, breathless, like they've been running)*
> Not again. Not *now—*
>
> *A spark of light — small, harsh, blue-white — flashes once across the black. Cut to: the hub interior, dim, resolving into focus. Something on the far wall sparks and dims, smoke curling from a cracked panel.*
>
> *The rifter materializes off-center, stumbling forward a step before catching themselves on a console. They stay a moment, breathing hard, looking back over their shoulder at nothing. Empty room. Whatever was behind them didn't follow. This time.*
>
> **RIFTER** *(to no one, low)*
> ...Still in one piece. Mostly.
>
> *They look down at their own hands. A flicker — just for a frame — like their image glitches, then steadies.*
>
> **RIFTER**
> I don't know who did this to me. Don't remember enough to *guess.*
>
> *(beat, glancing at the damaged panel)*
>
> But I remember enough to know I'm not whole. And something out there—
>
> *(trails off, doesn't finish it)*
>
> *They push off the console, look around the hub for the first time — taking it in like it's unfamiliar, but theirs.*
>
> **RIFTER**
> So. Pieces to find. Best get started.
>
> *Lights in the hub come up fully. Mission select interface activates. Fade to gameplay.*

## 5.3 Beat structure
16 beats across 3 phases:
- **Phase 1 (Beats 1–7):** Painted panels — black screen, VO, spark, damaged hub, glitch materialize
- **Phase 2 (Beats 8–15):** Live in-engine hub — rifter as real sprite, remaining dialogue, lights-up
- **Beat 16:** Handoff — control released to player

## 5.4 Implementation notes
- Data-driven `CutsceneBeat` list in `arrival_scene.dart` — editable without logic changes
- Tap-driven for dialogue/VO beats; auto-timed for transitions/effects
- Taps ignored on auto-timed beats (no accidental skips)
- VO gated — player cannot advance during playback
- Fallback timer guarantees advancement if `onPlayerComplete` fires late
- Glitch: one-frame opacity stutter on rifter sprite
- VO optional — lines work identically as text-only if audio not in budget

---

# 6. Collectibles System

## 6.1 Tier 1 — Universe Relics
Universe-specific. Found by exploring, completing side quests, or hidden in mission areas.

| Effect type | Example (wizarding world) |
|---|---|
| Codex / lore unlock | Hogwarts acceptance letter |
| Cosmetic skin | House badge |
| Story dialogue | Chocolate Frog card (famous witches/wizards lore) |

## 6.2 Tier 2 — Temporal Fragments
Rarer. Hidden across **all** universes. Tied to the rifter's personal arc and identity-reassembly.

| Effect type | Example |
|---|---|
| Gameplay upgrade | Rift Hub fuel cell → faster rift recharge |
| New ability | Travel device attachment → stun enemies |
| Origin story unlock | Time crystal → reveals a chapter of backstory |

Temporal Fragment milestones trigger hub state transitions (§4.2).

---

# 7. Pilot Universe — Wizarding World
> Inspired by Harry Potter and the Sorcerer's Stone. Original reimagining — no licensed IP used.

## 7.1 Structure
Beat-by-beat adaptation across 4 acts, mixing missions and cutscenes. Where a story beat has no natural player agency, it is a **cutscene** rather than a forced mission.

## 7.2 Act I — The Muggle World
| Order | Beat | Type | Format |
|---|---|---|---|
| 1 | Dumbledore/McGonagall/Hagrid leave baby at the Dursleys' | Cutscene | — |
| 2 | 10 years later — miserable life under the stairs | Cutscene | — |
| 3 | Zoo trip (talks to snake, vanishes the glass) | Main | Choice |
| 4 | Letters arriving, Dursleys flee | Cutscene | — |
| 5 | Hut on the Rock (Hagrid arrives, letter delivered) | Main | Timed |

## 7.3 Act II — The Wizarding World
| Order | Beat | Type | Format |
|---|---|---|---|
| 1 | Hagrid takes Harry to Diagon Alley | Main | Exploration |
| 2 | Gringotts — vault 687 + mysterious vault 713 | Side | Stealth |
| 3 | Getting the wand at Ollivander's | Cutscene | — |
| 4 | Platform 9¾, boarding the train | Main | Timed |
| 5 | On the train — meets Ron, Hermione, sees Draco | Cutscene | — |

## 7.4 Act III — Hogwarts: First Term
| Order | Beat | Type | Format |
|---|---|---|---|
| 1 | Arrival by boat, Great Hall, Sorting Hat | Main | Choice |
| 2 | Neville's toad (Trevor missing) | Side | Exploration |
| 3 | First flying lesson, Malfoy/Neville incident | Main | Action |
| 4 | Halloween — troll in the dungeon | Main | Combat |
| 5 | Quidditch match vs. Slytherin (broom jinxed) | Side | Timed |
| 6 | Mirror of Erised in the forbidden corridor | Side | Stealth |

## 7.5 Act IV — The Philosopher's Stone
| Order | Beat | Type | Format |
|---|---|---|---|
| 1 | Hagrid's dragon Norbert, nighttime detention setup | Side | Stealth |
| 2 | Detention in the Forbidden Forest | Side | Survival |
| 3 | Trio realize the Stone is in danger, sneak past Fluffy | Cutscene | — |
| 4 | The gauntlet — Devil's Snare, flying keys, chess, potions | Main | Puzzle |
| 5 | Quirrell/Voldemort confrontation over the Stone | Main | Combat |
| 6 | Hospital wing recovery, end-of-year feast, house cup | Cutscene | — |

## 7.6 Map assets (built, not yet wired)
- `tardis_hub.tmx` + `tardis_hub_art.tmx` — hub console room
- `act1_mission1.tmx` + `act1_mission1_art.tmx` — Muggle street "The Letter"
- Palette reference: `concept_dark_night.png` — blue-black + warm light pools

---

# 8. Design Decisions Log
> Running record of locked design calls. Do not contradict without updating here.

| Decision | Choice | Rationale |
|---|---|---|
| Camera / perspective | Top-down, whole game | Consistent across all universes |
| Are universes "real" or fictional? | Both simultaneously — fragments of the Rifter's shattered identity | The duality is the answer, not a contradiction |
| Rifter knowledge state | Partial/selective memory loss | Avoids blank-slate amnesiac and fully-knowing-fugitive failure modes |
| Cutscene form | Illustrated panels + in-engine handoff (no pre-rendered video) | Avoids video file sizes; editable as data |
| Audio drives cutscene pacing | VO cannot be cut off mid-word | Preserves weary delivery; tap-gating enforced |
| Hub background approach | Single flat `SpriteComponent` (flame_tiled Image Layer workaround) | flame_tiled does not render Image Layers |
| Hub states | 4 total (Fractured/Stabilizing/Reassembling/Whole(r)) | Keeps art budget scoped; each transition is celebrated |
| Hub state trigger | Temporal Fragment milestones (not Act completion) | Fragments are the identity-reassembly track |
| Rifter staging in non-participant scenes | Stands in shadow at edge of frame | Cheap (idle sprite), reads instantly as "observing" |
| Main menu on first launch | Always show menu, even first launch | Avoids two separate launch flows; cutscene is the real cold open |
| Sparkle overlay | ~6–10 fixed glint points on shard edges, independently randomized timing | Never reads as a synced loop; cheap, mobile-friendly |
| No licensed IP | Original reimaginings only | Legal safety; the time-lord archetype and wizarding world are archetypes, not BBC/WB properties |
| Player sprite style | Hand-painted, 4-directional, 4 frames per direction | Matches painterly hub environment; pixel art would clash |
| Spritesheet background removal | Saturation-based masking (not color key) | Handles both checker colors without affecting warm amber character pixels |
| Hub depth layering | Rifter renders above light beam (Phase 4 fix: split bg/fg) | Acceptable for pilot; correct fix deferred |
| TiledComponent visibility | Not added to scene — used as data source only | Object layer rendered visibly when added; only geometry needed at runtime |
| Spawn-point timing | `Completer<void>` / `waitUntilLoaded()` in hub world | Prevents race condition between TiledComponent async load and `camera.follow` |
| Map boundary handling | Generated perimeter colliders + player-position clamp + camera bounds | Belt-and-suspenders against Tiled authoring gaps (hub map is missing a bottom wall object) and tunneling at high speed |