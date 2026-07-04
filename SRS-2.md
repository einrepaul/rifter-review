# Software Requirements Specification (SRS)
## Rifter — A Dimension-Hopping Action RPG

| | |
|---|---|
| **Project** | Rifter |
| **Studio** | Marquee Studios |
| **Document** | SRS v1.1 |
| **Last updated** | 2026-07-04 — player sprite + hub rendering session |
| **Engine** | Flutter + Flame |
| **Status** | Pilot episode in development (Phase 1–2) |
| **Note** | This is the single source of truth. ROADMAP.md is retired. |

---

# 1. Introduction

## 1.1 Purpose
This document specifies the functional, non-functional, and architectural requirements for **Rifter**, a single-player mobile action RPG. It serves as the authoritative reference for what the system must do, how it is structured, and the constraints under which it is built. It supersedes the informal roadmap for requirements purposes.

## 1.2 Scope
Rifter is a narrative-driven game in which the player controls an original Time-Lord-archetype protagonist (the "Rifter") who travels between universes rendered as fragments of their own shattered identity. The **pilot episode** is set in a Harry Potter-inspired wizarding world; the TARDIS-style hub connects all universes.

**In scope (pilot):** main menu, "Arrival" intro cutscene, TARDIS hub, rift-jump mechanic, first universe chapter, mission + collectible systems, save/load.

**Out of scope (pilot):** additional universes, multiplayer, online services, localization beyond English.

## 1.3 Definitions and Acronyms
| Term | Definition |
|---|---|
| **Hub** | The TARDIS console room — the persistent space between missions |
| **Rift jump** | The mechanic that swaps the player between the hub and a universe world |
| **Universe** | A playable chapter world (e.g. the wizarding world) built from a fragment of the Rifter's identity |
| **VO** | Voice-over — spoken dialogue audio |
| **SFX** | Sound effect — one-shot non-speech audio |
| **Beat** | A single timed unit of a cutscene (panel, line, effect, or transition) |
| **Flame** | The 2D game engine layered on Flutter |
| **flame_tiled** | Flame integration for Tiled map editor (`.tmx`) files |
| **Relic** | Tier-1 collectible: universe-specific lore/cosmetic |
| **Temporal Fragment** | Tier-2 collectible: meta-progression + origin-story unlock |

## 1.4 References
- Flutter (framework), Flame 1.18+ (engine), flame_tiled 1.18+, audioplayers 6.0+, shared_preferences
- Tiled Map Editor (`.tmx` authoring)
- ElevenLabs (TTS voice + SFX generation)
- GDD.md (Game Design Document — narrative, universe, mission design)
- ROADMAP.md (retired — superseded by this SRS + GDD)

## 1.5 Overview
§2 describes the product at a high level. §3 details functional requirements (FR-*), non-functional requirements (NFR-*), the system architecture, data models, and external interfaces. Each requirement carries an implementation status: ✅ done, 🟡 partial, 🔴 not started.

---

# 2. Overall Description

## 2.1 Product Perspective
Rifter is a **standalone mobile application**, not part of a larger system. It is a Flutter app hosting a Flame game via `GameWidget`. The game loop, world simulation, and rendering run inside Flame; menus and overlays run as Flutter widgets layered above the game surface.

## 2.2 Product Functions (summary)
1. Present a main menu with New Game / Continue / Settings.
2. Play a cinematic "Arrival" intro cutscene on first launch.
3. Drop the player into a walkable TARDIS hub.
4. Allow the player to rift-jump from the hub into a universe mission.
5. Provide mission gameplay with objectives, NPCs, dialogue, and collectibles.
6. Reflect progression in the hub (mission states, collected relics/fragments).
7. Persist progress across sessions.

## 2.3 User Characteristics
Single user (the player). The player is expected to be a casual-to-midcore mobile gamer comfortable with touch joysticks, tap-to-advance dialogue, and exploration-based gameplay.

