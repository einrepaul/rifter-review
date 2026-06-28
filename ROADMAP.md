# Rifter — Game Development Roadmap
> A Marquee Studios game · Themed around The Doctor · Built with Flutter + Flame

---

## Phase 0 — Foundation
**Week 1–2**

- [x] **GitHub repo setup** — Init Flutter project, add Flame dependency, configure .gitignore, branch strategy
- [x] **Project folder structure** — Screens, components, game worlds, assets, services
- [x] **Flame game loop scaffold** — FlameGame base, camera, world layers, game states

---

## Phase 1 — Core mechanic: the Rift jump
**Week 3–5**

- [x] **Player character (The Doctor variant)** — Sprite, movement, basic animations, touch controls
- [x] **Rift jump mechanic** — Portal trigger, screen transition, world swap system
- [x] **TARDIS hub screen** — Between-mission base, mission select, player stats

---

## Phase 2 — First universe: pilot chapter
**Week 6–10**

- [x] **Choose pilot universe** — Harry Potter and the Sorcerer's Stone · 5 main missions + 9 side quests mapped across 4 acts
- [ ] **World tilemap + art style** — Tiled map integration, environment assets, unique universe palette
- [ ] **Mission system** — Objectives, completion states, NPC interactions, dialogue
- [ ] **Collectibles system** — Tier 1 Universe Relics (world-specific lore/cosmetics) + Tier 2 Temporal Fragments (meta Doctor upgrades + origin story unlocks)

---

## Phase 3 — Meta-story layer
**Week 11–14**

- [ ] **Player origin story** — Rogue Time Lord backstory, personal mission arc across universes
- [ ] **Universe journal / codex** — Track visited worlds, collected items, story unlocks
- [ ] **Save system** — Persist player progress, mission states, story flags

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

Two-tier design — universe-specific items + meta Doctor progression.

### Tier 1 — Universe Relics
Scattered across each world's open map. Found by exploring, completing side quests, or hidden in mission areas.

| Effect type | Example (Harry Potter) |
|---|---|
| Codex / lore unlock | Hogwarts acceptance letter |
| Cosmetic skin | House badge (Gryffindor, Slytherin, etc.) |
| Story dialogue | Chocolate Frog card (famous witches/wizards) |

### Tier 2 — Temporal Fragments
Rarer. Hidden across ALL universes. Tied to the Doctor variant's personal arc.

| Effect type | Example |
|---|---|
| Gameplay upgrade | TARDIS fuel cell → faster rift recharge |
| New ability | Sonic screwdriver attachment → stun enemies |
| Origin story unlock | Time crystal → reveals a chapter of your backstory |

---

## Pilot universe — Harry Potter and the Sorcerer's Stone

### Act I — The Muggle World
| Type | Mission | Gameplay |
|---|---|---|
| Main | The letter | Stealth |
| Side | Dudley's birthday | Choice |
| Side | Hut on the rock | Timed |

### Act II — The Wizarding World
| Type | Mission | Gameplay |
|---|---|---|
| Main | Diagon Alley | Exploration |
| Side | Gringotts vault | Stealth |
| Main | Platform 9¾ | Timed |
| Side | Neville's toad | Exploration |

### Act III — Hogwarts: First Term
| Type | Mission | Gameplay |
|---|---|---|
| Side | The sorting hat | Choice |
| Side | First flying lesson | Action |
| Main | The troll | Combat |
| Side | Quidditch match | Timed |
| Side | Mirror of Erised | Stealth |

### Act IV — The Philosopher's Stone
| Type | Mission | Gameplay |
|---|---|---|
| Side | Norbert | Stealth |
| Side | Forbidden forest | Survival |
| Main | The stone | Puzzle + Combat |

---

## Folder structure

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
│   ├── tardis_hub.dart
│   └── mission_select.dart
├── services/               # save, audio, etc.
└── story/                  # dialogue, codex data
assets/
├── images/
├── audio/
└── maps/
```