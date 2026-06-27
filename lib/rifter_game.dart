import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class RifterGame extends FlameGame {
  @override
  Color backgroundColor() => const Color(0xFF0A0A0F);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    camera.viewfinder.anchor = Anchor.topLeft;

    // TODO: load TARDIS hub world on boot
  }

  @override
  void update(double dt) {
    super.update(dt);
    // TODO: global game state updates (timers, events)
  }
}