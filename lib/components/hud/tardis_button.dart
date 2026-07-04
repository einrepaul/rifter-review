import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class TardisButton extends HudButtonComponent {
  TardisButton({required VoidCallback onPressed})
    : super(
        button: _build(false),
        buttonDown: _build(true),
        margin: const EdgeInsets.only(right: 32, top: 48),
        onPressed: onPressed,
      );

  static PositionComponent _build(bool pressed) {
    return RectangleComponent(
      size: Vector2(52, 28),
      paint: Paint()
        ..color = pressed ? const Color(0xCCA78BFA) : const Color(0x997C3AED),
    )..add(
      TextComponent(
        text: 'TARDIS',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
        anchor: Anchor.center,
        position: Vector2(26, 14),
      ),
    );
  }
}
