import 'package:easy_qr_toolkit/core/enums/scan_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/history_provider.dart';

class HistoryFilterChips extends ConsumerWidget {
  final String activeFilter;

  const HistoryFilterChips({super.key, required this.activeFilter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
}
