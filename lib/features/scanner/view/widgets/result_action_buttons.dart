import 'package:easy_qr_toolkit/core/theme/m3_expressive.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
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
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            M3EButton.icon(
              style: M3EButtonStyle.tonal,
              size: M3EButtonSize.sm,
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: const Text('Copy'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: content));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied to clipboard')),
                );
              },
            ),
            M3EButton.icon(
              style: M3EButtonStyle.tonal,
              size: M3EButtonSize.sm,
              icon: const Icon(Icons.share_rounded, size: 18),
              label: const Text('Share'),
              onPressed: () => Share.share(
                'Scanned with Easy QR Toolkit:\n'
                '$content\n\n'
                'Get the app: https://play.google.com/store/apps/details?id=com.billionants.easy_qr_toolkit',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: M3EButton(
            style: M3EButtonStyle.filled,
            size: M3EButtonSize.md,
            onPressed: onScanAgain,
            child: const Text('Scan Another Code'),
          ),
        ),
      ],
    );
  }
}
