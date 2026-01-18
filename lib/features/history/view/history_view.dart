import 'dart:typed_data';

import 'package:easy_qr_toolkit/features/history/provider/history_state.dart';
import 'package:easy_qr_toolkit/features/history/scan_data_model.dart';
import 'package:easy_qr_toolkit/features/history/view/widgets/history_details_sheet_content.dart';
import 'package:easy_qr_toolkit/features/history/view/widgets/history_filter_chips.dart';
import 'package:easy_qr_toolkit/features/history/view/widgets/history_list_item.dart';
import 'package:easy_qr_toolkit/features/history/view/widgets/qr_image_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums/scan_type.dart';
import '../provider/history_provider.dart';

class QRScanHistoryView extends ConsumerStatefulWidget {
  const QRScanHistoryView({super.key});

  @override
  ConsumerState<QRScanHistoryView> createState() => _QRScanHistoryViewState();
}

class _QRScanHistoryViewState extends ConsumerState<QRScanHistoryView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Re-build UI when search text changes (for clear button visibility)
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(historyProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Large App Bar
          SliverAppBar.large(
            pinned: true,
            scrolledUnderElevation: 0,
            title: const Text('Scan History'),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_sweep_outlined),
                onPressed: () => _showClearAllDialog(context),
                tooltip: 'Clear All',
              ),
            ],
          ),

          // 2. Search Bar (Not pinned, scrolls away for better UX)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  ref.read(historyProvider.notifier).setSearchQuery(value);
                },
                decoration: InputDecoration(
                  hintText: 'Search history...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            _searchController.clear();
                            ref
                                .read(historyProvider.notifier)
                                .setSearchQuery('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
          ),

          // 3. Filter Content (Wait for data)
          ...historyAsync.when(
            data: (state) => [
              SliverPersistentHeader(
                pinned: true,
                delegate: _PinnedFilterChipsDelegate(
                  child: Container(
                    height: 60,
                    // Force the color to match the background to prevent "AppBar color bleed"
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: HistoryFilterChips(activeFilter: state.filter),
                  ),
                ),
              ),
              _buildListSliver(state),
            ],
            loading: () => [
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
            error: (err, _) => [
              SliverFillRemaining(
                child: Center(child: Text('Error: $err')),
              ),
            ],
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 48)),
        ],
      ),
    );
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to delete all scan history? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(historyProvider.notifier).clearAllScans();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  Widget _buildListSliver(HistoryState historyState) {
    final filter = historyState.filter;
    final query = historyState.searchQuery.toLowerCase();
    final scans = historyState.scans;

    final filteredData = scans.reversed.where((item) {
      final matchesType = filter == 'All' ||
          ScanType.fromString(item.type).displayName == filter;
      final matchesSearch = query.isEmpty ||
          item.content.toLowerCase().contains(query) ||
          ScanType.fromString(item.type).displayName.toLowerCase().contains(query);
      return matchesType && matchesSearch;
    }).toList();

    if (filteredData.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                query.isNotEmpty ? Icons.search_off_rounded : Icons.history_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                query.isNotEmpty
                    ? 'No results for "$query"'
                    : filter == 'All'
                        ? 'No scan history found'
                        : 'No $filter scans found',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
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
  double get maxExtent => 60.0;

  @override
  double get minExtent => 60.0;

  @override
  bool shouldRebuild(covariant _PinnedFilterChipsDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
