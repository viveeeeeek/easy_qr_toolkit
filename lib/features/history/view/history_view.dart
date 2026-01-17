import 'dart:typed_data';

import 'package:easy_qr_toolkit/core/extensions/int.dart';
import 'package:easy_qr_toolkit/core/extensions/sizedbox.dart';
import 'package:easy_qr_toolkit/features/history/history_provider.dart';
import 'package:easy_qr_toolkit/features/history/scan_data_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_qr_toolkit/features/scanner/view/widgets/result_data_section.dart';
import 'package:easy_qr_toolkit/features/scanner/view/widgets/smart_action_buttons.dart';

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
                        child: Icon(_getIconForType(item.type)),
                      ),
                      onTap: () => _showDetailsDialog(context, item),
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
    final filters = ['All', 'URL', 'WiFi', 'ContactInfo', 'Text'];

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

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'url':
        return Icons.link;
      case 'wifi':
        return Icons.wifi;
      case 'contactinfo':
        return Icons.person_outline;
      case 'geo':
        return Icons.map_outlined;
      default:
        return Icons.subject;
    }
  }

  void _showDetailsDialog(BuildContext context, ScanDataModel item) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: SizedBox(
                  height: 180,
                  width: 180,
                  child: Image.memory(
                    item.image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            ResultDataSection(content: item.content),
            SmartActionButtons(content: item.content, type: item.type),
            10.h,
            Center(
              child: Text(
                DateTime.fromMillisecondsSinceEpoch(item.date).formattedDateTime,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        );
      },
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
