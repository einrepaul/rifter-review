import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/collisions.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import '../../components/player/player.dart';
import '../../components/rift_portal/rift_portal.dart';

class TardisHubWorld extends World with HasGameRef, HasCollisionDetection {
  late final Player _player;
  final JoystickComponent joystick;
  final VoidCallback onRiftEnter;
  final VoidCallback onRiftExit;
  late final TiledComponent tiledMap;

  final Completer<void> _loaded = Completer<void>();
  Future<void> get loaded => _loaded.future;

  static final Vector2 mapSize = Vector2(1408, 768);
  static const double _wallThickness = 32;

  TardisHubWorld({
    required this.joystick,
    required this.onRiftEnter,
    required this.onRiftExit,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Painted hub background + collision/trigger objects
    tiledMap = await TiledComponent.load(
      'tardis_hub_art.tmx',
      Vector2.all(32),
      prefix: 'assets/tiles/',
    );
    tiledMap.tileMap.getLayer<ObjectGroup>('Object Layer 1')?.visible = false;
    final bg = SpriteComponent()
      ..sprite = await Sprite.load('concept_tardis_hub_damaged.png')
      ..size = Vector2(1408, 768)
      ..position = Vector2.zero();
    add(bg);

    _player = Player(
      joystick: joystick,
      minBounds: Vector2.zero(),
      maxBounds: mapSize,
    );
    _addBoundaryWalls();

    final objectGroup = tiledMap.tileMap.getLayer<ObjectGroup>(
      'Object Layer 1',
    );
    for (final obj in objectGroup?.objects ?? <TiledObject>[]) {
      final pos = Vector2(obj.x, obj.y);
      final size = Vector2(obj.width, obj.height);

      switch (obj.name) {
        case 'console_interact':
          //add(ConsoleInteractTrigger(position: pos, size: size));
          break;
        case 'console_collision':
        case 'wall_collision_left':
        case 'wall_collision_right':
        case 'wall_collision_top':
          add(StaticCollider(position: pos, size: size));
          break;
        case 'panel_scanner':
        case 'panel_sonic':
          //add(FlavorInteractTrigger(name: obj.name, position: pos, size: size));
          break;
      }
    }

    add(_player);
    _loaded.complete();

    add(
      RiftPortal(
        position: Vector2(0, -150),
        onPlayerNearby: onRiftEnter,
        onPlayerLeft: onRiftExit,
      ),
    );
  }

  Player get player => _player;

  void _addBoundaryWalls() {
    addAll([
      StaticCollider(
        // top
        position: Vector2(-_wallThickness, -_wallThickness),
        size: Vector2(mapSize.x + _wallThickness * 2, _wallThickness),
      ),
      StaticCollider(
        // bottom
        position: Vector2(-_wallThickness, mapSize.y),
        size: Vector2(mapSize.x + _wallThickness * 2, _wallThickness),
      ),
      StaticCollider(
        // left
        position: Vector2(-_wallThickness, -_wallThickness),
        size: Vector2(_wallThickness, mapSize.y + _wallThickness * 2),
      ),
      StaticCollider(
        // right
        position: Vector2(mapSize.x, -_wallThickness),
        size: Vector2(_wallThickness, mapSize.y + _wallThickness * 2),
      ),
    ]);
  }
}

class StaticCollider extends PositionComponent {
  StaticCollider({required Vector2 position, required Vector2 size})
    : super(position: position, size: size) {
    add(RectangleHitbox()..collisionType = CollisionType.passive);
  }
}
