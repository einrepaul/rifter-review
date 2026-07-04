# Rifter — Game Development Roadmap
> A Marquee Studios game · An original Time-Lord-archetype protagonist · Built with Flutter + Flame

---

## Meta-story spine

Core narrative premise, locked in during pre-production design discussion. This drives the intro cutscene, hub framing, dialogue tone, and how Temporal Fragments pay off later — write nothing in Phase 3 that contradicts this without updating it here first.

**Who they are:** An original character built on the Time-Lord-wanderer archetype (regeneration-capable, time/space travel, a TARDIS-*like* device — naming TBD, see open question below, dry wit born of loneliness) — explicitly **not** framed as a variant or alternate version of an existing licensed character. Own name, own identity, to be determined.

**What the universes are:** Not real alternate dimensions, not a neutral simulation — **fragments of the rifter's own shattered identity**, dressed in the shape of familiar fiction (Harry Potter, and future genres beyond it). The worlds are simultaneously "real" (lived-in, dangerous, consequential) and "fictional" (made of story-material), because that duality *is* the answer to the game's core mystery — not a contradiction to resolve later.

**Why they jump:** Primarily a **search** — piecing their own scattered self back together, one fragment at a time, universe by universe. Secondary pressure layer: **pursuit** — something in the rift network does not want those fragments reassembled, and is actively working to stop them. The pursuer's identity/motive is an open design thread (candidate: the entity or event responsible for the original fragmenting).

**What the rifter knows, going in:** Partial/selective memory loss — not a blank-slate amnesiac, not a fully knowing fugitive. The rifter is aware *that* they've been fragmented and *that* something is actively hunting them, so they can speak with urgency and confidence from the first scene. What they don't know: who they were before, and what caused the fragmenting in the first place — that's the mystery the player uncovers alongside them, fragment by fragment. This is the knowledge-state baseline for all dialogue writing, including the intro cutscene.

**Tonal differentiator vs. comparable media (Split Fiction et al.):** Rifter's worlds are built from *other people's* stories colliding with the rifter's psyche, not self-authored fiction — and the rifter travels alone, with no co-op partner softening the isolation. Lean into loneliness and the pursuer-driven tension as the things that make this distinct.

---

## Phase 0 — Foundation
**Week 1–2**

- [x] **GitHub repo setup** — Init Flutter project, add Flame dependency, configure .gitignore, branch strategy
- [x] **Project folder structure** — Screens, components, game worlds, assets, services
- [x] **Flame game loop scaffold** — FlameGame base, camera, world layers, game states

---

## Phase 1 — Core mechanic: the Rift jump
**Week 3–5**

- [x] **Player character (original Time-Lord-archetype protagonist)** — Sprite, movement, basic animations, touch controls
- [x] **Rift jump mechanic** — Portal trigger, screen transition, world swap system
- [ ] **Rift Hub screen** *(in active redesign)* — Between-mission base, mission select, player stats, 4-state evolving background art (see Hub States below)
- [x] **Main menu screen** — New Game / Continue / Settings, gates the intro cutscene (see Main Menu below). **Fully wired** to the cutscene as of this session — see Cutscene system entry in Phase 2 and Bug fixes log below.
- [ ] **Lock device orientation to landscape (native level)** — `AndroidManifest.xml` (`android:screenOrientation="landscape"`) + iOS `Info.plist` (`UISupportedInterfaceOrientations`). Currently only a temporary `SystemChrome.setPreferredOrientations` override in `main.dart` for testing — not yet the permanent native-level lock. See orientation decision in the log below.

---

## Phase 2 — First universe: pilot chapter
**Week 6–10**

