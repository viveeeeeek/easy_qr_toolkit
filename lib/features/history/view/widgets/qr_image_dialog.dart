
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:saver_gallery/saver_gallery.dart';

class QRImageDialog extends StatelessWidget {
  final Uint8List imageBytes;

  const QRImageDialog({super.key, required this.imageBytes});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(imageBytes),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FilledButton.icon(
                onPressed: () => _saveImage(context),
                icon: const Icon(Icons.download),
                label: const Text('Save'),
              ),
            ],
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