## 2.4 Constraints
- **Platform:** iOS + Android (mobile-first). Landscape orientation enforced.
- **Input:** Touch (primary) + keyboard (desktop/debug).
- **Engine lock-in:** Flutter/Flame 1.18+. A Unity migration is a Phase-4 assessment, not a current requirement.
- **Content:** No licensed IP. The Time-Lord archetype, TARDIS-style device, and universes are original reimaginings, not the BBC *Doctor Who* or Warner Bros. *Harry Potter* properties.
- **Performance:** Target 60 FPS on mid-range mobile devices; asset budget tuned for mobile memory.

## 2.5 Assumptions and Dependencies
- The player grants standard audio permissions (audio focus is managed via `AudioContextConfig.focus = mixWithOthers`).
- All narrative content (VO, SFX, art) is sourced/owned by Marquee Studios.
- The meta-story spine (§3.1.4) is locked; downstream content must not contradict it.

---

# 3. Specific Requirements

## 3.1 Functional Requirements

### FR-1 — Application entry & orientation
**FR-1.1** The application shall launch in **landscape orientation** (left or right). Implemented: orientation locked in `main()`.
**Status:** ✅

**FR-1.2** The application shall boot into a `GameWidget` hosting `RifterGame` with the `mainMenu` overlay initially active and the engine paused until the player begins.
**Status:** ✅

### FR-2 — Main menu
**FR-2.1** The main menu shall display a background painting (`main_menu_bg.png`) with an animated sparkle-glint overlay.
**Status:** ✅

**FR-2.2** The menu shall present three actions:
- **New Game** — always enabled; starts the intro cutscene (if not yet played) or the hub.
- **Continue** — enabled only if a save exists; disabled (muted) otherwise.
- **Settings** — opens an audio/settings panel.

**Status:** ✅ (UI) / 🟡 (Continue gating reads a hardcoded `false`; save integration pending)

### FR-3 — Intro cutscene ("Arrival")
**FR-3.1** The cutscene shall be a data-driven sequence of **beats** (`CutsceneBeat`), each specifying at most: panel asset, voice line, speaker, SFX cue, VO cue, visual effect, and pacing (`durationMs` or `waitForTap`).
**Status:** ✅ (15 beats authored)

**FR-3.2** The cutscene shall crossfade between painted panels and apply visual effects (glitch overlay, lights-up bloom).
**Status:** ✅

**FR-3.3 (Audio-driven pacing)** For voiced beats, the player shall be **unable to advance until the VO completes**. A tap during playback shall be ignored so the weary delivery is not cut off.
**Status:** ✅

**FR-3.4 (Robustness)** The cutscene shall guarantee beat advancement via a **duration-based fallback timer** (`getDuration()`), independent of `onPlayerComplete`, since that callback is unreliable on repeated mobile plays.
**Status:** ✅

**FR-3.5 (Fault tolerance)** Every `.play()` call shall be wrapped in `.catchError()` so a missing audio file cannot corrupt the `AudioPlayer` chain or break subsequent beats.
**Status:** ✅

**FR-3.6 (Race safety)** Beat state shall be managed by a state machine (`_BeatToken` + `_BeatPhase`) such that no beat can double-advance or be advanced by a stale async callback from a prior beat.
**Status:** ✅

**FR-3.7 (Audio mix)** The cutscene shall play VO and SFX on **separate `AudioPlayer` instances** with crossfade support (`_AlternatingPlayers`), and shall play a looping ambient bed that ducks under VO and crossfades seamlessly on loop.
**Status:** ✅

**FR-3.8 (Handoff)** On the final beat, the cutscene shall remove itself and **resume the game engine**, dropping the player into the walkable hub (not a menu).
**Status:** ✅

### FR-4 — Player character
**FR-4.1** The player shall be controllable via an on-screen **joystick** and/or **WASD/arrow keys**, with normalized diagonal movement at a fixed speed.
**Status:** ✅ (movement) / 🟡 (no collision response — see FR-6.3)

