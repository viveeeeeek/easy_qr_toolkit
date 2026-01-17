import 'package:flutter/material.dart';

class ScannerOverlay extends StatelessWidget {
  const ScannerOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.6),
            Colors.black.withOpacity(0.3),
            Colors.black.withOpacity(0.1),
            Colors.transparent,
          ],
        ),
      ),
      height: 150, // Increased height for a smoother fade
      width: double.infinity,
    );
  }
}
