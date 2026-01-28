import 'package:flutter/material.dart';

class TaraBackground extends StatelessWidget {
  const TaraBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final background = theme.scaffoldBackgroundColor;

    final primaryGlow = isDark
        ? colors.surface.withValues(alpha: 0.08)
        : colors.primary.withValues(alpha: 0.12);
    final accentGlow = isDark
        ? colors.surface.withValues(alpha: 0.05)
        : colors.tertiary.withValues(alpha: 0.16);

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  background,
                  primaryGlow,
                  background,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: -140,
          left: -120,
          child: _GlowOrb(
            size: 260,
            color: accentGlow,
          ),
        ),
        Positioned(
          bottom: -160,
          right: -120,
          child: _GlowOrb(
            size: 280,
            color: primaryGlow,
          ),
        ),
        child,
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, Colors.transparent],
            stops: const [0, 1],
          ),
        ),
      ),
    );
  }
}