- [x] **Choose pilot universe** — Harry Potter and the Sorcerer's Stone · beat-by-beat film adaptation across 4 acts, mixing missions and cutscenes
- [ ] **World tilemap + art style** — Tiled map integration, environment assets, unique universe palette
- [ ] **Mission system** — Objectives, completion states, NPC interactions, dialogue
- [x] **Cutscene system** *(core implementation + main-menu wiring done — see Intro Cutscene Script section)* — Data-driven `CutsceneBeat` model, 16-beat `arrivalScene` data, `ArrivalCutscene` sequencer widget with tap-driven + auto-timed beat handling, `AnimatedOpacity` panel crossfades, placeholder glitch/lights-up effect hooks, dialogue box with amber palette (now width-capped/centered for landscape — see below), tap prompt. SFX stubs in place, not yet wired to `audioplayers`. **Wiring to main menu: done** — `arrivalCutScene` registered in `main.dart`'s `overlayBuilderMap`; `MainMenuOverlay._onNewGame()` correctly triggers it; `onComplete` removes the cutscene overlay and adds `riftHub`, engine left paused throughout (mirrors the existing `_onContinue` pattern). Open polish tasks: panel crossfade refinement, glitch shader, skip support.
- [ ] **Collectibles system** — Tier 1 Universe Relics (world-specific lore/cosmetics) + Tier 2 Temporal Fragments (meta Doctor upgrades + origin story unlocks)

---

## Phase 3 — Meta-story layer
**Week 11–14**

- [ ] **Player origin story** — Identity-fragmentation/search narrative + pursuer thread (see Meta-Story Spine above), personal mission arc across universes
- [ ] **Universe journal / codex** — Track visited worlds, collected items, story unlocks
- [ ] **Save system** — Persist player progress, mission states, story flags. Also gates the `introPlayed` flag check currently stubbed as `const introPlayed = false;` in `MainMenuOverlay._onNewGame()`.

---

## Phase 4 — Polish & expand
**Week 15+**

- [ ] **Audio — music & SFX** — Universe-specific soundtracks, sonic screwdriver SFX, ambient audio
- [ ] **Second universe chapter** — New genre, new gameplay style, expanded rift network
- [ ] **Unity migration assessment** — Evaluate if Flame is sufficient or if Unity is needed for scope

---

## Tech stack

| Layer | Choice |
|---|---|
| Language | Dart |
| Game engine | Flame 1.18+ |
| Platform target | Mobile (iOS + Android) |
| Orientation | **Landscape** (decided this session — see log below; native-level lock still pending, see Phase 1) |
| Tilemaps | flame_tiled |
| Audio | audioplayers |
| Save system | shared_preferences |
| Repo | GitHub (private) |

## Branch strategy

| Branch | Purpose |
|---|---|
| `main` | Stable builds only |
| `dev` | Active development |
| `feature/*` | One branch per phase or feature |

## Collectibles system

Two-tier design — universe-specific items + meta rifter progression.

### Tier 1 — Universe Relics
Scattered across each world's open map. Found by exploring, completing side quests, or hidden in mission areas.

| Effect type | Example (Harry Potter) |
|---|---|
| Codex / lore unlock | Hogwarts acceptance letter |
| Cosmetic skin | House badge (Gryffindor, Slytherin, etc.) |
| Story dialogue | Chocolate Frog card (famous witches/wizards) |

### Tier 2 — Temporal Fragments
Rarer. Hidden across ALL universes. Tied to the rifter's personal arc and identity-reassembly (see Meta-Story Spine).

| Effect type | Example |
|---|---|
| Gameplay upgrade | Rift Hub fuel cell → faster rift recharge |
| New ability | Sonic screwdriver attachment → stun enemies |
| Origin story unlock | Time crystal → reveals a chapter of your backstory |

---

## Main menu

Always shown on app launch — including the very first launch — rather than skipping straight into the intro cutscene. Simpler to build (one launch flow, not two), matches platform-standard expectations, and doesn't cost any cinematic impact since the Arrival cutscene itself remains the real cold open the moment "New Game" is tapped.

**Flow (implemented):**
```
App launch
   │
   ▼
Main Menu (Flame overlay: 'mainMenu')
   ├─ New Game ──► (if intro_played == false) ──► overlay 'arrivalCutScene' ──► onComplete ──► overlay 'riftHub'
   │                  (if intro_played == true, later: prompt "overwrite save?" — gated on Save System, Phase 3)
   ├─ Continue ──► (shown/enabled only if a save exists) ──► overlay 'riftHub', at saved state
   └─ Settings ──► overlay 'settings'
```

Implemented via Flame's `overlays` API rather than `Navigator`/routes — `MainMenuOverlay._onNewGame()` removes `'mainMenu'` and adds `'arrivalCutScene'`; `main.dart`'s `overlayBuilderMap` builds `ArrivalCutscene` for that key with an `onComplete` that swaps to `'riftHub'`. Engine stays paused throughout the menu → cutscene → hub-overlay chain, matching the existing `_onContinue` pattern (no `resumeEngine()` call needed since `RiftHubOverlay` is a Flutter UI surface, not live gameplay).

