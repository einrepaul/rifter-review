import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'rifter_game.dart';
import 'screens/main_menu_overlay.dart';
import 'screens/rift_hub_overlay.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final game = RifterGame();

  runApp(
    GameWidget<RifterGame>(
      game: game,
      initialActiveOverlays: const ['mainMenu'],
      overlayBuilderMap: {
        'mainMenu': (context, game) => MainMenuOverlay(game: game),
        'riftHub': (context, game) => RiftHubOverlay(game: game),  
      },
    ),
  );
}
