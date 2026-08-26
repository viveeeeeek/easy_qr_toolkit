import 'package:easy_qr_toolkit/core/enums/qr_type.dart';
import 'package:easy_qr_toolkit/core/theme/m3_expressive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../provider/history_provider.dart';

class HistoryFilterChips extends ConsumerWidget {
  final String activeFilter;

  const HistoryFilterChips({super.key, required this.activeFilter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = [
      'All',
      ...QrType.values
          .where((e) => e != QrType.other)
          .map((e) => e.displayName)
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: filters.map((filter) {
          final isSelected = activeFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: M3EChip(
              label: filter,
              type: M3EChipType.filter,
              selected: isSelected,
              onPressed: () {
                ref.read(historyProvider.notifier).changeFilter(filter);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
