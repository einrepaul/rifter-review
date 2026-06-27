import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import '../../components/player/player.dart';
import '../../components/rift_portal/rift_portal.dart';

class PilotWorld extends World with HasGameRef, HasCollisionDetection {
  late final Player _player;
  final JoystickComponent joystick;
  final VoidCallback onRiftEnter;
  final VoidCallback onRiftExit;

  PilotWorld({
    required this.joystick,
    required this.onRiftEnter,
    required this.onRiftExit,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(
      RectangleComponent(
        position: Vector2(-500, -500),
        size: Vector2(1000, 1000),
        paint: Paint()..color = const Color(0xFF1A0A00),
      ),
    );

    add(
      RiftPortal(
        position: Vector2(0, -150),
        onPlayerNearby: onRiftEnter,
        onPlayerLeft: onRiftExit,
      ),
    );

    _player = Player(joystick: joystick)..position = Vector2.zero();
    add(_player);
  }

  Player get player => _player;
}
