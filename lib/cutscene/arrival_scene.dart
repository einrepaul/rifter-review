import 'cutscene_beat.dart';

const List<CutsceneBeat> arrivalScene = [
  CutsceneBeat(type: BeatType.black, durationMs: 2000, sfxKey: 'sfx_whine'),

  CutsceneBeat(
    type: BeatType.voiceover,
    speaker: 'RIFTER',
    text: 'Not again. Not now-',
    voKey: 'vo_01_not_again',
  ),

  CutsceneBeat(
    type: BeatType.panelTransition,
    panelAsset: 'assets/images/panel_1_spark.png',
    durationMs: 800,
    sfxKey: 'sfx_spark',
  ),

  CutsceneBeat(
    type: BeatType.panelTransition,
    panelAsset: 'assets/images/panel_2_damaged_hub.png',
    durationMs: 1200,
    sfxKey: 'sfx_smoke_crackle',
  ),

  CutsceneBeat(
    type: BeatType.panelTransition,
    panelAsset: 'assets/images/panel_3_glitch.png',
    durationMs: 1000,
    sfxKey: 'sfx_materialize',
  ),

  CutsceneBeat(
    type: BeatType.dialogue,
    speaker: 'RIFTER',
    text: '...Still in one piece. Mostly.',
    voKey: 'vo_02_one_piece',
  ),

  CutsceneBeat(type: BeatType.effect, durationMs: 500, effectKey: 'glitch'),

  CutsceneBeat(
    type: BeatType.dialogue,
    speaker: 'RIFTER',
    text: 'I don\'t know who did this to me. Don\'t remember enough to guess.',
    voKey: 'vo_03_dont_know',
  ),

  CutsceneBeat(
    type: BeatType.pause,
    durationMs: 2000,
    sfxKey: 'sfx_smoke_crackle',
  ),

  CutsceneBeat(
    type: BeatType.dialogue,
    speaker: 'RIFTER',
    text: 'But I remember enough to know I\'m not whole.',
    voKey: 'vo_04_not_whole',
  ),

  CutsceneBeat(
    type: BeatType.dialogue,
    speaker: 'RIFTER',
    text: 'And something out there-',
    voKey: 'vo_05_something',
  ),

  CutsceneBeat(type: BeatType.pause, durationMs: 2000),

  CutsceneBeat(type: BeatType.pause, durationMs: 2000),

  CutsceneBeat(
    type: BeatType.effect,
    durationMs: 1500,
    sfxKey: 'sfx_power_up',
    effectKey: 'lights_up',
  ),

  CutsceneBeat(type: BeatType.handoff, durationMs: 800),
];
