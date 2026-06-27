import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'rifter_game.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final game = RifterGame();

  runApp(
    GameWidget<RifterGame>(
      game: game,
      overlayBuilderMap: {
        // TODO: register Flutter UI overlays here (HUD, dialogue, menus)
      },
    ),
  );
}
