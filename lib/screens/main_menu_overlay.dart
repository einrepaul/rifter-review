import 'package:flutter/material.dart';
import '../components/sparkle_overlay.dart';
import '../rifter_game.dart';

class MainMenuOverlay extends StatelessWidget {
  final RifterGame game;

  const MainMenuOverlay({super.key, required this.game});

  static const _amber = Color(0xFFE8B45A);
  static const _dimGrey = Color(0xFF6B7480);

  bool get _hasSave => false;

  void _onNewGame() {
    const introPlayed = false;

    game.overlays.remove('mainMenu');

    if (!introPlayed) {
      game.overlays.add('arrivalCutScene');
    } else {
      game.overlays.add('riftHub');
    }
  }

  void _onContinue() {
    game.overlays.remove('mainMenu');
    game.overlays.add('riftHub');
  }

  void _onSettings() {
    game.overlays.add('settings');
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SparkleOverlay(
        glints: kMainMenuGlints,
        child: Image.asset('assets/images/main_menu_bg.png', fit: BoxFit.cover),
        foreground: SafeArea(
          child: Column(
            children: [
              SizedBox(height: isLandscape ? 20 : 56),
              Text(
                'RIFTER',
                style: TextStyle(
                  color: _amber,
                  fontSize: isLandscape ? 32 : 48,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 12,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'A MARQUEE STUDIOS GAME',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  letterSpacing: 4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      children: [
                        _MenuButton(
                          label: 'NEW GAME',
                          enabled: true,
                          emphasized: true,
                          onTap: _onNewGame,
                        ),
                        SizedBox(height: isLandscape ? 8 : 14),
                        _MenuButton(
                          label: 'CONTINUE',
                          enabled: _hasSave,
                          onTap: _hasSave ? _onContinue : null,
                        ),
                        SizedBox(height: isLandscape ? 8 : 14),
                        _MenuButton(
                          label: 'SETTINGS',
                          enabled: true,
                          onTap: _onSettings,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: isLandscape ? 8 : 24),
              Padding(
                padding: const EdgeInsets.only(right: 16, bottom: 8),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'build 0.0.1 - pilot',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35),
                      fontSize: 11,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final bool emphasized;
  final VoidCallback? onTap;

  const _MenuButton({
    required this.label,
    required this.enabled,
    this.emphasized = false,
    this.onTap,
  });

  static const _amber = Color(0xFFE8B45A);
  static const _dimGrey = Color(0xFF6B7480);

  @override
  Widget build(BuildContext context) {
    final borderColor = enabled
        ? (emphasized ? _amber : _amber.withValues(alpha: 0.6))
        : _dimGrey.withValues(alpha: 0.4);
    final textColor = enabled ? (emphasized ? _amber : Colors.white) : _dimGrey;

    return Material(
      color: const Color(0xCC0A0E16),
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 1.4),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 3,
            ),
          ),
        ),
      ),
    );
  }
}
