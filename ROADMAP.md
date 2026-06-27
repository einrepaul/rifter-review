# Rifter — Game Development Roadmap
> A Marquee Studios game · Themed around The Doctor · Built with Flutter + Flame

---

## Phase 0 — Foundation
**Week 1–2**

- [x] **GitHub repo setup** — Init Flutter project, add Flame dependency, configure .gitignore, branch strategy
- [x] **Project folder structure** — Screens, components, game worlds, assets, services
- [ ] **Flame game loop scaffold** — FlameGame base, camera, world layers, game states

---

## Phase 1 — Core mechanic: the Rift jump
**Week 3–5**

- [ ] **Player character (The Doctor variant)** — Sprite, movement, basic animations, touch controls
- [ ] **Rift jump mechanic** — Portal trigger, screen transition, world swap system
- [ ] **TARDIS hub screen** — Between-mission base, mission select, player stats

---

## Phase 2 — First universe: pilot chapter
**Week 6–10**

- [ ] **Choose pilot universe** — Pick one iconic show/film, map 3–5 plot-based missions
- [ ] **World tilemap + art style** — Tiled map integration, environment assets, unique universe palette
- [ ] **Mission system** — Objectives, completion states, NPC interactions, dialogue

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