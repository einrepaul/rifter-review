import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'rifter_game.dart';
import 'screens/main_menu_overlay.dart';
import 'screens/rift_hub_overlay.dart';
import 'cutscene/arrival_cutscene.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  final game = RifterGame();

  runApp(
    GameWidget<RifterGame>(
      game: game,
      initialActiveOverlays: const ['mainMenu'],
      overlayBuilderMap: {
        'mainMenu': (context, game) => MainMenuOverlay(game: game),
        'riftHub': (context, game) => RiftHubOverlay(game: game),
        'arrivalCutScene': (context, game) => ArrivalCutscene(
          onComplete: () {
            game.overlays.remove('arrivalCutScene');
            game.resumeEngine();
          },
        ),
      },
    ),
  );
}