**Dependency flag:** "Continue" isn't wireable until the Save System (Phase 3) exists — menu shell can be built now, but that button stays disabled/hidden until save/load is in place.

**Background art:** AI-generated, reusing the locked blue-black + warm-amber palette from the Act I and hub art bible. Direction: fragmented glowing shards floating in a dark void, evoking shattered memory/identity (ties the very first screen players see back to the Meta-Story Spine) rather than generic sci-fi dressing. No character, no text — kept reusable as a pure backdrop, avoiding the protagonist-vs-pursuer ambiguity issue flagged earlier on the cutscene panel 3 art.

**Mockup status:** Layout/composition approved as a portrait preview (title, subtitle, button hierarchy, negative space). **Open follow-up:** that approval predates the landscape orientation decision — layout has since been made responsive (see Bug fixes log) for landscape, but `main_menu_bg.png`'s crop under `BoxFit.cover` in landscape has not yet been visually confirmed.

**Sparkle polish:**
- ~6–10 fixed glint points, hand-picked to sit on actual reflective shard edges in the image (not randomized positions, to avoid glints appearing on flat/non-shard areas)
- Each glint's timing (fire delay, duration, repeat interval) independently randomized per-point, so the effect never reads as a synced, obviously-looping animation
- Implementation: small glow sprites opacity-pulsed in place, or Flame `ParticleSystemComponent` — cheap, mobile-performance-friendly, no shader work required
- Reusable component — same approach can be applied to other glassy/crystal surfaces in future universes
- **Open follow-up:** whether `kMainMenuGlints` coordinates in `sparkle_overlay.dart` are normalized (0.0–1.0) or fixed-pixel values tied to the original portrait dimensions is unconfirmed — file not yet reviewed. If pixel-based, glints will likely drift off the shard art under the new landscape layout and need converting to normalized coordinates.

---

The hub's background art is not a single static image — it progresses through 4 pre-rendered states as the rifter recovers Temporal Fragments, making identity-reassembly visually felt rather than just tracked in stats. Each transition can reuse the glitch-flicker visual motif from the intro cutscene, tying hub change back to rifter change.

| State | Trigger | Visual direction |
|---|---|---|
| 0 — Fractured | Game start / intro cutscene | Damaged panel, smoke, dim/uneven lighting, mostly dark space |
| 1 — Stabilizing | First Temporal Fragment milestone (~25%) | Damage repaired, lighting evens out, space feels less precarious |
| 2 — Reassembling | Mid milestone (~50–75%) | New areas of the hub visible/usable, warmer light, hints of personal objects/memory appearing |
| 3 — Whole(r) | Final/near-final milestone | Full lighting, lived-in and personal — likely never "perfect," since the pursuer thread probably keeps this unresolved until the ending |

---

## Intro cutscene script — "Arrival"

First-ever scene of the game. Plays before mission select is available, at Hub State 0 (Fractured). Establishes the rifter's voice and knowledge state per the Meta-Story Spine — knows they're fragmented and hunted, doesn't know who they were or why. Pursuer is implied only, never shown.

