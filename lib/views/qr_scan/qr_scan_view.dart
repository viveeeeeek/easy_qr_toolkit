import 'dart:developer';

import 'package:easy_qr_toolkit/providers/qr_data_provider.dart';
import 'package:easy_qr_toolkit/core/utils/qr_scanner_overlay_shape.dart';
import 'package:easy_qr_toolkit/view_models/qr_scan_viewmodel.dart';
import 'package:easy_qr_toolkit/views/qr_scan/qr_result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
// import 'package:image/image.dart' as img;

import 'widgets/widgets.dart';

class QRScanView extends StatelessWidget {
  const QRScanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Consumer<QrDataProvider>(
      builder: (context, qrDataProvider, child) {
        return qrDataProvider.scannedQRData.isEmpty
            ? const QRScanner()
            : const QRResult();
      },
    ));
  }
}

class QRScanner extends StatefulWidget {
  const QRScanner({super.key});

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> with WidgetsBindingObserver {
  MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    useNewCameraSelector: true,
    returnImage: true,
  );

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
    log('controller disposed');
  }

  @override
  Widget build(BuildContext context) {
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.of(context).size.center(Offset.zero),
      width: 200,
      height: 200,
    );

    final QrScanViewmodel qrScanViewmodel = QrScanViewmodel();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Scan QR Code"),
        actions: [
          ToggleFlashlightButton(controller: controller),
          ScanGalleryImgButton(
            controller: controller,
            onBarcodeFound: () =>
                qrScanViewmodel.handleGalleryBarcode(context, controller),
          ),
        ],
        leading: IconButton(
          onPressed: () {
            if (Navigator.canPop(context)) {
              log('can pop context');
              Navigator.pop(context);
            } else {
              log('cannot pop context so pushing new route of homeview');
              Navigator.pushReplacementNamed(context, '/home');
            }
          },
          icon: const Icon(Icons.clear),
        ),
      ),
      body: Stack(
        children: [
          /// Custom QR Scanner
          CustomScanner(
            scanWindow: scanWindow,
            controller: controller,
          ),

          /// Top gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
            height: 110,
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}
