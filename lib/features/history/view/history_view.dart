import 'dart:typed_data';

import 'package:easy_qr_toolkit/core/enums/scan_type.dart';
import 'package:easy_qr_toolkit/core/extensions/int.dart';
import 'package:easy_qr_toolkit/core/extensions/sizedbox.dart';
import 'package:easy_qr_toolkit/features/history/history_provider.dart';
import 'package:easy_qr_toolkit/features/history/scan_data_model.dart';
import 'package:easy_qr_toolkit/features/scanner/view/widgets/result_data_section.dart';
import 'package:easy_qr_toolkit/features/scanner/view/widgets/smart_action_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saver_gallery/saver_gallery.dart';

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
                  child: _buildFilterChips(ref, state.filter),
                ),
              ),
            ),
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
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
                          item.type.toLowerCase() == filter.toLowerCase())
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
                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        child: Icon(ScanType.fromString(item.type).icon),
                      ),
                      onTap: () => _showDetailsBottomSheet(context, item),
                      title: Text(
                        item.content,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(item.date.toDateTime.formattedDateTime),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          if (item.id != null) {
                            ref
                                .read(historyProvider.notifier)
                                .deleteScan(item.id!);
                          }
                        },
                      ),
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

  Widget _buildFilterChips(WidgetRef ref, String activeFilter) {
    final filters = ['All', ...ScanType.values.where((e) => e != ScanType.other).map((e) => e.displayName)];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: filters.map((filter) {
          final isSelected = activeFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (bool value) {
                ref.read(historyProvider.notifier).changeFilter(filter);
              },
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showDetailsBottomSheet(BuildContext context, ScanDataModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   // Handle
                  Center(
                    child: Container(
                      width: 32,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                       physics: const BouncingScrollPhysics(),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.stretch,
                         children: [
                            // Type Badge
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  ScanType.fromString(item.type).label,
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            ResultDataSection(content: item.content),
                            const SizedBox(height: 24),
                            SmartActionButtons(content: item.content, type: item.type),
                            const SizedBox(height: 24),
          
                            // View/Download QR Button
                            OutlinedButton.icon(
                              onPressed: () => _showQRImageDialog(context, item.image, item.content),
                              icon: const Icon(Icons.qr_code_2),
                              label: const Text('View Original QR Code'),
                               style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(color: theme.colorScheme.outlineVariant),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            Center(
                              child: Text(
                                DateTime.fromMillisecondsSinceEpoch(item.date).formattedDateTime,
                                style: TextStyle(
                                  color: theme.colorScheme.outline,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                         ]
                       ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showQRImageDialog(BuildContext context, Uint8List imageBytes, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(imageBytes),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilledButton.icon(
                  onPressed: () async {
                    // Save logic could go here
                     try {
                      final result = await SaverGallery.saveImage(
                        imageBytes,
                        name: 'scan_${DateTime.now().millisecondsSinceEpoch}',
                        androidExistNotSave: false,
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result.isSuccess ? 'Saved to Gallery' : 'Failed to save')),
                        );
                      }
                    } catch (e) {
                       if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(content: Text('Error saving: $e')),
                        );
                       }
                    }
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
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
