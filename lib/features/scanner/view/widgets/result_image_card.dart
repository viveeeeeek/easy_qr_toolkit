import 'dart:typed_data';
import 'package:material_ui/material_ui.dart';

class ResultImageCard extends StatelessWidget {
  final Uint8List imageBytes;

  const ResultImageCard({super.key, required this.imageBytes});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: 140, // Reduced from 200 for a more "proof" look
          height: 140,
          child: Image(
            image: MemoryImage(imageBytes),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
