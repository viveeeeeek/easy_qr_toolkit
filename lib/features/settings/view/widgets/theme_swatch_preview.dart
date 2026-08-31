import 'package:material_new_shapes/material_new_shapes.dart';
import 'package:material_ui/material_ui.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

class ThemeSwatchPreview extends StatelessWidget {
  final Color seedColor;
  final bool isSelected;
  final VoidCallback? onTap;

  static final Morph _morph = Morph(
    MaterialShapes.circle,
    MaterialShapes.cookie4Sided,
  );

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
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Theme.of(context).brightness,
    );

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 60,
        height: 60,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(
            begin: isSelected ? 1.0 : 0.0,
            end: isSelected ? 1.0 : 0.0,
          ),
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          builder: (context, progress, child) {
            return CustomPaint(
              size: const Size(60, 60),
              painter: _M3EMorphPalettePainter(
                morph: _morph,
                progress: progress,
                primary: colorScheme.primary,
                secondary: colorScheme.secondaryContainer,
                tertiary: colorScheme.onSecondaryContainer,
                selectionBorderColor: Theme.of(context).colorScheme.primary,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _M3EMorphPalettePainter extends CustomPainter {
  final Morph morph;
  final double progress;
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color selectionBorderColor;

  _M3EMorphPalettePainter({
    required this.morph,
    required this.progress,
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.selectionBorderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const innerSize = 44.0;
    const outerSize = 54.0;

    // 1. Draw outer selection morph ring when progress > 0
    if (progress > 0.01) {
      final outerPath = morph.toPath(progress: progress);
      final outerMatrix = Matrix4.identity()
        ..translateByVector3(
            Vector3(center.dx - outerSize / 2, center.dy - outerSize / 2, 0.0))
        ..scaleByVector3(Vector3(outerSize, outerSize, 1.0));
      final scaledOuterPath = outerPath.transform(outerMatrix.storage);

      final ringPaint = Paint()
        ..color = selectionBorderColor.withValues(alpha: progress)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawPath(scaledOuterPath, ringPaint);
    }

    // 2. Draw inner morphing palette swatch
    final innerPath = morph.toPath(progress: progress);
    final innerMatrix = Matrix4.identity()
      ..translateByVector3(
          Vector3(center.dx - innerSize / 2, center.dy - innerSize / 2, 0.0))
      ..scaleByVector3(Vector3(innerSize, innerSize, 1.0));
    final scaledInnerPath = innerPath.transform(innerMatrix.storage);

    final bounds = scaledInnerPath.getBounds();

    canvas.save();
    canvas.clipPath(scaledInnerPath);

    final paint = Paint()..style = PaintingStyle.fill;

    // Left half (Primary)
    paint.color = primary;
    canvas.drawRect(
      Rect.fromLTRB(bounds.left, bounds.top, bounds.center.dx, bounds.bottom),
      paint,
    );

    // Top-right (Secondary)
    paint.color = secondary;
    canvas.drawRect(
      Rect.fromLTRB(
          bounds.center.dx, bounds.top, bounds.right, bounds.center.dy),
      paint,
    );

    // Bottom-right (Tertiary)
    paint.color = tertiary;
    canvas.drawRect(
      Rect.fromLTRB(
          bounds.center.dx, bounds.center.dy, bounds.right, bounds.bottom),
      paint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _M3EMorphPalettePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.primary != primary ||
        oldDelegate.secondary != secondary ||
        oldDelegate.tertiary != tertiary ||
        oldDelegate.selectionBorderColor != selectionBorderColor;
  }
}
