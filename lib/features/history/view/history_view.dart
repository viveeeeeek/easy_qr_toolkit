import 'package:easy_qr_toolkit/core/extensions/int.dart';
import 'package:easy_qr_toolkit/core/extensions/sizedbox.dart';
import 'package:easy_qr_toolkit/features/history/history_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QRScanHistoryView extends ConsumerWidget {
  const QRScanHistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, _) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  double top = constraints.biggest.height;
                  return FlexibleSpaceBar(
                    titlePadding: EdgeInsets.only(
                      left: top == MediaQuery.of(context).padding.top + kToolbarHeight ? 60 : 20,
                      bottom: 15,
                    ),
                    title: const Text(
                      'Scan History',
                      style: TextStyle(fontSize: 22),
                    ),
                  );
                },
              ),
            )
          ];
        },
        body: historyAsync.when(
          data: (data) {
            final reversedData = data.reversed.toList();
            if (reversedData.isEmpty) {
              return const Center(child: Text('No scan history found'));
            }
            return ListView.builder(
              itemCount: reversedData.length,
              itemBuilder: (context, index) {
                final item = reversedData[index];
                return ListTile(
                  onTap: () => _showDetailsDialog(context, item),
                  title: Text(
                    item.content,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(item.date.toDateTime.formattedDateTime),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      if (item.id != null) {
                        ref.read(historyProvider.notifier).deleteScan(item.id!);
                      }
                    },
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  void _showDetailsDialog(BuildContext context, dynamic item) {
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
                borderRadius: BorderRadius.circular(8.0),
                child: SizedBox(
                  height: 150,
                  width: 150,
                  child: Image.memory(
                    item.image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            20.h,
            Text(item.content),
            20.h,
            Text(
              DateTime.fromMillisecondsSinceEpoch(item.date).toString(),
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        );
      },
    );
  }
}
