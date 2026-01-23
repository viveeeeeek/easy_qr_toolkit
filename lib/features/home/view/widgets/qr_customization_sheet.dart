import 'dart:io';

import 'package:easy_qr_toolkit/core/extensions/color_extension.dart';
import 'package:easy_qr_toolkit/core/extensions/sizedbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/enums/qr_shape.dart';
import '../../generator_provider.dart';

class QrCustomizationSheet extends ConsumerWidget {
  const QrCustomizationSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
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
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: QrShape.values.map((shape) {
              final isSelected = shape == selectedShape;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(
                      shape.name[0].toUpperCase() + shape.name.substring(1)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      _updateShape(ref, shape);
                    }
                  },
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
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
    generator.generateImage();
  }
}

class _QrColorPicker extends ConsumerWidget {
  const _QrColorPicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedColor = ref.watch(generatorProvider.select((s) => s.qrColor));

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
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: colors.length,
            separatorBuilder: (context, index) => 12.w,
            itemBuilder: (context, index) {
              final color = colors[index];
              final isSelected = color.value == selectedColor.value;

              return GestureDetector(
                onTap: () => _updateColor(ref, color),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 44,
                  height: 44,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? context.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                      ],
                    ),
                  ),
                ),
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
    generator.generateImage();
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
                    color: context.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: context.outlineVariant.withOpacity(0.5),
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
            if (selectedLogo != null) ...[
              16.w,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Size',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    8.h,
                    SegmentedButton<double>(
                      segments: const [
                        ButtonSegment(value: 0.15, label: Text('Small')),
                        ButtonSegment(value: 0.20, label: Text('Medium')),
                        ButtonSegment(value: 0.25, label: Text('Large')),
                      ],
                      selected: {logoScale},
                      onSelectionChanged: (Set<double> newSelection) {
                        ref.read(generatorProvider.notifier).updateState(
                              logoScale: newSelection.first,
                            );
                      },
                      style: ButtonStyle(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        padding: WidgetStateProperty.all(EdgeInsets.zero),
                      ),
                      showSelectedIcon: false,
                    ),
                  ],
                ),
              ),
              8.w,
              IconButton(
                onPressed: () => _clearLogo(ref),
                icon: const Icon(Icons.close_rounded),
                color: context.error,
                tooltip: 'Remove',
              ),
            ] else ...[
              16.w,
              Expanded(
                child: Text(
                  'Embed a logo',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          ],
        ),
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
      generator.generateImage();
    }
  }

  void _clearLogo(WidgetRef ref) {
    final generator = ref.read(generatorProvider.notifier);
    generator.updateState(clearLogo: true);
    generator.generateImage();
  }
}