> **INTRO CUTSCENE — "Arrival"**
>
> *Black screen. Silence, then: a low electronic whine, irregular, like something straining. A beat of total dark.*
>
> **RIFTER (V.O.)** *(quiet, breathless, like they've been running)*
> Not again. Not *now—*
>
> *A spark of light — small, harsh, blue-white — flashes once across the black. Cut to: the hub interior, dim, resolving into focus as if the player's eyes are adjusting. The space is empty. Something on the far wall sparks and dims, smoke curling from a cracked panel.*
>
> *The rifter materializes off-center, stumbling forward a step before catching themselves on a console. They stay there a moment, breathing hard, looking back over their shoulder at the space behind them — at nothing. Empty room. Whatever was behind them didn't follow. This time.*
>
> **RIFTER** *(to no one, low)*
> ...Still in one piece. Mostly.
>
> *They straighten. Look down at their own hands, like checking they're really there. A flicker — just for a frame — like their image glitches, then steadies.*
>
> **RIFTER**
> I don't know who did this to me. Don't remember enough to *guess.*
>
> *(beat, glancing at the damaged panel, the smoke still curling)*
>
> But I remember enough to know I'm not whole. And something out there—
>
> *(trails off, doesn't finish it)*
>
> *They push off the console, look around the hub properly for the first time — taking it in like it's unfamiliar, but theirs.*
>
> **RIFTER**
> So. Pieces to find. Best get started.
>
> *Lights in the hub come up fully — mission select interface activates, panels glowing to life around them. Fade to gameplay / hub UI.*

**Notes for implementation:**
- Glitch-flicker on the rifter sprite is a one-frame opacity/shader stutter, not a full animation — cheap to build.
- Damaged panel/smoke can be baked into the Hub State 0 background art, or layered as a small looping particle effect on top — flagged as an open art-pipeline choice depending on what the AI-generated background actually produces.
- Pursuer is never named or shown — leave the thread fully open for future design work.
- VO is optional — if not in budget, lines work identically as timed text-box cutscene dialogue with no rework needed.

**Implementation status:** **Core implementation complete and wired to main menu.** `cutscene_beat.dart` (data model), `arrival_scene.dart` (16-beat const list), `arrival_cutscene.dart` (sequencer widget) all built and in `lib/cutscene/`. Tap-driven beats use `GestureDetector`; auto-timed beats use `Timer`. Taps ignored on auto-timed beats to prevent accidental skips. Panel crossfades via `AnimatedOpacity`. Glitch and lights-up are placeholder overlays — swap for shader/sprite when ready. SFX keys stubbed throughout, not yet wired to `audioplayers`. **Wire-up: done** — `arrivalCutScene` registered in `main.dart`'s `overlayBuilderMap`, `onComplete` swaps to `'riftHub'`. **Panel art fit:** switched from `BoxFit.cover` to `BoxFit.contain` after cover caused severe crop/zoom on a portrait device (panel art is landscape-aspect, ~16:9). Superseded in practice by the landscape orientation decision below — **open follow-up:** revisit switching back to `cover` once orientation is natively locked, since panel-art and device aspect ratios will be much closer and cover should crop only slightly rather than letterbox. **Dialogue box:** now wrapped in `Center` + `ConstrainedBox(maxWidth: 720)` to stop it stretching edge-to-edge on wide landscape screens. **Open polish tasks:** panel crossfade refinement, real glitch shader/sprite, skip/replay support, SFX wiring.

---

## Pilot universe — Harry Potter and the Sorcerer's Stone

Beat-by-beat adaptation of the film. Where a story beat has no natural player agency, it's a **cutscene** instead of a mission, so the plot stays intact without forcing gameplay onto moments that don't need it.

### Act I — The Muggle World
| Order | Beat | Type | Gameplay/Format |
|---|---|---|---|
| 1 | Dumbledore/McGonagall/Hagrid leave baby Harry at the Dursleys' | Cutscene | — |
| 2 | 10 years later — Harry's miserable life under the stairs | Cutscene | — |
| 3 | Dudley's birthday trip to the zoo (Harry talks to the snake, vanishes the glass) | Main | Choice |
| 4 | Letters from Hogwarts start arriving, Dursleys panic and flee | Cutscene | — |
| 5 | Hut on the Rock (Hagrid arrives, gives Harry his letter, Dudley gets a pig tail) | Main | Timed |

### Act II — The Wizarding World
| Order | Beat | Type | Gameplay/Format |
|---|---|---|---|
| 1 | Hagrid takes Harry to Diagon Alley | Main | Exploration |
| 2 | Gringotts — vault 687, then the mysterious empty vault 713 | Side | Stealth |
| 3 | Getting his wand at Ollivander's | Cutscene | — |
| 4 | Platform 9¾, boarding the train | Main | Timed |
| 5 | On the train — meets Ron, Hermione, sees Draco | Cutscene | — |

### Act III — Hogwarts: First Term
| Order | Beat | Type | Gameplay/Format |
|---|---|---|---|
| 1 | Arrival by boat, the Great Hall, the Sorting Hat | Main | Choice |
| 2 | Neville's toad (Trevor missing — corridor search) | Side | Exploration |
| 3 | First flying lesson, Malfoy/Neville incident | Main | Action |
| 4 | Halloween — the troll in the dungeon | Main | Combat |
| 5 | Quidditch match vs. Slytherin (broom jinxed) | Side | Timed |
| 6 | Mirror of Erised in the forbidden corridor | Side | Stealth |

### Act IV — The Philosopher's Stone
| Order | Beat | Type | Gameplay/Format |
|---|---|---|---|
| 1 | Hagrid's dragon, Norbert, the nighttime detention setup | Side | Stealth |
| 2 | Detention in the Forbidden Forest (cloaked figure, centaur rescue) | Side | Survival |
| 3 | Trio realize the Stone is in danger, sneak past Fluffy | Cutscene | — |
| 4 | The gauntlet — Devil's Snare, flying keys, giant chess, troll, potions riddle | Main | Puzzle |
| 5 | Quirrell/Voldemort confrontation over the Stone | Main | Combat |
| 6 | Hospital wing recovery, end-of-year feast, house cup | Cutscene | — |

---

## Game design decisions (living log)

Running record of design calls made during pre-production discussion, so reasoning isn't lost between sessions.

| Decision | Choice | Rationale |
|---|---|---|
| Camera / perspective | Top-down / isometric, whole game | Matches concept art direction; consistent across all universes, not just the pilot |
| Rift entry framing | Time Lord notices wrongness first (not disorientation, not clean teleport) | Reusable across every universe entry without feeling repetitive; doubles as a natural, in-character vehicle for exposition |
| Are the universes "real" or fictional? | **Resolved** in Meta-Story Spine — both, simultaneously: fragments of the rifter's own shattered identity, dressed as familiar fiction | Superseded the earlier "deliberately ambiguous" placeholder once the full meta-story discussion happened; the duality itself is the answer, not a contradiction to resolve later |
| Rifter staging in scenes they don't participate in | Stands in shadow at the edge of frame, outside the main light source | Cheap to build (idle sprite, no extra animation), reads instantly as "observing, not present," reusable pattern for every universe-opening cutscene |
| Act I, Beat 1 staging reference | `concept_dark_night.png` — Privet Drive, top-down, streetlamp + lit window, envelope on lawn as foreshadowing prop | Locks the night palette (blue-black + warm light pools) as the Act I art bible reference |
| Rifter's knowledge state (amnesia vs. knowing fugitive) | Partial/selective memory loss | Avoids both failure modes: full amnesia leaves the character nothing definite to say early on; full knowing-fugitive gives away the central mystery too soon. Knows they're fragmented and hunted; doesn't know who they were or why |
| First-ever hub appearance (game start) | Full narrative intro cutscene (not cold open, not short materialization) | Sets tone and stakes from minute one; biggest production cost of the three options but justified given this is a mystery-driven game and the hub intro is a one-time, high-value moment |
| Visual rendering approach (3D-look vs. true 3D) | Stay in Flame: pre-rendered/AI-generated 3D-*look* static art, true 2D engine underneath | Flame has no 3D renderer — a real Daxter-style 3D pipeline would mean leaving Flame (Unity territory, already a Phase 4 line item). Pre-rendered art + sprites + manual collision boxes gets a comparable look without forking the engine mid-project |
| Hub background: static vs. evolving | Evolving — multiple hub states, not one fixed image | Pays off the "memory fragments" theme directly: the hub becoming visibly more whole as you recover yourself makes identity-progress *felt*, not just tracked in a stats screen |
| Hub state trigger | Temporal Fragment milestones (not Act completion, not individual story beats) | Temporal Fragments are explicitly the identity-reassembly track already (per Collectibles system); Act completion measures a different axis (finishing a universe, not rebuilding the self) |
| Number of hub states | 4 total — Fractured / Stabilizing / Reassembling / Whole(r) | Keeps the art budget scoped (4 full renders, not an unbounded count that grows every time a new universe is added) while still making each transition a noticeable, celebrated moment rather than an incremental tweak |
| Cutscene system architecture | Data-driven beats (`CutsceneBeat` list), not baked video — painted panels (spark → damaged hub → glitch materialize) play as pure cinematic, then crossfade directly into the **live, in-engine hub** where the rifter is a real positioned sprite | Avoids needing a separate cutscene-only rifter sprite/pose-set — the moment the rifter needs to act (look around, react), they're already the same in-engine character used for the rest of the game. Script stays editable as data, no re-rendering needed for line/timing changes |
| Cutscene advancement model | Tap-driven for dialogue/VO beats; auto-timed (ms duration) for black screen, transitions, effects, handoff | Player agency on reading pace; skip support is clean (jump sequencer to beat 16); VO optional — lines work identically as text boxes with or without audio underneath |
| Cutscene tap guard | Taps ignored on auto-timed beats | Prevents accidental skips during transitions and effect beats; sequencer checks `waitForTap` before advancing on tap |
| Cutscene effect hooks | Placeholder `Container` overlays for glitch and lights-up; keyed by `effectKey` string | Cheap to build now, easy to swap for real shader/sprite later without touching beat data or sequencer logic |
| `doctor` → `rifter` naming cleanup | **Done** — global rename complete across all files | Leftover from the old "Doctor variant" framing the Meta-Story Spine explicitly moved away from |
| Main menu vs. skip-to-cutscene on first launch | Always show menu, even on first-ever launch | Avoids maintaining two separate launch flows (first-launch vs. every-launch) for a one-time benefit; doesn't cost cinematic impact since the cutscene itself remains the real cold open the moment New Game is tapped |
| "TARDIS hub" → "Rift Hub" naming | Renamed | Same IP-distance reasoning as the `doctor`→`rifter` code cleanup — "TARDIS" is leftover Doctor Who-specific language that doesn't fit an original character; "Rift Hub" also ties the name directly to the game's own rift-jump mechanic instead of borrowing someone else's term. **Open follow-up:** the rifter's personal travel device is still described as "TARDIS-like" in the Meta-Story Spine — needs its own name too, not yet decided |
| `tardis_hub_overlay.dart` → `rift_hub_overlay.dart` | **Done** — file, class (`TardisHubOverlay`→`RiftHubOverlay`), and in-UI copy ("TARDIS CONSOLE"→"RIFT HUB", "Rogue Time Lord - Dimension Rifter"→"Fragmented. Hunted. Searching.") all renamed | Same cleanup as the hub-screen task line; this overlay had its own separate instance of leftover Doctor/TARDIS language that hadn't been caught until the actual file was reviewed |
| Hub overlay accent color (purple `0xFF7C3AED`) vs. locked amber/blue-black palette | **Open inconsistency — not yet fixed** | The Rift Hub overlay currently uses purple accents throughout, which doesn't match the amber/blue-black palette locked for Act I, the main menu, and the 4 hub background states. Needs a deliberate decision: align Rift Hub to the existing palette, or confirm purple is an intentional distinct accent for hub UI specifically |
| Device orientation: portrait vs. landscape | **Landscape** | Persistent virtual joystick + separate action button need two-thumb space that's cramped in a narrow portrait frame (same control pattern as Genshin Impact, Brawl Stars, PUBG Mobile — all landscape-only); top-down/isometric camera benefits from the wider horizontal FOV; cutscene panel art was generated at a cinematic ~16:9 ratio, which is landscape-native rather than portrait |
| Cutscene panel `BoxFit` mode | `contain` (interim) | `cover` caused extreme crop/zoom because panel art (~16:9) was being forced into a portrait device frame (~9:20). `contain` letterboxes instead, which reads as intentional cinematic framing against the cutscene's black backdrop. Flagged to revisit `cover` once landscape is natively locked, since the aspect mismatch will be far smaller |
| Dialogue box max-width | Capped at `720px`, centered via `Center` + `ConstrainedBox` | Prevents the box stretching edge-to-edge on wide landscape screens (~2400px) — matches film-subtitle convention of never running a caption box the full width of a widescreen frame, for readability |
| Main menu landscape layout | Responsive sizing (`isLandscape`-branched font size / padding / gaps) instead of wrapping the `Column` in `SingleChildScrollView` | `Spacer` requires bounded height from its parent to resolve layout; `SingleChildScrollView` gives its child unbounded height, so the two are structurally incompatible in the same `Column` — caused a cascading `RenderBox was not laid out` crash loop. Responsive sizing avoids the overflow at its source instead of trying to absorb it after the fact |
| Main menu button column width | Capped at `480px`, centered via `Center` + `ConstrainedBox` | Same edge-to-edge-stretch problem as the dialogue box, on a landscape screen roughly 2.2× the width the original portrait design targeted |

---

## Bug fixes & engineering notes (running log)

| Issue | Root cause | Status |
|---|---|---|
| `_runBeat` Timer crash on compile | Referenced undefined identifier `beatDurationMs` instead of `beat.durationMs` inside the `Duration(milliseconds: ...)` call — the null-check above it correctly used `beat.durationMs`, but the line inside the block dropped the `beat.` prefix | **Fixed** |
| In-game pause/hub button (`TardisButton` → `openHubOverlay()`) silently freezes the game | `RifterGame.hubOverlay` constant is set to `'tardisHub'`, but `main.dart`'s `overlayBuilderMap` only registers a builder for `'riftHub'`. `openHubOverlay()` pauses the engine and adds an overlay key with no matching builder, so nothing renders | **Identified, fix recommended** (`hubOverlay = 'riftHub'`) — not yet confirmed applied in `rifter_game.dart` |
| Leftover Doctor Who-era naming in `rifter_game.dart` | `TardisHubWorld`, `TardisButton`, and the `GameWorld.hub` enum value were never updated when `TardisHubOverlay` → `RiftHubOverlay` was renamed elsewhere | **Flagged, not yet renamed** |
| Cutscene panel art severely cropped/zoomed on portrait device | `BoxFit.cover` + landscape-aspect (~16:9) art forced into a portrait (~9:20) frame — cover scales up to fill the taller dimension, crushing the visible width to a thin centered sliver | **Fixed (interim)** via `BoxFit.contain`; full resolution pending orientation lock (see decisions log) |
| Main menu overflow in landscape (`BOTTOM OVERFLOWED BY 44 PIXELS`) | Fixed-pixel-sized elements (title font, button padding, inter-button gaps) were tuned for portrait height; in landscape the available height shrank enough that the sum of fixed sizes exceeded it, and `Spacer` had already collapsed to zero with nothing left to give | **Fixed** via `isLandscape`-branched responsive sizing |
| Repeating `RenderBox was not laid out` / `NEEDS-PAINT` crash loop after wrapping the menu `Column` in `SingleChildScrollView` | `Spacer` (an `Expanded` under the hood) needs bounded height from its parent to resolve a size; `SingleChildScrollView` deliberately gives its child unbounded height so content can scroll past the viewport — the two are mutually incompatible inside the same `Column`. A still-running repeating animation (likely the tap-prompt pulse or a sparkle glint) kept re-triggering the broken layout every frame | **Fixed** by removing the scroll view in favor of responsive sizing instead |

---

## Open items carried forward

- Apply the `hubOverlay = 'riftHub'` fix in `rifter_game.dart` (not yet confirmed done)
- Full Doctor/TARDIS naming cleanup pass in `rifter_game.dart` (`TardisHubWorld`, `TardisButton`, `GameWorld.hub`)
- Lock orientation natively — `AndroidManifest.xml` + iOS `Info.plist` — currently only a temporary `SystemChrome.setPreferredOrientations` code-level override for testing
- Confirm `sparkle_overlay.dart`'s `kMainMenuGlints` coordinate system (normalized vs. fixed-pixel) and fix if pixel-based, since landscape will have shifted the underlying image's rendered size
- Visually confirm `main_menu_bg.png`'s crop under `BoxFit.cover` in landscape
- Revisit cutscene panel `BoxFit.contain` → `cover` once landscape is natively locked
- Hub overlay accent color (purple) vs. locked amber/blue-black palette — still an open inconsistency
- Rifter's personal travel device ("TARDIS-like" in the spine) still unnamed
- SFX stubs in the cutscene system not yet wired to `audioplayers`
- Cutscene polish: panel crossfade refinement, real glitch shader/sprite, skip/replay support

---

```
lib/
├── main.dart
├── rifter_game.dart        # FlameGame root
├── components/             # reusable game components
│   ├── player/
│   └── rift_portal/
├── worlds/                 # one folder per universe
│   └── pilot/
├── screens/                # Flutter UI screens
│   ├── main_menu.dart
│   ├── rift_hub.dart
│   └── mission_select.dart
├── cutscene/               # data-driven cutscene system
│   ├── cutscene_beat.dart
│   ├── dialogue_box.dart
│   ├── arrival_scene.dart
│   └── arrival_cutscene.dart
├── services/               # save, audio, etc.
└── story/                  # dialogue, codex data
assets/
├── images/
│   └── cutscene/
│       ├── panel_1_spark.png
│       ├── panel_2_damaged_hub.png
│       └── panel_3_glitch.png
├── audio/
└── maps/
```