enum BeatType {
  black,
  voiceover,
  panelTransition,
  dialogue,
  pause,
  effect,
  handoff,
}

class CutsceneBeat {
  final BeatType type;
  final String? text;
  final String? speaker;
  final int? durationMs;
  final String? panelAsset;
  final String? sfxKey;
  final String? effectKey;
  bool get waitForTap => durationMs == null;

  const CutsceneBeat({
    required this.type,
    this.text,
    this.speaker,
    this.durationMs,
    this.panelAsset,
    this.sfxKey,
    this.effectKey,
  }) : assert(
         durationMs != null ||
             type == BeatType.voiceover ||
             type == BeatType.dialogue,
         'Non-dialogue beats must have a durationMs',
       );
}
