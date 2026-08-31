import 'package:easy_qr_toolkit/core/enums/qr_type.dart';
import 'package:easy_qr_toolkit/core/extensions/int.dart';
import 'package:easy_qr_toolkit/core/theme/m3_expressive.dart';
import 'package:easy_qr_toolkit/core/utils/wifi_parser.dart';
import 'package:easy_qr_toolkit/features/history/scan_data_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

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

    if (type == 'contact' || content.startsWith('BEGIN:VCARD')) {
      ref.read(vCardCacheProvider.notifier).resolve(content);
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.item.type;
    final content = widget.item.content;
    String displayName = content;
    IconData iconData = Icons.qr_code_rounded;

    if (type == 'contact' || content.startsWith('BEGIN:VCARD')) {
      final cachedName =
          ref.watch(vCardCacheProvider.select((map) => map[content]));
      displayName = cachedName ?? 'Contact Card';
      iconData = Icons.person_rounded;
    } else if (type == 'wifi' || content.startsWith('WIFI:')) {
      final wifi = WifiParser.parse(content);
      displayName = wifi?.ssid ?? 'WiFi Network';
      iconData = Icons.wifi_rounded;
    } else if (type == 'url' || content.startsWith('http')) {
      iconData = Icons.link_rounded;
    } else if (type == 'geo' || content.startsWith('geo:')) {
      iconData = Icons.location_on_rounded;
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: M3ECard(
        variant: M3ECardVariant.filled,
        borderRadius: BorderRadius.circular(20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        onPressed: widget.onTap,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                iconData,
                color: colorScheme.onPrimaryContainer,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.item.date.toDateTime.formattedDateTime,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            M3EIconButton(
              variant: M3EIconButtonVariant.standard,
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Delete',
              onPressed: () {
                if (widget.item.id != null) {
                  ref
                      .read(historyProvider.notifier)
                      .deleteScan(widget.item.id!);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

