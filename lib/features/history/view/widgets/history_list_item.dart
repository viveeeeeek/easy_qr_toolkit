
import 'package:easy_qr_toolkit/core/enums/scan_type.dart';
import 'package:easy_qr_toolkit/core/extensions/int.dart';
import 'package:easy_qr_toolkit/features/history/scan_data_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/history_provider.dart';
import '../../provider/vcard_cache_provider.dart';

class HistoryListItem extends ConsumerStatefulWidget {
  final ScanDataModel item;
  final VoidCallback onTap;

  const HistoryListItem({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  ConsumerState<HistoryListItem> createState() => _HistoryListItemState();
}

class _HistoryListItemState extends ConsumerState<HistoryListItem> {
  @override
  void initState() {
    super.initState();
    _checkVCardResolution();
  }

  @override
  void didUpdateWidget(HistoryListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.content != oldWidget.item.content) {
      _checkVCardResolution();
    }
  }

  void _checkVCardResolution() {
    final type = widget.item.type;
    final content = widget.item.content;

    // Trigger resolution if needed (fire and forget, provider handles dedup)
    if (type == 'contact' || content.startsWith('BEGIN:VCARD')) {
       // We use read here because we just want to trigger the action
       // The watch below will handle the UI update
       ref.read(vCardCacheProvider.notifier).resolve(content);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Determine Display Name efficiently
    final type = widget.item.type;
    final content = widget.item.content;
    String displayName = content;

    if (type == 'contact' || content.startsWith('BEGIN:VCARD')) {
      // Watch ONLY the specific entry for this content
      final cachedName = ref.watch(
        vCardCacheProvider.select((map) => map[content])
      );
      
      // Use cached name if available, otherwise show placeholder or raw content
      displayName = cachedName ?? 'Contact Card';
    }
    
    return ListTile(
      onTap: widget.onTap,
      title: Text(
        displayName,
        style: const TextStyle(fontWeight: FontWeight.w500),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(widget.item.date.toDateTime.formattedDateTime),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () {
          if (widget.item.id != null) {
            ref.read(historyProvider.notifier).deleteScan(widget.item.id!);
          }
        },
      ),
    );
  }
}