**FR-4.2** The player shall be rendered as a 4-directional top-down character sprite consistent with the cutscene's coat/underlit look (panel 3).
**Status:** ✅ (`rifter_spritesheet.png` — 1024×1024, 4×4 grid, 256×256 per frame; rendered at 148×148 world units via `SpriteAnimationComponent`; background removed programmatically; direction-switching on dominant movement axis; animation pauses on idle)

**FR-4.3** The player shall be lockable (movement disabled) during cutscenes and unlocked on handoff.
**Status:** 🟡 (engine-pause approach used; explicit lock not yet implemented)

### FR-5 — TARDIS hub
**FR-5.1** The hub shall render a painted console room (`concept_tardis_hub-3.png`) as the floor/walls at fixed map dimensions (1408×768).
**Status:** ✅ (rendered as `SpriteComponent` at `Vector2(1408, 768)` added before `TiledComponent`; flame_tiled Image Layer limitation worked around; `TiledComponent` not added to scene — used only as data source for object geometry)

**FR-5.2** Hub gameplay geometry shall be authored in Tiled (`tardis_hub_art.tmx`) as named objects: `spawn_point`, `console_interact`, `console_collision`, `wall_collision_*`, `panel_scanner`, `panel_sonic`.
**Status:** ✅

**FR-5.3** The hub shall read the object layer at runtime and instantiate: the player at `spawn_point` (center), static colliders at `*_collision` objects, and interaction triggers at `console_interact` / `panel_*` objects.
**Status:** 🟡 (spawn + colliders wired; triggers commented out)

**FR-5.4** The hub shall place the player spawn at the **center** of the `spawn_point` object (accounting for `anchor: center`).
**Status:** ✅ (spawn reads `obj.x + obj.width/2, obj.y + obj.height/2` in `rifter_game.dart` after `await _hubWorld.waitUntilLoaded()` — Completer pattern used to prevent race condition between `TiledComponent` async load and camera follow)

### FR-6 — Collision & interaction
**FR-6.1** Solid geometry (console, walls) shall be represented as `RectangleHitbox` components with `CollisionType.passive`.
**Status:** ✅

**FR-6.2** The player shall carry a `RectangleHitbox` enabling collision detection.
**Status:** ✅

**FR-6.3 (Collision response)** Collision response implemented.** Axis-based overlap resolution added in `Player._resolveCollisions()` using the 32x32 hitbox (not full sprite bounds). Resolved.
**Status:** ✅

**FR-6.4** The hub's `RiftPortal` shall be positioned at a defined gameplay location and fire `onPlayerNearby` / `onPlayerLeft` callbacks.
**Status:** 🟡 (portal is hardcoded at `(0, -150)`, which is outside the painted map — must be moved to a valid location, e.g. the materialization pad)

**FR06.5** Map boundary containment
**FR-6.5.1** The player shall be unable to move or render beyond the current world's painted background bounds.
**FR-6.5.2** Containment shall be enforced by generated perimeter `StaticCollider` walls (`TardisHubWorld._addBoundaryWalls()`) independent of hand-authored Tiled `wall_collision_*` objects, since the Hub's tiled map has no `wall_collision_bottom` object.
**FR-6.5.3** A position clamp (`Player._clampToMapBounds()`) shall act as a fallback against tunneling or collider gaps.
**FR-6.5.4** The camera shall be bounded to the painted map rectangle via `camera.setBounds()`.
**Status:** 🟡 (hub implemented; PilotWorld bounds pending real map dimensions - see Open Issues)

### FR-7 — Rift jump (world swap)
**FR-7.1** Approaching a rift portal shall reveal an **action button**; activating it shall swap the active world (hub ⇄ pilot) by reassigning `camera.world` and re-targeting `camera.follow`.
**Status:** ✅

**FR-7.2** The swap shall be debounced (no re-trigger for ~500ms).
**Status:** ✅

