import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

class RiftPortal extends PositionComponent with CollisionCallbacks, HasGameRef {
  final VoidCallback onPlayerNearby;
  final VoidCallback onPlayerLeft;

  bool _playerInRange = false;

  RiftPortal({
    required Vector2 position,
    required this.onPlayerNearby,
    required this.onPlayerLeft,
  }) : super(position: position, size: Vector2(48, 48), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox());
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    print('💥 collision with: ${other.runtimeType}');
    if (!_playerInRange) {
      _playerInRange = true;
      onPlayerNearby();
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (_playerInRange) {
      _playerInRange = false;
      onPlayerLeft();
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(
      size.toOffset() / 2,
      22,
      Paint()
        ..color = const Color(0x44A78BFA)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawCircle(
      size.toOffset() / 2,
      14,
      Paint()..color = const Color(0xFF7C3AED),
    );
    canvas.drawCircle(
      size.toOffset() / 2,
      6,
      Paint()..color = const Color(0xFFDDD6FE),
    );
  }
}
