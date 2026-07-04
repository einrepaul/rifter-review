import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/input.dart';
import 'package:flutter/services.dart';
import '../../worlds/hub/tardis_hub_world.dart' show StaticCollider;

enum PlayerDirection { down, up, left, right }

class Player extends PositionComponent
    with KeyboardHandler, HasGameRef, CollisionCallbacks {
  static const double speed = 150;
  static const double _frameSize = 256;
  static const double _renderSize = 148;

  final _velocity = Vector2.zero();
  final Set<LogicalKeyboardKey> _keysPressed = {};
  final JoystickComponent joystick;

  final Vector2 minBounds;
  final Vector2 maxBounds;

  final Set<StaticCollider> _activeCollisions = {};
  late final RectangleHitbox _hitbox;

  PlayerDirection _facing = PlayerDirection.down;
  final Map<PlayerDirection, SpriteAnimation> _animations = {};
  late SpriteAnimationComponent _animComponent;

  Player({
    required this.joystick,
    required this.minBounds,
    required this.maxBounds,
  }) : super(size: Vector2.all(_renderSize), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final sheet = await gameRef.images.load('rifter_spritesheet.png');

    SpriteAnimation rowAnimation(int row) {
      return SpriteAnimation.fromFrameData(
        sheet,
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.15,
          textureSize: Vector2.all(_frameSize),
          texturePosition: Vector2(0, row * _frameSize),
        ),
      );
    }

    _animations[PlayerDirection.down] = rowAnimation(0);
    _animations[PlayerDirection.up] = rowAnimation(1);
    _animations[PlayerDirection.left] = rowAnimation(2);
    _animations[PlayerDirection.right] = rowAnimation(3);

    _animComponent = SpriteAnimationComponent(
      animation: _animations[PlayerDirection.down],
      size: Vector2.all(_renderSize),
    );
    add(_animComponent);

    _hitbox = RectangleHitbox(
      size: Vector2.all(32),
      position: Vector2(_renderSize / 2 - 16, _renderSize / 2 - 16),
    );
    add(_hitbox);
  }

  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    super.onCollisionStart(points, other);
    if (other is StaticCollider) _activeCollisions.add(other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (other is StaticCollider) _activeCollisions.remove(other);
  }

  void _resolveCollisions() {
    for (final collider in _activeCollisions) {
      final hitboxRect = _hitbox.toAbsoluteRect();
      final colliderRect = collider.toRect();
      final intersection = hitboxRect.intersect(colliderRect);
      if (intersection.isEmpty) continue;

      if (intersection.width < intersection.height) {
        final pushLeft = hitboxRect.center.dx < colliderRect.center.dx;
        position.x += pushLeft ? -intersection.width : intersection.width;
      } else {
        final pushUp = hitboxRect.center.dy < colliderRect.center.dy;
        position.y += pushUp ? -intersection.height : intersection.height;
      }
    }
  }

  void _clampToMapBounds() {
    final halfW = size.x / 2;
    final halfH = size.y / 2;
    position.x = position.x.clamp(minBounds.x + halfW, maxBounds.x - halfW);
    position.y = position.y.clamp(minBounds.y + halfH, maxBounds.y - halfH);
  }

  void _setFacing(PlayerDirection dir) {
    if (_facing == dir) return;
    _facing = dir;
    _animComponent.animation = _animations[dir];
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
      _resolveCollisions();
      _clampToMapBounds();
      if (_velocity.x.abs() > _velocity.y.abs()) {
        _setFacing(
          _velocity.x > 0 ? PlayerDirection.right : PlayerDirection.left,
        );
      } else {
        _setFacing(_velocity.y > 0 ? PlayerDirection.down : PlayerDirection.up);
      }

      _animComponent.playing = true;
    } else {
      _animComponent.playing = false;
    }
  }
}
