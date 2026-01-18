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
import 'package:easy_qr_toolkit/features/settings/view/theme_settings_bottom_sheet.dart';
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
