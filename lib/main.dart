import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'rifter_game.dart';
import 'screens/tardis_hub_overlay.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final game = RifterGame();

  runApp(
    GameWidget<RifterGame>(
      game: game,
      overlayBuilderMap: {
        'tardisHub': (context, game) => TardisHubOverlay(game: game),  
      },
    ),
  );
}
