import 'package:flutter/material.dart';
import '../rifter_game.dart';

class RiftHubOverlay extends StatelessWidget {
  final RifterGame game;

  const RiftHubOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        color: const Color(0xCC0A0A1F),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildStats(),
                const SizedBox(height: 32),
                const Text(
                  'AVAILABLE UNIVERSES',
                  style: TextStyle(
                    color: Color(0xFF7C3AED),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(child: _buildUniverseList()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RIFT HUB',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              'Fragmented. Hunted. Searching.',
              style: TextStyle(
                color: Color(0xFF7C3AED),
                fontSize: 12,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => game.closeHubOverlay(),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF7C3AED)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.close,
              color: Color(0xFFC73AED),
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF1E1E3F)),
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF0D0D2B),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(label: 'UNIVERSES', value: '1'),
          _StatItem(label: 'MISSIONS', value: '0.5'),
          _StatItem(label: 'RIFTS OPENED', value: '0'),
        ],
      ),
    );
  }

  Widget _buildUniverseList() {
    final universes = [
      _UniverseData(
        name: 'Pilot Universe',
        description: 'Your first dimension. Explore the unknown.',
        color: const Color(0xFF7C3AED),
        isUnlocked: true,
      ),
      _UniverseData(
        name: '??? Universe',
        description: 'Complete pilot missions to unlock.',
        color: const Color(0xFF374151),
        isUnlocked: false,
      ),
      _UniverseData(
        name: '??? Universe',
        description: 'Complete pilot missions to unlock.',
        color: const Color(0xFF374151),
        isUnlocked: false,
      ),
    ];

    return ListView.separated(
      itemCount: universes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _UniverseCard(
        data: universes[index],
        onTap: universes[index].isUnlocked
          ? () => game.closeHubOverlay()
          : null,
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 10,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _UniverseData {
  final String name;
  final String description;
  final Color color;
  final bool isUnlocked;

  _UniverseData({
    required this.name,
    required this.description,
    required this.color,
    required this.isUnlocked,
  });
}

class _UniverseCard extends StatelessWidget {
  final _UniverseData data;
  final VoidCallback? onTap;

  const _UniverseCard({required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: data.isUnlocked
              ? data.color
              : const Color(0xFF1E1E3F),
          ),
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF0D0D2B),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: data.color.withValues(alpha:0.2),
                border: Border.all(color: data.color),
              ),
              child: Icon(
                data.isUnlocked ? Icons.blur_on : Icons.lock,
                color: data.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.name,
                    style: TextStyle(
                      color: data.isUnlocked
                        ? Colors.white
                        : const Color(0xFF6B7280),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.description,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (data.isUnlocked)
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF7C3AED),
            ),
          ],
        ),
      ),
    );
  }
}