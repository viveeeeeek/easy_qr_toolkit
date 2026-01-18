import 'dart:io';

import 'package:easy_qr_toolkit/core/constants/app_constants.dart';
import 'package:easy_qr_toolkit/core/extensions/color_extension.dart';
import 'package:easy_qr_toolkit/core/extensions/sizedbox.dart';
import 'package:easy_qr_toolkit/core/utils/custom_snackbar.dart';
import 'package:easy_qr_toolkit/features/generator/generator_provider.dart';
import 'package:easy_qr_toolkit/features/scanner/view/qr_scan_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import '../../../core/services/qr_service.dart';
import 'package:easy_qr_toolkit/core/enums/qr_shape.dart';
import 'package:easy_qr_toolkit/features/settings/view/theme_settings_bottom_sheet.dart';
import 'package:image_picker/image_picker.dart';
import 'widgets/generate_qr_textfield.dart';
import 'widgets/generated_qr_card.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  final ScrollController _scrollController = ScrollController();
  bool _isFabExpanded = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels > 100 && _isFabExpanded) {
      setState(() {
        _isFabExpanded = false;
      });
    } else if (_scrollController.position.pixels <= 100 && !_isFabExpanded) {
      setState(() {
        _isFabExpanded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final generatorState = ref.watch(generatorProvider);
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 100;

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildSliverAppBar(context),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: isKeyboardOpen ? 10.0 : 20.0,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const ModernQRInputCard(),
                    (isKeyboardOpen ? 8.h : 24.h),
                    if (generatorState.data.isNotEmpty) ...[
                      const _QrStylePicker(),
                      (isKeyboardOpen ? 8.h : 20.h),
                      const _QrColorPicker(),
                      (isKeyboardOpen ? 8.h : 20.h),
                      const _QrLogoPicker(),
                      (isKeyboardOpen ? 8.h : 24.h),
                    ],
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: animation,
                            child: child,
                          ),
                        );
                      },
                      child: generatorState.data.isNotEmpty
                          ? GeneratedQRCard(isCompact: isKeyboardOpen)
                          : const SizedBox.shrink(),
                    ),
                    80.h, // spacing for fab
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context, isKeyboardOpen),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar.large(
      title: const Text('Generate'),
      actions: [
        IconButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              showDragHandle: true,
              isScrollControlled: true,
              builder: (context) => const ThemeSettingsBottomSheet(),
            );
          },
          icon: const Icon(Icons.palette_outlined),
        ),
        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.history);
          },
          icon: const Icon(Icons.history),
        ),
        IconButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('About'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: context.primary,
                        child: Icon(
                          Icons.person_2_outlined,
                          color: context.onPrimary,
                          size: 25,
                        ),
                      ),
                      20.h,
                      const Text('Made with <3 by VivekS.'),
                    ],
                  ),
                );
              },
            );
          },
          icon: const Icon(Icons.info_outline_rounded),
        )
      ],
    );
  }

  Widget _buildFloatingActionButton(BuildContext context, bool isKeyboardOpen) {
    if (isKeyboardOpen) return const SizedBox.shrink();

    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const QRScanView(),
          ),
        );
      },
      icon: const Icon(Icons.qr_code_scanner_rounded),
      label: const Text('Scan QR'),
      isExtended: _isFabExpanded,
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
          'QR Style',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        8.h,
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
                    borderRadius: BorderRadius.circular(12),
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

    // We update the shape in the state
    generator.updateState(shape: shape);

    // Trigger re-generation of the image with the new shape
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
          'QR Color',
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
                      color: isSelected
                          ? context.primary
                          : Colors.transparent,
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
              OutlinedButton.icon(
                onPressed: () => _clearLogo(ref),
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('Clear'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.error,
                  side: BorderSide(color: context.error.withOpacity(0.5)),
                ),
              ),
            ] else ...[
              16.w,
              Text(
                'Add a brand logo to your QR',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.onSurfaceVariant,
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