### FR-8 — Pilot universe & missions
**FR-8.1** The pilot universe shall be a Harry Potter-inspired wizarding world with 5 main + 9 side missions across 4 acts.
**Status:** 🔴 (universe chosen; no content built)

**FR-8.2 (Mission contract)** Each mission shall expose a manifest: `id`, `universe`, `act`, `title`, `gameplay` type, `map` path, `objectives[]`, `collectibles{relics[], fragments[]}`, `exit_rift`, `story_flags[]`.
**Status:** 🔴 (contract designed in workspace; not implemented)

**FR-8.3** Mission 1 ("The Letter") map (`act1_mission1.tmx`) shall be loadable into `PilotWorld`.
**Status:** 🔴 (map built in workspace; not wired)

**FR-8.4** The mission system shall track objective completion states and expose them to the hub.
**Status:** 🔴

### FR-9 — Collectibles
**FR-9.1 (Tier 1 — Universe Relics)** Each universe shall scatter universe-specific relics unlockable by exploration or side-quest completion, granting codex entries, cosmetic skins, or story dialogue.
**Status:** 🔴

**FR-9.2 (Tier 2 — Temporal Fragments)** Rare fragments, scattered across all universes, shall grant meta-progression (TARDIS upgrades, sonic-screwdriver abilities) and origin-story chapter unlocks.
**Status:** 🔴

### FR-10 — Meta-story layer
**FR-10.1** The narrative spine shall treat universes as **fragments of the Rifter's shattered identity**, with a pursuer as the active antagonist. (Design lock.)
**Status:** ✅ (locked in GDD.md — see §2)

**FR-10.2** A universe journal / codex shall track visited worlds, collected items, and unlocked story chapters.
**Status:** 🔴

### FR-11 — Persistence (save/load)
**FR-11.1** The system shall persist player progress (mission states, collected items, story flags, intro-played flag) using `shared_preferences`.
**Status:** 🔴

**FR-11.2** "Continue" shall be enabled iff a save exists; otherwise disabled.
**Status:** 🟡 (UI gating present; save check hardcoded `false`)

### FR-12 — Settings
**FR-12.1** The settings panel shall expose audio toggles (music, SFX) at minimum.
**Status:** 🟡 (panel stubbed)

---

## 3.2 Non-Functional Requirements

### Performance
**NFR-P1** The game shall maintain **≥60 FPS** on mid-range mobile hardware (target: 2020-era device) during hub traversal and cutscenes.
**NFR-P2** Audio playback shall incur no perceptible latency on beat triggers (<150 ms).
**NFR-P3** Asset bundle size shall remain mobile-appropriate (cutscene art + audio < 50 MB combined budget guideline).

### Reliability
**NFR-R1** The game shall not crash on a missing audio asset (handled via `catchError`).
**NFR-R2** The cutscene shall never deadlock on a missing VO file (fallback timer guarantees advancement).
**NFR-R3** No beat may double-advance (enforced by `_BeatToken` validity).

### Usability
**NFR-U1** All primary input shall be achievable via touch (no keyboard required on mobile).
**NFR-U2** Cutscene dialogue shall be skippable line-by-line without cutting off audio mid-word.
**NFR-U3** The hub shall orient the player visually to the next objective (rift portal prominence).

### Portability
**NFR-PO1** Shall run on iOS and Android; orientation locked to landscape.
**NFR-PO2** Shall be buildable from `main`/`dev` branches with `flutter pub get && flutter run`.

### Maintainability
**NFR-M1** Cutscene content shall be editable as data (`arrival_scene.dart` beat list) without code logic changes.
**NFR-M2** Hub geometry shall be editable in Tiled without code changes (object names drive runtime behavior).
**NFR-M3** Audio files shall be declarable via a single pubspec folder entry (`assets/audio/`) to avoid per-file drift.

