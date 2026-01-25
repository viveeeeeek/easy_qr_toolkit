import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Scan Gallery Image Button
///
/// Scans the image from the gallery
class ScanGalleryImgButton extends StatelessWidget {
  const ScanGalleryImgButton(
      {required this.controller, super.key, required this.onBarcodeFound});

  final MobileScannerController controller;
  final void Function() onBarcodeFound;

  @override
  Widget build(BuildContext context) {
    return IconButton(icon: const Icon(Icons.image), onPressed: onBarcodeFound);
  }
}

/// Toggle Flashlight Button
///
/// Toggles the flashlight on and off
class ToggleFlashlightButton extends StatelessWidget {
  const ToggleFlashlightButton({required this.controller, super.key});

  final MobileScannerController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, state, child) {
        if (!state.isInitialized || !state.isRunning) {
          return const SizedBox.shrink();
        }

        switch (state.torchState) {
          case TorchState.auto:
            return IconButton(
              icon: const Icon(Icons.flash_auto),
              onPressed: () async {
                await controller.toggleTorch();
              },
            );
          case TorchState.off:
            return IconButton(
              icon: const Icon(Icons.flashlight_off_rounded),
              onPressed: () async {
                await controller.toggleTorch();
              },
            );
          case TorchState.on:
            return IconButton(
              icon: const Icon(Icons.flashlight_on_rounded),
              onPressed: () async {
                await controller.toggleTorch();
              },
            );
          case TorchState.unavailable:
            return const Icon(
              Icons.no_flash,
              color: Colors.grey,
            );
        }
      },
    );
  }
}
