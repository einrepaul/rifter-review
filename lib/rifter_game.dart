import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'worlds/hub/tardis_hub_world.dart';

class RifterGame extends FlameGame {
  late final TardisHubWorld _hubWorld;
  late final JoystickComponent joystick;

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

    _hubWorld = TardisHubWorld(joystick: joystick);
    
    camera = CameraComponent(world: _hubWorld);
    camera.viewfinder.anchor = Anchor.center;

    await add(_hubWorld);
    await add(camera);

    camera.viewport.add(joystick);

    camera.follow(_hubWorld.player);
  }

  @override
  void update(double dt) {
    super.update(dt);
    // TODO: global game state updates (timers, events)
  }
}