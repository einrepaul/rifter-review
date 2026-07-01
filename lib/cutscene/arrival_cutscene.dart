import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'cutscene_beat.dart';
import 'arrival_scene.dart';

typedef OnCutSceneComplete = void Function();

/// Invalidated whenever the cutscene moves past the beat that created it.
/// Any async callback (VO complete, VO fallback timer, VO error, breath
/// delay) captures its beat's token and checks `isValid` before acting,
/// so stale callbacks from a previous beat are silently ignored instead
/// of needing a hand-rolled `if (token != _beatToken) return` copied at
/// every call site (that duplication is what let the double-advance race
/// slip through last time).
class _BeatToken {
  bool _valid = true;
  bool get isValid => _valid;
  void _invalidate() => _valid = false;
}

/// What the current beat is doing right now. Replaces the old
/// `_voPlaying` + `_advancedThisBeat` pair of independent bools, which
/// could in principle disagree with each other.
enum _BeatPhase {
  playingVo, // VO/duration timer running; tap does nothing yet
  waitingForTap, // beat finished producing audio, holding for input
  advanced, // _advanceBeat already ran for this beat; further calls no-op
}

/// Two AudioPlayer instances that trade off which one is "live", so a new
/// sound can start on the idle one while the previously-active one fades
/// out — shared shape between the SFX crossfade and the ambient loop
/// chain, which both need "two players, one active at a time" but fade
/// differently (SFX: new sound at full volume instantly, old one fades
/// out; ambient loop: both fade across each other symmetrically).
class _AlternatingPlayers {
  final AudioPlayer a = AudioPlayer();
  final AudioPlayer b = AudioPlayer();
  bool _aIsActive = true;

  AudioPlayer get active => _aIsActive ? a : b;
  AudioPlayer get idle => _aIsActive ? b : a;
  void swap() => _aIsActive = !_aIsActive;

  void setAudioContext(AudioContext ctx) {
    a.setAudioContext(ctx);
    b.setAudioContext(ctx);
  }

  Future<void> dispose() async {
    await a.dispose();
    await b.dispose();
  }
}

class ArrivalCutscene extends StatefulWidget {
  final OnCutSceneComplete onComplete;

  const ArrivalCutscene({super.key, required this.onComplete});

  @override
  State<ArrivalCutscene> createState() => _ArrivalCutsceneState();
}

class _ArrivalCutsceneState extends State<ArrivalCutscene> {
  int _beatIndex = 0;
  _BeatToken _token = _BeatToken();
  _BeatPhase _phase = _BeatPhase.playingVo;

  Timer? _beatTimer;
  Timer? _voFallbackTimer;

  String? _currentPanel;
  String? _incomingPanel;
  double _incomingOpacity = 0.0;

  // Effect key -> auto-clear duration. null means "persists once triggered".
  // Adding a new effect (screen shake, sprite fade-in, ...) means adding
  // one entry here, not a new bool field + a new Future.delayed block.
  static const _effectDurations = <String, Duration?>{
    'glitch': Duration(milliseconds: 100),
    'lights_up': null,
  };
  final Set<String> _activeEffects = {};

  final AudioPlayer _voPlayer = AudioPlayer();

  final _AlternatingPlayers _sfx = _AlternatingPlayers();
  Timer? _sfxFadeTimer;
  static const _sfxCrossfadeMs = 350;
  static const _sfxFadeStepMs = 30;

  final _AlternatingPlayers _ambient = _AlternatingPlayers();
  Timer? _ambientDuckFadeTimer;
  Timer? _ambientLoopTimer;
  Timer? _ambientLoopFadeTimer;
  double _ambientVolume =
      0.0; // audioplayers has no getVolume(); tracked ourselves
  static const _ambientAsset = 'audio/sfx/amb_hub_drone.wav';
  static const _ambientBaseVolume = 0.35;
  static const _ambientDuckVolume = 0.15;
  static const _ambientCrossfadeMs = 500;

  CutsceneBeat get _currentBeat => arrivalScene[_beatIndex];

  @override
  void initState() {
    super.initState();

    final mixContext = AudioContextConfig(
      focus: AudioContextConfigFocus.mixWithOthers,
    ).build();
    _voPlayer.setAudioContext(mixContext);
    _sfx.setAudioContext(mixContext);
    _ambient.setAudioContext(mixContext);

    _voPlayer.onPlayerComplete.listen((_) => _handleVoFinished(_token));

    _runBeat(_beatIndex);

    Future.delayed(const Duration(milliseconds: 50), _startAmbient);
  }

  @override
  void dispose() {
    _beatTimer?.cancel();
    _voFallbackTimer?.cancel();
    _sfxFadeTimer?.cancel();
    _ambientDuckFadeTimer?.cancel();
    _ambientLoopTimer?.cancel();
    _ambientLoopFadeTimer?.cancel();
    _voPlayer.dispose();
    _sfx.dispose();
    _ambient.dispose();
    super.dispose();
  }