### Aesthetics
**NFR-A1** Visual identity: dark, atmospheric, painterly; warm amber focal glows against cool teal/navy fields.
**NFR-A2** Palette continuity shall be maintained across menu, cutscene, and hub.

---

## 3.3 System Architecture

### 3.3.1 Layered structure
```
┌──────────────────────────────────────────────┐
│  Flutter UI (overlays)                        │  MainMenuOverlay, RiftHubOverlay, Settings
│  via GameWidget.overlayBuilderMap             │
├──────────────────────────────────────────────┤
│  RifterGame (FlameGame)                       │  owns worlds, camera, joystick, HUD, world-state
│   ├─ CameraComponent (follows active player)  │
│   ├─ TardisHubWorld (World)                   │  painted bg + Tiled objects + player + portal
│   ├─ PilotWorld (World)                       │  (placeholder, will host missions)
│   ├─ HUD: Joystick, ActionButton, TardisBtn   │
│   └─ Overlays: arrivalCutScene, riftHub       │
├──────────────────────────────────────────────┤
│  Cutscene subsystem (ArrivalCutscene widget)  │  beat state machine + audio mix
├──────────────────────────────────────────────┤
│  Services (planned)                           │  AudioService, SaveService (Phase 2/3)
├──────────────────────────────────────────────┤
│  Assets                                       │  images/, audio/{vo,sfx}, tiles/*.tmx, maps/
└──────────────────────────────────────────────┘
```

### 3.3.2 Component inventory (current code)
| File | Role |
|---|---|
| `main.dart` | App entry, orientation lock, overlay registration, cutscene handoff (`resumeEngine`) |
| `rifter_game.dart` | Game root; world swap, camera follow, spawn-point resolution, HUD |
| `worlds/hub/tardis_hub_world.dart` | Painted bg `SpriteComponent` + Tiled object parsing + `StaticCollider` |
| `worlds/pilot/pilot_world.dart` | Universe world (placeholder rectangle) |
| `components/player/player.dart` | Movement (joystick + keyboard), `RectangleHitbox`, 4-directional `SpriteAnimationComponent`, idle pause |
| `components/rift_portal/rift_portal.dart` | Proximity portal, nearby/left callbacks |
| `components/hud/{action,tardis}_button.dart` | HUD buttons |
| `components/sparkle_overlay.dart` | Animated menu glints |
| `screens/main_menu_overlay.dart` | Main menu |
| `screens/rift_hub_overlay.dart` | Universe-select panel |
| `cutscene/{arrival_cutscene,arrival_scene,cutscene_beat}.dart` | Cutscene system |

### 3.3.3 Key data flows
**Title → Hub:** `mainMenu` overlay → `arrivalCutScene` overlay (engine paused) → beats play → final beat → `resumeEngine()` → walkable hub visible.

**Hub → Mission:** approach `RiftPortal` → `ActionButton` appears → press → `_jumpToPilotWorld()` → `camera.world = _pilotWorld` → `camera.follow(pilot player)`.

**Cutscene beat lifecycle:** `_runBeat` plays VO/SFX/effects → VO-gated (`_BeatPhase.playingVo`) → on completion (`onPlayerComplete` OR fallback timer) → `_BeatPhase.waitingForTap` → breath delay → `_advanceBeat` → next beat.

---

## 3.4 Data Models

### 3.4.1 `CutsceneBeat`
```
type: BeatType { black, voiceover, panelTransition, dialogue, pause, effect, handoff }
text, speaker: String?
durationMs: int?           (null ⇒ waitForTap)
panelAsset, sfxKey, voKey, effectKey: String?
waitForTap: bool (derived: durationMs == null)
```

### 3.4.2 Tiled hub object schema (`tardis_hub_art.tmx`)
| Object name | Purpose | Runtime handling |
|---|---|---|
| `spawn_point` | Player spawn (center) | Sets `player.position` to center |
| `console_interact` | Mission-select trigger | (stubbed — to wire) |
| `console_collision` | Solid console | `StaticCollider` |
| `wall_collision_{left,right,top}` | Solid walls | `StaticCollider` |
| `panel_scanner`, `panel_sonic` | Flavor triggers | (stubbed — to wire) |

