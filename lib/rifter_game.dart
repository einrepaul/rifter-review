import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'worlds/hub/tardis_hub_world.dart';
import 'worlds/pilot/pilot_world.dart';
import 'components/hud/action_button.dart';

enum GameWorld { hub, pilot }

class RifterGame extends FlameGame with KeyboardEvents {
  late final TardisHubWorld _hubWorld;
  late final PilotWorld _pilotWorld;
  late final JoystickComponent joystick;
  late ActionButton _actionButton;

  bool _nearRift = false;
  bool _isTransitioning = false;
  GameWorld _currentWorld = GameWorld.hub;

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
    camera.follow(_hubWorld.player);
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
    Future.delayed(const Duration(milliseconds: 500), () {
      _isTransitioning = false;
      _nearRift = false;
      _actionButton.removeFromParent();
    });
  }

  @override
  void update(double dt) {
    super.update(dt);
  }
}
