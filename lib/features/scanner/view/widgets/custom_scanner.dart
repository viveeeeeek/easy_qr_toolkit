import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:easy_qr_toolkit/core/utils/qr_scanner_overlay_shape.dart';

class CustomScanner extends ConsumerWidget {
  const CustomScanner({
    super.key,
    required this.scanWindow,
    required this.controller,
    required this.onDetect,
  });

  final Rect scanWindow;
  final MobileScannerController controller;
  final Function(BarcodeCapture) onDetect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MobileScanner(
      scanWindow: scanWindow,
      scanWindowUpdateThreshold: 1000,
      controller: controller,
      overlayBuilder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Stack(
            children: [
              Container(
                decoration: ShapeDecoration(
                  shape: QrScannerOverlayShape(
                    borderColor: Colors.white,
                    overlayColor: Colors.black.withOpacity(0.5),
                    borderRadius: 10,
                    borderLength: 20,
                    borderWidth: 5,
                    cutOutSize: 200,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      onDetect: onDetect,
    );
  }
}
