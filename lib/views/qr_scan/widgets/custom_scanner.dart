import 'package:easy_qr_toolkit/models/scan_data_model.dart';
import 'package:easy_qr_toolkit/core/services/database_service.dart';
import 'package:easy_qr_toolkit/providers/qr_data_provider.dart';
import 'package:easy_qr_toolkit/core/utils/qr_scanner_overlay_shape.dart';
import 'package:easy_qr_toolkit/view_models/qr_scan_viewmodel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:image/image.dart' as img;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

class CustomScanner extends StatelessWidget {
  const CustomScanner({
    super.key,
    required this.scanWindow,
    required this.controller,
  });

  final Rect scanWindow;
  final MobileScannerController controller;

  @override
  Widget build(BuildContext context) {
    QrScanViewmodel qrScanViewmodel = QrScanViewmodel();
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
      onDetect: (capture) {
        // final List<Barcode> barcodes = capture.barcodes;
        qrScanViewmodel.handleScannedQR(context, capture);
      },
    );
  }
}