  void _runBeat(int index) {
    if (index >= arrivalScene.length) return;

    _token._invalidate();
    final token = _token = _BeatToken();

    final beat = arrivalScene[index];

    _phase = beat.voKey != null
        ? _BeatPhase.playingVo
        : _BeatPhase.waitingForTap;

    if (beat.voKey != null) {
      _playVo(beat.voKey!, token);
    }

    if (beat.sfxKey != null) {
      _playSfxCrossfade(beat.sfxKey!);
    }

    if (beat.effectKey != null) {
      _triggerEffect(beat.effectKey!);
    }

    if (beat.panelAsset != null && beat.panelAsset != _currentPanel) {
      _crossfadeToPanel(beat.panelAsset!);
    }

    if (beat.durationMs != null) {
      _beatTimer = Timer(
        Duration(milliseconds: beat.durationMs!),
        () => _advanceBeat(token),
      );
    }
  }

  void _playVo(String voKey, _BeatToken token) {
    setState(() => _phase = _BeatPhase.playingVo);
    _fadeAmbientTo(_ambientDuckVolume, ms: 250);

    _voPlayer.play(AssetSource('audio/vo/$voKey.mp3')).catchError((e) {
      debugPrint('VO failed to play ($voKey): $e');
      _guarded(token, () {
        setState(() => _phase = _BeatPhase.waitingForTap);
        _scheduleBreathThenAdvance(token, ms: 300);
      });
    });

    _voFallbackTimer?.cancel();
    _voPlayer
        .getDuration()
        .then((duration) {
          if (duration == null) return;
          _guarded(token, () {
            _voFallbackTimer = Timer(
              duration + const Duration(milliseconds: 400),
              () => _handleVoFinished(token),
            );
          });
        })
        .catchError((_) {});
  }

  void _handleVoFinished(_BeatToken token) {
    if (_phase != _BeatPhase.playingVo) return;
    _guarded(token, () {
      _voFallbackTimer?.cancel();
      setState(() => _phase = _BeatPhase.waitingForTap);
      _fadeAmbientTo(_ambientBaseVolume, ms: 400);
      _scheduleBreathThenAdvance(token, ms: 600);
    });
  }

  void _scheduleBreathThenAdvance(_BeatToken token, {required int ms}) {
    Future.delayed(Duration(milliseconds: ms), () {
      _guarded(token, () => _advanceBeat(token));
    });
  }

  void _advanceBeat(_BeatToken token) {
    if (!token.isValid || _phase == _BeatPhase.advanced) return;
    _phase = _BeatPhase.advanced;

    _beatTimer?.cancel();
    _beatTimer = null;
    _voFallbackTimer?.cancel();
    _voFallbackTimer = null;

    final beat = _currentBeat;

    if (beat.type == BeatType.handoff) {
      _fadeAmbientTo(0, ms: 600);
      widget.onComplete();
      return;
    }

    if (_beatIndex < arrivalScene.length - 1) {
      setState(() => _beatIndex++);
      _runBeat(_beatIndex);
    }
  }

  void _onTap() {
    if (_phase != _BeatPhase.waitingForTap) return;
    if (!_currentBeat.waitForTap) return;
    _advanceBeat(_token);
  }

  void _guarded(_BeatToken token, VoidCallback fn) {
    if (!mounted || !token.isValid) return;
    fn();
  }

  void _playSfxCrossfade(String key) {
    final incoming = _sfx.idle;
    final outgoing = _sfx.active;

    incoming.setVolume(1.0);
    incoming.play(AssetSource('audio/sfx/$key.mp3')).catchError((e) {
      debugPrint('SFX failed to play ($key): $e');
    });

    _sfxFadeTimer?.cancel();
    final steps = (_sfxCrossfadeMs / _sfxFadeStepMs).round();
    var step = 0;
    _sfxFadeTimer = Timer.periodic(
      const Duration(milliseconds: _sfxFadeStepMs),
      (timer) {
        step++;
        final t = (step / steps).clamp(0.0, 1.0);
        outgoing.setVolume(1.0 - t);
        if (t >= 1.0) {
          timer.cancel();
          outgoing.stop().catchError((_) {});
          outgoing.setVolume(1.0);
        }
      },
    );

    _sfx.swap();
  }

  void _startAmbient() {
    if (!mounted) return;
    final player = _ambient.active;
    player.setReleaseMode(ReleaseMode.stop).catchError((e) {
      debugPrint('Ambient setReleaseMode failed: $e');
    });
    _ambientVolume = 0.0;
    player.setVolume(0.0);
    player.play(AssetSource(_ambientAsset)).catchError((e) {
      debugPrint('Ambient bed failed to play: $e');
    });
    _fadeAmbientTo(_ambientBaseVolume, ms: 800);
    _scheduleAmbientLoopChain(player);
  }

