import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class ActionButton extends HudButtonComponent {
  ActionButton({required VoidCallback onPressed})
    : super(
        button: _buildButton(false),
        buttonDown: _buildButton(true),
        margin: const EdgeInsets.only(right: 32, bottom: 32),
        onPressed: onPressed,
      );

  static PositionComponent _buildButton(bool pressed) {
    return CircleComponent(
      radius: 30,
      paint: Paint()
        ..color = pressed ? const Color(0xCCA78BFA) : const Color(0x99A78BFA),
    )..add(
      TextComponent(
        text: '⬡',
        textRenderer: TextPaint(
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ),
        anchor: Anchor.center,
        position: Vector2(30, 30),
      ),
    );
  }
}
