import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'cutscene_beat.dart';
import 'arrival_scene.dart';

typedef OnCutSceneComplete = void Function();

class ArrivalCutscene extends StatefulWidget {
  final OnCutSceneComplete onComplete;

  const ArrivalCutscene({super.key, required this.onComplete});

  @override
  State<ArrivalCutscene> createState() => _ArrivalCutsceneState();
}

class _ArrivalCutsceneState extends State<ArrivalCutscene>
    with SingleTickerProviderStateMixin {
  int _beatIndex = 0;
  Timer? _beatTimer;

  String? _currentPanel;
  String? _incomingPanel;
  double _panelOpacity = 1.0;

  bool _glitchActive = false;
  bool _lightsUpActive = false;

  final AudioPlayer _voPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  bool _voPlaying = false;

  CutsceneBeat get _currentBeat => arrivalScene[_beatIndex];

  @override
  void initState() {
    super.initState();
    _voPlayer.onPlayerComplete.listen((_) {
      if (mounted) return;
      setState(() => _voPlaying = false);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted && _beatIndex < arrivalScene.length) {
          _advanceBeat();
        }
      });
    });
    _runBeat(_beatIndex);
  }

  @override
  void dispose() {
    _beatTimer?.cancel();
    _voPlayer.dispose();
    _sfxPlayer.dispose();
    super.dispose();
  }

  void _runBeat(int index) {
    if (index >= arrivalScene.length) return;

    final beat = arrivalScene[index];

    if (beat.voKey != null) {
      _playVo(beat.voKey!);
    }

    if (beat.sfxKey != null) {
      _sfxPlayer.play(AssetSource('audio/sfx/${beat.sfxKey}.mp3'));
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
        _advanceBeat,
      );
    }
  }

  void _playVo(String voKey) {
    setState(() => _voPlaying = true);
    _voPlayer.play(AssetSource('audio/vo/$voKey.mp3'));
  }

  void _advanceBeat() {
    _beatTimer?.cancel();
    _beatTimer = null;

    final beat = _currentBeat;

    if (beat.type == BeatType.handoff) {
      widget.onComplete();
      return;
    }

    if (_beatIndex < arrivalScene.length - 1) {
      setState(() => _beatIndex++);
      _runBeat(_beatIndex);
    }
  }

  void _onTap() {
    if (_voPlaying) return;
    if (!_currentBeat.waitForTap) return;
    _advanceBeat();
  }

  void _crossfadeToPanel(String assetPath) {
    setState(() {
      _incomingPanel = assetPath;
      _panelOpacity = 0.0;
    });

    Future.delayed(const Duration(milliseconds: 50), () {
      if (!mounted) return;
      setState(() {
        _panelOpacity = 1.0;
        _currentPanel = assetPath;
        _incomingPanel = null;
      });
    });
  }

  void _triggerEffect(String key) {
    switch (key) {
      case 'glitch':
        setState(() => _glitchActive = true);
        Future.delayed(const Duration(milliseconds: 100), () {
          if (!mounted) return;
          setState(() => _glitchActive = false);
        });
        break;
      case 'lights_up':
        setState(() => _lightsUpActive = true);
        break;
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
              AnimatedOpacity(
                opacity: _panelOpacity,
                duration: const Duration(milliseconds: 400),
                child: Image.asset(_currentPanel!, fit: BoxFit.cover),
              ),

            if (_glitchActive)
              Container(color: Colors.white.withValues(alpha: 0.15)),

            if (_lightsUpActive)
              AnimatedOpacity(
                opacity: 0.3,
                duration: const Duration(milliseconds: 1500),
                child: Container(color: Colors.amber.withValues(alpha: 0.2)),
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

            if (!_currentBeat.waitForTap && _currentBeat.text != null)
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
