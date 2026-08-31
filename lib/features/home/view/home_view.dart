import 'package:easy_qr_toolkit/core/constants/app_constants.dart';
import 'package:easy_qr_toolkit/core/enums/qr_type.dart';
import 'package:easy_qr_toolkit/core/extensions/color_extension.dart';
import 'package:easy_qr_toolkit/core/extensions/sizedbox.dart';
import 'package:easy_qr_toolkit/core/theme/m3_expressive.dart';
import 'package:easy_qr_toolkit/features/home/generator_provider.dart';
import 'package:easy_qr_toolkit/features/scanner/view/qr_scan_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:material_ui/material_ui.dart';

import 'widgets/generated_qr_card.dart';
import 'widgets/qr_customization_sheet.dart';
import 'widgets/qr_type_selector.dart';
import 'widgets/smart_input_container.dart';

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
  QrType _selectedType = QrType.text;

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
    // Unfocus ANY active field when returning from another screen
    FocusManager.instance.primaryFocus?.unfocus();
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
    if (uri != null && uri.toString() == AppConstants.scanWidgetDeepLink) {
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
    final hasData =
        ref.watch(generatorProvider.select((s) => s.data.isNotEmpty));
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
                M3EIconButton(
                  variant: M3EIconButtonVariant.tonal,
                  onPressed: () {
                    _inputFocusNode.unfocus();
                    Navigator.pushNamed(context, AppRoutes.history);
                  },
                  icon: const Icon(Icons.history_rounded),
                  tooltip: 'History',
                ),
                const SizedBox(width: 8),
                M3EIconButton(
                  variant: M3EIconButtonVariant.tonal,
                  onPressed: () {
                    _inputFocusNode.unfocus();
                    Navigator.pushNamed(context, AppRoutes.settings);
                  },
                  icon: const Icon(Icons.settings_outlined),
                  tooltip: 'Settings',
                ),
                const SizedBox(width: 12),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Type Selector and Input Form - use Visibility to preserve state
                  Visibility(
                    visible: !_isCustomizing,
                    maintainState: true,
                    maintainAnimation: true,
                    maintainSize: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        QrTypeSelector(
                          selectedType: _selectedType,
                          onTypeChanged: (type) {
                            if (_selectedType != type) {
                              setState(() => _selectedType = type);
                              ref.read(generatorProvider.notifier).reset();
                              if (_isTyping) {
                                setState(() => _isTyping = false);
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        SmartInputContainer(
                          selectedType: _selectedType,
                          focusNode: _inputFocusNode,
                          onTypingStateChanged: (isTyping) {
                            if (_isTyping != isTyping) {
                              setState(() => _isTyping = isTyping);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  // Use AnimatedSwitcher instead of AnimatedCrossFade for better performance
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
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
                              (isKeyboardOpen ? 16.h : 28.h),
                              GeneratedQRCard(isCompact: isKeyboardOpen),
                            ],
                          ),
                  ),
                  100.h,
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: shouldHideFab
          ? null
          : M3EExtendedFab(
              label: 'Scan QR',
              icon: const Icon(Icons.qr_code_scanner_rounded),
              extended: shouldExpandFab,
              color: M3EFabColor.primary,
              onPressed: () {
                _inputFocusNode.unfocus();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QRScanView()),
                );
              },
            ),
    );
  }
}
