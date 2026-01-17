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
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildUtilityButton(
              context,
              icon: Icons.copy,
              label: 'Copy',
              onTap: () {
                Clipboard.setData(ClipboardData(text: content));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied to clipboard')),
                );
              },
            ),
            _buildUtilityButton(
              context,
              icon: Icons.share,
              label: 'Share',
              onTap: () => Share.share(content),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton(
            onPressed: onScanAgain,
            style: FilledButton.styleFrom(
              elevation: 0,
              backgroundColor: Theme.of(context).colorScheme.inverseSurface,
              foregroundColor: Theme.of(context).colorScheme.onInverseSurface,
            ),
            child: const Text('Scan Another Code'),
          ),
        ),
      ],
    );
  }

  Widget _buildUtilityButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20, color: colorScheme.secondary),
      label: Text(
        label,
        style: TextStyle(color: colorScheme.secondary),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
