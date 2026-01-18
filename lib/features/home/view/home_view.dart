import 'package:easy_qr_toolkit/core/extensions/color_extension.dart';
import 'package:easy_qr_toolkit/core/extensions/sizedbox.dart';
import 'package:easy_qr_toolkit/features/scanner/view/qr_scan_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../settings/view/theme_settings_bottom_sheet.dart';
import '../generator_provider.dart';
import 'widgets/generate_qr_textfield.dart';
import 'widgets/generated_qr_card.dart';
import 'widgets/qr_customization_sheet.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  final ScrollController _scrollController = ScrollController();
  bool _isFabExpanded = true;
  bool _isCustomizing = false;

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
    if (_scrollController.position.pixels > 50 && _isFabExpanded) {
      setState(() => _isFabExpanded = false);
    } else if (_scrollController.position.pixels <= 50 && !_isFabExpanded) {
      setState(() => _isFabExpanded = true);
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
            SliverAppBar.medium(
              title: const Text('Generate QR'),
              centerTitle: false,
              actions: [
                IconButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.history),
                  icon: const Icon(Icons.history_rounded),
                  tooltip: 'History',
                ),
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      showDragHandle: true,
                      builder: (context) => const ThemeSettingsBottomSheet(),
                    );
                  },
                  icon: const Icon(Icons.palette_outlined),
                  tooltip: 'Theme',
                ),
                const SizedBox(width: 8),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  AnimatedSize(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOutCubicEmphasized,
                    child: _isCustomizing 
                      ? const SizedBox.shrink() 
                      : const ModernQRInputCard(),
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox(width: double.infinity),
                    secondChild: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Dynamic spacing based on keyboard
                        (isKeyboardOpen ? 16.h : 32.h),

                        // The main QR Card
                        GeneratedQRCard(isCompact: isKeyboardOpen),

                        if (!isKeyboardOpen && !_isCustomizing) ...[
                          32.h,
                          Center(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                setState(() => _isCustomizing = true);
                                await showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  showDragHandle: true,
                                  // barrierColor: Colors.black.withOpacity(0.05), // Nearly transparent but keeps focus logic
                                  backgroundColor:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  builder: (context) =>
                                      const QrCustomizationSheet(),
                                );
                                if (mounted) {
                                  setState(() => _isCustomizing = false);
                                }
                              },
                              icon: const Icon(Icons.tune_rounded),
                              label: const Text('Customize Style'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    crossFadeState: generatorState.data.isEmpty
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    duration: const Duration(milliseconds: 600),
                    sizeCurve: Curves.easeOutCubic,
                    // Use a layout builder to ensure top-center alignment during transition
                    layoutBuilder: (topChild, topChildKey, bottomChild, bottomChildKey) {
                      return Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.topCenter,
                        children: [
                          Positioned(
                            key: bottomChildKey,
                            top: 0,
                            left: 0,
                            right: 0,
                            child: bottomChild,
                          ),
                          Positioned(
                            key: topChildKey,
                            child: topChild,
                          ),
                        ],
                      );
                    },
                  ),
                  // Extra padding at bottom for FAB
                  100.h,
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: isKeyboardOpen || _isCustomizing
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QRScanView()),
                );
              },
              icon: const Icon(Icons.qr_code_scanner_rounded),
              label: const Text('Scan QR'),
              isExtended: _isFabExpanded,
            ),
    );
  }
}
