import 'dart:typed_data';
import 'package:flutter/material.dart';

class ResultImageCard extends StatelessWidget {
  final Uint8List imageBytes;

  const ResultImageCard({super.key, required this.imageBytes});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: SizedBox(
        width: 200,
        height: 200,
        child: Image(
          image: MemoryImage(imageBytes),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
