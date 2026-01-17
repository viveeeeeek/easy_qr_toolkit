import 'dart:typed_data';

import 'package:easy_qr_toolkit/features/history/history_provider.dart';
import 'package:easy_qr_toolkit/features/history/scan_data_model.dart';
import 'package:easy_qr_toolkit/features/history/view/widgets/history_details_sheet_content.dart';
import 'package:easy_qr_toolkit/features/history/view/widgets/history_filter_chips.dart';
import 'package:easy_qr_toolkit/features/history/view/widgets/history_list_item.dart';
import 'package:easy_qr_toolkit/features/history/view/widgets/qr_image_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums/scan_type.dart';

class QRScanHistoryView extends ConsumerWidget {
  const QRScanHistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider);

    return Scaffold(
      body: CustomScrollView(
        // High-quality bouncing physics (Material You feel)
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          // 1. Collapsing App Bar
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            stretch: true,
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final double top = constraints.biggest.height;
                // Standard height of a collapsed app bar + status bar
                final bool isCollapsed = top <=
                    kToolbarHeight + MediaQuery.of(context).padding.top + 70;

                return FlexibleSpaceBar(
                  stretchModes: const [
                    StretchMode.zoomBackground,
                    StretchMode.blurBackground,
                  ],
                  titlePadding: EdgeInsetsDirectional.only(
                    start: isCollapsed ? 56 : 20,
                    bottom: 16,
                  ),
                  title: Text(
                    'Scan History',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 22,
                    ),
                  ),
                  centerTitle: false,
                );
              },
            ),
          ),

          // 2. Pinned Filter Chips
          historyAsync.when(
            data: (state) => SliverPersistentHeader(
              pinned: true,
              delegate: _PinnedFilterChipsDelegate(
                child: Container(
                  height: 70,
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: HistoryFilterChips(activeFilter: state.filter),
                ),
              ),
            ),
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (_, __) =>
                const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),

          // 3. The List of Scans
          historyAsync.when(
            data: (historyState) {
              final filter = historyState.filter;
              final scans = historyState.scans;

              final filteredData = filter == 'All'
                  ? scans.reversed.toList()
                  : scans.reversed
                      .where((item) =>
                          ScanType.fromString(item.type).displayName == filter)
                      .toList();

              if (filteredData.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      filter == 'All'
                          ? 'No scan history found'
                          : 'No $filter scans found',
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = filteredData[index];
                    return HistoryListItem(
                      item: item,
                      onTap: () => _showDetailsBottomSheet(context, item),
                    );
                  },
                  childCount: filteredData.length,
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(child: Text('Error: $err')),
            ),
          ),

          // Extra space at bottom for better feel
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  void _showDetailsBottomSheet(BuildContext context, ScanDataModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return HistoryDetailsSheetContent(
          item: item,
          onViewQrCode: (image, content) =>
              _showQRImageDialog(context, image, content),
        );
      },
    );
  }

  void _showQRImageDialog(
      BuildContext context, Uint8List imageBytes, String content) {
    showDialog(
      context: context,
      builder: (context) => QRImageDialog(imageBytes: imageBytes),
    );
  }
}

class _PinnedFilterChipsDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _PinnedFilterChipsDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 70.0;

  @override
  double get minExtent => 70.0;

  @override
  bool shouldRebuild(covariant _PinnedFilterChipsDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
