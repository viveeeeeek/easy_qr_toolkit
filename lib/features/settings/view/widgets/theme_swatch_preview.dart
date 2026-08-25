import 'dart:math';

import 'package:material_ui/material_ui.dart';

class ThemeSwatchPreview extends StatelessWidget {
  final Color seedColor;
  final bool isSelected;
  final VoidCallback? onTap;

  const ThemeSwatchPreview({
    super.key,
    required this.seedColor,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Generate a scheme to get harmonic colors.
    // We match the preview brightness to the active theme mode.
    // This ensures the "Primary" color in the swatch matches the actual
    // "Primary" color used in the app (and the selection ring).
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Theme.of(context).brightness,
    );

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 60,
        height: 60,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Selection Ring
            if (isSelected)
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),

            // Color Palette Pie Chart
            Container(
              width: 45,
              height: 45,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: CustomPaint(
                painter: _PalettePainter(
                  primary: colorScheme.primary,
                  secondary: colorScheme.secondaryContainer,
                  tertiary: colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PalettePainter extends CustomPainter {
  final Color primary;
  final Color secondary;
  final Color tertiary;

  _PalettePainter({
    required this.primary,
    required this.secondary,
    required this.tertiary,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final paint = Paint()..style = PaintingStyle.fill;

    // 1. Primary (Left Half)
    paint.color = primary;
    canvas.drawArc(rect, pi / 2, pi, true, paint);

    // 2. Secondary (Top Right Quarter)
    paint.color = secondary;
    canvas.drawArc(rect, -pi / 2, pi / 2, true, paint);

    // 3. Tertiary (Bottom Right Quarter)
    paint.color = tertiary;
    canvas.drawArc(rect, 0, pi / 2, true, paint);
  }

  @override
  bool shouldRepaint(covariant _PalettePainter oldDelegate) {
    return oldDelegate.primary != primary ||
        oldDelegate.secondary != secondary ||
        oldDelegate.tertiary != tertiary;
  }
}
