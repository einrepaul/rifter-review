import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Player extends PositionComponent
    with KeyboardHandler, HasGameRef, CollisionCallbacks {
  static const double speed = 150;

  final _velocity = Vector2.zero();
  final Set<LogicalKeyboardKey> _keysPressed = {};
  final JoystickComponent joystick;

  Player({required this.joystick})
    : super(size: Vector2(32, 32), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _keysPressed
      ..clear()
      ..addAll(keysPressed);
    return true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _velocity.setZero();

    if (!joystick.delta.isZero()) {
      _velocity.setFrom(joystick.delta.normalized());
    }

    if (_keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
        _keysPressed.contains(LogicalKeyboardKey.keyW)) {
      _velocity.y = -1;
    }
    if (_keysPressed.contains(LogicalKeyboardKey.arrowDown) ||
        _keysPressed.contains(LogicalKeyboardKey.keyS)) {
      _velocity.y = 1;
    }
    if (_keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        _keysPressed.contains(LogicalKeyboardKey.keyA)) {
      _velocity.x = -1;
    }
    if (_keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        _keysPressed.contains(LogicalKeyboardKey.keyD)) {
      _velocity.x = 1;
    }

    if (_velocity.length > 0) {
      _velocity.normalize();
      position += _velocity * speed * dt;
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), Paint()..color = const Color(0xFF00E5FF));
  }
}
