import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class ResultActionButtons extends StatelessWidget {
  final String content;
  final VoidCallback onScanAgain;

  const ResultActionButtons({
    super.key,
    required this.content,
    required this.onScanAgain,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: content));
              },
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                Share.share(content);
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        FilledButton.tonal(
          onPressed: onScanAgain,
          child: const Text('Scan Again'),
        ),
      ],
    );
  }
}
