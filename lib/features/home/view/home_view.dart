import 'package:easy_qr_toolkit/core/extensions/color_extension.dart';
import 'package:easy_qr_toolkit/core/extensions/sizedbox.dart';
import 'package:easy_qr_toolkit/features/scanner/view/qr_scan_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

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

class _HomeViewState extends ConsumerState<HomeView> with RouteAware {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();
  bool _isFabExpanded = true;
  bool _isCustomizing = false;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _checkForWidgetLaunch();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route changes to handle focus
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      AppRoutes.routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    AppRoutes.routeObserver.unsubscribe(this);
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  // Called when returning to this route from another
  @override
  void didPopNext() {
    // Unfocus when returning from another screen
    _inputFocusNode.unfocus();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels > 50 && _isFabExpanded) {
      setState(() => _isFabExpanded = false);
    } else if (_scrollController.position.pixels <= 50 && !_isFabExpanded) {
      setState(() => _isFabExpanded = true);
    }
  }

  void _checkForWidgetLaunch() {
    HomeWidget.widgetClicked.listen(_handleLaunch);
  }

  void _handleLaunch(Uri? uri) {
    if (uri != null && uri.toString() == 'esqr://scan') {
      // Small delay to ensure route is ready and frame is rendered
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          Navigator.of(context).pushNamed(AppRoutes.scan);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only rebuild HomeView if strictly necessary (keyboard or data existence)
    final hasData = ref.watch(generatorProvider.select((s) => s.data.isNotEmpty));
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 100;

    // FAB visibility: hide when user is typing (keyboard open + started typing) OR customizing
    final shouldHideFab = (isKeyboardOpen && _isTyping) || _isCustomizing;
    
    // FAB expansion: minimize when QR is generated OR scrolled
    final shouldExpandFab = _isFabExpanded && !hasData;

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
                  onPressed: () {
                    // Unfocus before navigating
                    _inputFocusNode.unfocus();
                    Navigator.pushNamed(context, AppRoutes.history);
                  },
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
                      : ModernQRInputCard(
                          focusNode: _inputFocusNode,
                          onTypingStateChanged: (isTyping) {
                            if (_isTyping != isTyping) {
                              setState(() => _isTyping = isTyping);
                            }
                          },
                        ),
                  ),
                  // Use AnimatedSwitcher instead of AnimatedCrossFade for better performance
                  // AnimatedSwitcher only builds the CURRENT child, not both.
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    // Simple fade only - no size animation to avoid layout recalculations
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    child: !hasData
                        ? const SizedBox.shrink(key: ValueKey('empty'))
                        : Column(
                            key: const ValueKey('qr_content'),
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
                  ),
                  // Extra padding at bottom for FAB
                  100.h,
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: shouldHideFab
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                // Unfocus before navigating
                _inputFocusNode.unfocus();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QRScanView()),
                );
              },
              icon: const Icon(Icons.qr_code_scanner_rounded),
              label: const Text('Scan QR'),
              isExtended: shouldExpandFab,
            ),
    );
  }
}