  void _scheduleAmbientLoopChain(AudioPlayer player) {
    player
        .getDuration()
        .then((duration) {
          if (!mounted || duration == null) return;
          final delay =
              duration - const Duration(milliseconds: _ambientCrossfadeMs);
          if (delay.isNegative) return;
          _ambientLoopTimer?.cancel();
          _ambientLoopTimer = Timer(delay, _crossfadeAmbientLoop);
        })
        .catchError((_) {});
  }

  void _crossfadeAmbientLoop() {
    if (!mounted) return;
    final incoming = _ambient.idle;
    final outgoing = _ambient.active;
    final targetVolume = _ambientVolume;

    incoming.setReleaseMode(ReleaseMode.stop).catchError((_) {});
    incoming.setVolume(0.0);
    incoming.play(AssetSource(_ambientAsset)).catchError((e) {
      debugPrint('Ambient loop-chain failed to play: $e');
    });

    _ambient.swap();

    _ambientLoopFadeTimer?.cancel();
    const stepMs = 30;
    final steps = (_ambientCrossfadeMs / stepMs).round();
    var step = 0;
    _ambientLoopFadeTimer = Timer.periodic(
      const Duration(milliseconds: stepMs),
      (timer) {
        step++;
        final t = (step / steps).clamp(0.0, 1.0);
        outgoing.setVolume(targetVolume * (1.0 - t));
        incoming.setVolume(targetVolume * t);
        if (t >= 1.0) {
          timer.cancel();
          outgoing.stop().catchError((_) {});
        }
      },
    );

    _scheduleAmbientLoopChain(incoming);
  }

  void _fadeAmbientTo(double target, {required int ms}) {
    _ambientDuckFadeTimer?.cancel();
    const stepMs = 30;
    final steps = (ms / stepMs).round().clamp(1, 1000);
    final from = _ambientVolume;
    final player = _ambient.active;
    var step = 0;
    _ambientDuckFadeTimer = Timer.periodic(
      const Duration(milliseconds: stepMs),
      (timer) {
        step++;
        final t = (step / steps).clamp(0.0, 1.0);
        _ambientVolume = from + (target - from) * t;
        player.setVolume(_ambientVolume);
        if (t >= 1.0) timer.cancel();
      },
    );
  }

  void _crossfadeToPanel(String assetPath) {
    setState(() {
      _incomingPanel = assetPath;
      _incomingOpacity = 0.0;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _incomingOpacity = 1.0);
    });
  }

  void _onCrossfadeComplete() {
    if (!mounted || _incomingPanel == null) return;
    setState(() {
      _currentPanel = _incomingPanel;
      _incomingPanel = null;
      _incomingOpacity = 0.0;
    });
  }

  void _triggerEffect(String key) {
    if (!_effectDurations.containsKey(key)) {
      debugPrint('Unknown effect key: $key');
      return;
    }
    setState(() => _activeEffects.add(key));

    final duration = _effectDurations[key];
    if (duration != null) {
      Future.delayed(duration, () {
        if (!mounted) return;
        setState(() => _activeEffects.remove(key));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onTap,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (_currentPanel != null)
              Image.asset(_currentPanel!, fit: BoxFit.cover),

            if (_incomingPanel != null)
              AnimatedOpacity(
                opacity: _incomingOpacity,
                duration: const Duration(milliseconds: 400),
                onEnd: _onCrossfadeComplete,
                child: Image.asset(_incomingPanel!, fit: BoxFit.cover),
              ),

            if (_activeEffects.contains('glitch'))
              Container(color: Colors.white.withValues(alpha: 0.15)),

            if (_activeEffects.contains('lights_up'))
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 0.35),
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeOut,
                builder: (context, opacity, child) {
                  return IgnorePointer(
                    child: Container(
                      color: Colors.amber.withValues(alpha: opacity),
                    ),
                  );
                },
              ),

            if (_currentBeat.text != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 48,
                child: _DialogueBox(
                  speaker: _currentBeat.speaker,
                  text: _currentBeat.text!,
                ),
              ),

            if (_phase == _BeatPhase.waitingForTap &&
                _currentBeat.waitForTap &&
                _currentBeat.text != null)
              const Positioned(right: 32, bottom: 56, child: _TapPrompt()),
          ],
        ),
      ),
    );
  }
}

class _DialogueBox extends StatelessWidget {
  final String? speaker;
  final String text;

  const _DialogueBox({this.speaker, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.75),
            border: Border.all(color: const Color(0xFFFFC869), width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (speaker != null) ...[
                Text(
                  speaker!,
                  style: const TextStyle(
                    color: Color(0xFFFFC869),
                    fontSize: 11,
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
              ],
              Text(
                text,
                style: const TextStyle(
                  color: Color(0xFFE8E6DC),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TapPrompt extends StatefulWidget {
  const _TapPrompt();

  @override
  State<_TapPrompt> createState() => _TapPromptState();
}

class _TapPromptState extends State<_TapPrompt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _opacity = Tween(begin: 0.3, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: const Text(
        '▶',
        style: TextStyle(color: Color(0xFFFFC869), fontSize: 14),
      ),
    );
  }
}