### 3.4.3 Mission manifest (planned, FR-8.2)
```
mission:
  id, universe, act, title, gameplay, map, tile_size
  objectives: [{ id, done }]
  collectibles: { relics: [], fragments: [] }
  exit_rift: { point: {x,y} }
  story_flags: []
```

---

## 3.5 External Interfaces

### 3.5.1 Audio
- **VO** — `.mp3`, `assets/audio/vo/`, played via dedicated `AudioPlayer`, duration-gated.
- **SFX** — `.mp3`, `assets/audio/sfx/`, played via alternating players with crossfade.
- **Ambient** — `.wav`, looped with duck-under-VO + seamless crossfade chain.

### 3.5.2 Art assets
- **Paintings** — `.png`, `assets/images/`, rendered as `SpriteComponent` (flame_tiled Image Layer workaround).
- **Tiled maps** — `.tmx`, `assets/tiles/`, loaded via `TiledComponent.load(..., prefix: 'assets/tiles/')`.

### 3.5.3 Persistence
- `shared_preferences` (key-value) for flags and progression.

---

## 3.6 Open Issues / Known Defects
1. **FR-6.3 — No collision response.** Player passes through `StaticCollider` hitboxes. Detection exists; position-revert logic missing in `player.update`. **Next priority.**
2. **FR-6.4 — Stale `RiftPortal` position.** Hardcoded at `(0, -150)` (outside the painted map). Must be moved to a valid Tiled object position.
3. **FR-5.3 — Hub triggers stubbed.** `console_interact`, `panel_scanner`, `panel_sonic` commented out.
4. **FR-11.1 — No save system.** `Continue` reads hardcoded `false`.
5. **Spritesheet depth layering.** Rifter sprite renders above the hub light beam (flat `SpriteComponent` background has no layer depth). Phase 4 polish — split painting into bg + fg layers.
6. **Branch hygiene.** Hub work not yet merged to `dev`/`main`.
7. **FR-6.5** - PilotWorld has no camera/boundary bounds yet.** Placeholder world has no real map size: `_jumpToPilotWorld()` has a TODO for `camera.setBounds()` once dimensions exist.

---

# Appendix A — Implementation Status Summary

| Area | Status | Notes |
|---|---|---|
| Foundation (Phase 0) | ✅ | Stack, scaffold, structure |
| Rift jump (Phase 1) | ✅ | World swap working |
| Main menu (1.5) | ✅ | Sparkles, nav |
| Intro cutscene (1.5) | ✅ | Robust state machine, all audio |
| Cutscene → hub handoff | ✅ | `resumeEngine()` |
| TARDIS hub rendering | ✅ | Painted bg + Tiled objects |
| Hub spawn (centered) | ✅ | `rifter_game.dart` |
| Collision detection | ✅ | Hitboxes present |
| Collision response | 🔴 | Player moves through walls — next priority |
| Rifter sprite | ✅ | `rifter_spritesheet.png` 4-dir walk, idle pause, transparent bg |
| Hub interaction triggers | 🟡 | Stubbed |
| Save/load | 🔴 | Not started |
| Mission system | 🔴 | Not started |
| Collectibles | 🔴 | Not started |
| Meta-story layer | 🔴 | Spine locked; systems pending |

---

# Appendix B — Glossary of Design Locks
1. **No pre-rendered video for cutscenes.** Illustrated panels + in-engine handoff only.
2. **Audio drives cutscene pacing.** VO cannot be cut off mid-word.
3. **Hub = art-backed.** Static painting + invisible collision/triggers (not modular tiles).
4. **Meta-story spine.** Universes are fragments of the Rifter's identity; a pursuer is the antagonist.
5. **No licensed IP.** Original reimaginings only.
