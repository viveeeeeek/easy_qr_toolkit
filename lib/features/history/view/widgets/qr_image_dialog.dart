
import 'dart:typed_data';

import 'package:easy_qr_toolkit/core/theme/m3_expressive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:saver_gallery/saver_gallery.dart';

class QRImageDialog extends StatelessWidget {
  final Uint8List imageBytes;

  const QRImageDialog({super.key, required this.imageBytes});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding: const EdgeInsets.all(20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.memory(
              imageBytes,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 20),
          M3EButton.icon(
            style: M3EButtonStyle.filled,
            icon: const Icon(Icons.download_rounded),
            label: const Text('Save to Gallery'),
            onPressed: () => _saveImage(context),
          ),
        ],
      ),
    );
  }

  Future<void> _saveImage(BuildContext context) async {
    try {
      final result = await SaverGallery.saveImage(
        imageBytes,
        name: 'scan_${DateTime.now().millisecondsSinceEpoch}',
        androidExistNotSave: false,
      );
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.isSuccess ? 'Saved to Gallery' : 'Failed to save')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    }
  }
}
