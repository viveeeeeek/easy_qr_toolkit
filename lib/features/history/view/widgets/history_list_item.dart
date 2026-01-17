
import 'package:easy_qr_toolkit/core/enums/scan_type.dart';
import 'package:easy_qr_toolkit/core/extensions/int.dart';
import 'package:easy_qr_toolkit/features/history/history_provider.dart';
import 'package:easy_qr_toolkit/features/history/scan_data_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HistoryListItem extends ConsumerWidget {
  final ScanDataModel item;
  final VoidCallback onTap;

  const HistoryListItem({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(ScanType.fromString(item.type).icon),
      ),
      onTap: onTap,
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
            ref.read(historyProvider.notifier).deleteScan(item.id!);
          }
        },
      ),
    );
  }
}
