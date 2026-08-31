import 'dart:io';

import 'package:easy_qr_toolkit/core/extensions/color_extension.dart';
import 'package:easy_qr_toolkit/core/extensions/sizedbox.dart';
import 'package:easy_qr_toolkit/core/theme/m3_expressive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_new_shapes/material_new_shapes.dart';
import 'package:material_ui/material_ui.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

import '../../../../core/enums/qr_shape.dart';
import '../../generator_provider.dart';

class QrCustomizationSheet extends ConsumerWidget {
  const QrCustomizationSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 64),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          24.h,
          Text(
            'Customize QR',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          24.h,
          const _QrStylePicker(),
          24.h,
          const _QrColorPicker(),
          24.h,
          const _QrLogoPicker(),
          16.h,
        ],
      ),
    );
  }
}

class _QrStylePicker extends ConsumerWidget {
  const _QrStylePicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedShape = ref.watch(generatorProvider.select((s) => s.shape));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Style',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        12.h,
        SizedBox(
          width: double.infinity,
          child: M3EButtonGroup(
            type: M3EButtonGroupType.connected,
            style: M3EButtonStyle.tonal,
            selectedIndex: selectedShape.index,
            onSelectedIndexChanged: (index) {
              if (index != null &&
                  index >= 0 &&
                  index < QrShape.values.length) {
                _updateShape(ref, QrShape.values[index]);
              }
            },
            actions: QrShape.values.map((shape) {
              return M3EButtonGroupAction(
                label: Text(
                  shape.name[0].toUpperCase() + shape.name.substring(1),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _updateShape(WidgetRef ref, QrShape shape) {
    final generator = ref.read(generatorProvider.notifier);
    generator.updateState(shape: shape);
  }
}

class _QrColorPicker extends ConsumerWidget {
  const _QrColorPicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedColor =
        ref.watch(generatorProvider.select((s) => s.qrColor));

    // Curated M3-safe colors for QR codes (high contrast)
    final colors = [
      Colors.black,
      context.primary,
      context.secondary,
      const Color(0xFF1B5E20), // Deep Green
      const Color(0xFF0D47A1), // Deep Blue
      const Color(0xFFB71C1C), // Deep Red
      const Color(0xFF4A148C), // Deep Purple
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        12.h,
        SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: colors.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final color = colors[index];
              final isSelected =
                  color.toARGB32() == selectedColor.toARGB32();

              return _QrColorMorphSwatchItem(
                color: color,
                isSelected: isSelected,
                onTap: () => _updateColor(ref, color),
              );
            },
          ),
        ),
      ],
    );
  }

  void _updateColor(WidgetRef ref, Color color) {
    final generator = ref.read(generatorProvider.notifier);
    generator.updateState(qrColor: color);
  }
}

class _QrColorMorphSwatchItem extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  static final Morph _morph = Morph(
    MaterialShapes.circle,
    MaterialShapes.verySunny,
  );

  const _QrColorMorphSwatchItem({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 52,
        height: 52,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(
            begin: isSelected ? 1.0 : 0.0,
            end: isSelected ? 1.0 : 0.0,
          ),
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          builder: (context, progress, child) {
            return CustomPaint(
              size: const Size(52, 52),
              painter: _M3ESingleColorMorphPainter(
                morph: _morph,
                progress: progress,
                color: color,
                selectionBorderColor: Theme.of(context).colorScheme.primary,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _M3ESingleColorMorphPainter extends CustomPainter {
  final Morph morph;
  final double progress;
  final Color color;
  final Color selectionBorderColor;

  _M3ESingleColorMorphPainter({
    required this.morph,
    required this.progress,
    required this.color,
    required this.selectionBorderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const innerSize = 38.0;
    const outerSize = 48.0;

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

    // 2. Draw inner morphing color fill
    final innerPath = morph.toPath(progress: progress);
    final innerMatrix = Matrix4.identity()
      ..translateByVector3(
          Vector3(center.dx - innerSize / 2, center.dy - innerSize / 2, 0.0))
      ..scaleByVector3(Vector3(innerSize, innerSize, 1.0));
    final scaledInnerPath = innerPath.transform(innerMatrix.storage);

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(scaledInnerPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _M3ESingleColorMorphPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.selectionBorderColor != selectionBorderColor;
  }
}

class _QrLogoPicker extends ConsumerWidget {
  const _QrLogoPicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLogo = ref.watch(generatorProvider.select((s) => s.logo));
    final logoScale = ref.watch(generatorProvider.select((s) => s.logoScale));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Logo',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        12.h,
        Row(
          children: [
            GestureDetector(
              onTap: () => _pickLogo(ref),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 64,
                height: 64,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: selectedLogo != null
                        ? context.primary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: context.surfaceVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: context.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: selectedLogo != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            selectedLogo,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(Icons.add_photo_alternate_outlined),
                ),
              ),
            ),
            16.w,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedLogo != null ? 'Logo Selected' : 'Embed a logo',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    selectedLogo != null
                        ? 'Tap image to change'
                        : 'Displays in center of QR',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            if (selectedLogo != null) ...[
              8.w,
              M3EIconButton(
                variant: M3EIconButtonVariant.tonal,
                onPressed: () => _clearLogo(ref),
                icon: const Icon(Icons.close_rounded),
                tooltip: 'Remove',
              ),
            ],
          ],
        ),
        if (selectedLogo != null) ...[
          14.h,
          Text(
            'Size',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: context.onSurfaceVariant,
                ),
          ),
          8.h,
          SizedBox(
            width: double.infinity,
            child: M3EButtonGroup(
              type: M3EButtonGroupType.connected,
              style: M3EButtonStyle.tonal,
              selectedIndex: logoScale <= 0.16
                  ? 0
                  : (logoScale <= 0.22 ? 1 : 2),
              onSelectedIndexChanged: (index) {
                if (index == null) return;
                final scale = switch (index) {
                  0 => 0.15,
                  1 => 0.20,
                  _ => 0.25,
                };
                ref.read(generatorProvider.notifier).updateState(
                      logoScale: scale,
                    );
              },
              actions: const [
                M3EButtonGroupAction(label: Text('Small')),
                M3EButtonGroupAction(label: Text('Medium')),
                M3EButtonGroupAction(label: Text('Large')),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _pickLogo(WidgetRef ref) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 200,
      maxHeight: 200,
    );

    if (image != null) {
      final generator = ref.read(generatorProvider.notifier);
      generator.updateState(logo: File(image.path));
    }
  }

  void _clearLogo(WidgetRef ref) {
    final generator = ref.read(generatorProvider.notifier);
    generator.updateState(clearLogo: true);
  }
}
