import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/input.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'worlds/hub/tardis_hub_world.dart';
import 'worlds/pilot/pilot_world.dart';
import 'components/hud/action_button.dart';
import 'components/hud/tardis_button.dart';

enum GameWorld { hub, pilot }

class RifterGame extends FlameGame with KeyboardEvents {
  late final TardisHubWorld _hubWorld;
  late final PilotWorld _pilotWorld;
  late final JoystickComponent joystick;
  late ActionButton _actionButton;
  late final TardisButton _tardisButton;
  bool _nearRift = false;
  bool _isTransitioning = false;
  GameWorld _currentWorld = GameWorld.hub;

  static const String hubOverlay = 'riftHub';

  /// Preferred zoom for hub framing — a creative choice, not a computed fit.
  /// The actual zoom used will never go below what's needed to guarantee
  /// the camera's pan stays fully inside the map (see _applyHubBounds).
  static const double _hubZoomPreference = 1.4;

  @override
  Color backgroundColor() => const Color(0xFF0A0A0F);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    joystick = JoystickComponent(
      knob: CircleComponent(
        radius: 20,
        paint: Paint()..color = const Color(0x99FFFFFF),
      ),
      background: CircleComponent(
        radius: 50,
        paint: Paint()..color = const Color(0x44FFFFFF),
      ),
      margin: const EdgeInsets.only(left: 32, bottom: 32),
    );

    _hubWorld = TardisHubWorld(
      joystick: joystick,
      onRiftEnter: _onRiftEnter,
      onRiftExit: _onRiftExit,
    );
    _pilotWorld = PilotWorld(
      joystick: joystick,
      onRiftEnter: _onRiftEnter,
      onRiftExit: _onRiftExit,
    );

    camera = CameraComponent(world: _hubWorld);
    camera.viewfinder.anchor = Anchor.center;

    await add(_hubWorld);
    await add(_pilotWorld);
    await add(camera);

    camera.viewport.add(joystick);

    _tardisButton = TardisButton(onPressed: openHubOverlay);
    camera.viewport.add(_tardisButton);

    final tiledMap = _hubWorld.tiledMap; // expose this getter (see below)
    final objectGroup = tiledMap.tileMap.getLayer<ObjectGroup>(
      'Object Layer 1',
    );
    for (final obj in objectGroup?.objects ?? <TiledObject>[]) {
      if (obj.name == 'spawn_point') {
        _hubWorld.player.position = Vector2(
          obj.x + obj.width / 2,
          obj.y + obj.height / 2,
        );
        break;
      }
    }

    await Future.microtask(() => _hubWorld.loaded);

    camera.follow(_hubWorld.player);
    _applyHubBounds();

    pauseEngine();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _applyHubBounds();
  }

  /// Locks the map itself as the total pannable/walkable space: the camera
  /// can pan anywhere within it (following the player) but is guaranteed to
  /// never show area beyond the painted background, at any device aspect
  /// ratio. Achieved by flooring zoom at whatever value makes the map fully
  /// cover the viewport, then clamping pan with setBounds.
  void _applyHubBounds() {
    if (!isLoaded) return;
    if (camera.viewport.size.x == 0 || camera.viewport.size.y == 0) return;
    if (_currentWorld != GameWorld.hub) return;

    final mapSize = TardisHubWorld.mapSize;
    final minZoomToCover = [
      camera.viewport.size.x / mapSize.x,
      camera.viewport.size.y / mapSize.y,
    ].reduce((a, b) => a > b ? a : b);

    camera.viewfinder.zoom = _hubZoomPreference > minZoomToCover
        ? _hubZoomPreference
        : minZoomToCover;
    // NOTE: camera.setBounds()/BoundedPositionBehavior was tested and found
    // to NOT reliably clamp when combined with follow() — confirmed via
    // live visibleWorldRect logging showing the camera exceeding map bounds
    // by ~45 units. Manual clamp in update() (see _clampCameraToMap) is
    // used instead as the authoritative mechanism.
  }

  /// Manually clamps the camera's focal point so the visible world rect
  /// never exceeds the hub map's bounds, regardless of zoom or device
  /// aspect ratio. Runs every frame; this is the authoritative boundary
  /// mechanism (camera.setBounds was found unreliable with follow()).
  void _clampCameraToMap() {
    if (_currentWorld != GameWorld.hub) return;
    if (camera.viewport.size.x == 0 || camera.viewport.size.y == 0) return;

    final mapSize = TardisHubWorld.mapSize;
    final zoom = camera.viewfinder.zoom;
    final halfVisibleW = (camera.viewport.size.x / zoom) / 2;
    final halfVisibleH = (camera.viewport.size.y / zoom) / 2;

    final pos = camera.viewfinder.position;
    final clampedX = pos.x.clamp(halfVisibleW, mapSize.x - halfVisibleW);
    final clampedY = pos.y.clamp(halfVisibleH, mapSize.y - halfVisibleH);
    camera.viewfinder.position = Vector2(clampedX, clampedY);
  }

  void resumeFromMenu() {
    resumeEngine();
  }

  void _onRiftEnter() {
    if (_isTransitioning) return;
    _nearRift = true;
    _actionButton = ActionButton(onPressed: _onActionPressed);
    camera.viewport.add(_actionButton);
  }

  void _onRiftExit() {
    if (_isTransitioning) return;
    _nearRift = false;
    _actionButton.removeFromParent();
  }

  void _onActionPressed() {
    if (!_nearRift || _isTransitioning) return;
    _isTransitioning = true;

    if (_currentWorld == GameWorld.hub) {
      _jumpToPilotWorld();
    } else {
      _jumpToHubWorld();
    }
  }

  void _jumpToPilotWorld() {
    _currentWorld = GameWorld.pilot;
    camera.stop();
    camera.world = _pilotWorld;
    camera.follow(_pilotWorld.player);
    // TODO: call _applyBoundsFor(PilotWorld) once PilotWorld has real map
    // dimensions instead of the placeholder rectangle.

    // Small delay before allowing rift interactions again
    Future.delayed(const Duration(milliseconds: 500), () {
      _isTransitioning = false;
      _nearRift = false;
      _actionButton.removeFromParent();
    });
  }

  void _jumpToHubWorld() {
    _currentWorld = GameWorld.hub;
    camera.stop();
    camera.world = _hubWorld;
    camera.follow(_hubWorld.player);
    _applyHubBounds();

    Future.delayed(const Duration(milliseconds: 500), () {
      _isTransitioning = false;
      _nearRift = false;
      _actionButton.removeFromParent();
    });
  }

  void openHubOverlay() {
    pauseEngine();
    overlays.add(hubOverlay);
  }

  void closeHubOverlay() {
    overlays.remove(hubOverlay);
    resumeEngine();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _clampCameraToMap();
  }
}

class StaticCollider extends PositionComponent {
  StaticCollider({required Vector2 position, required Vector2 size})
      : super(position: position, size: size) {
    add(RectangleHitbox()..collisionType = CollisionType.passive);
  }
}