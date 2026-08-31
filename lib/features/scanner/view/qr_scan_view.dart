import 'package:easy_qr_toolkit/core/services/qr_service.dart';
import 'package:easy_qr_toolkit/features/scanner/provider/scanner_provider.dart';
import 'package:easy_qr_toolkit/features/scanner/view/qr_result_view.dart';
import 'package:easy_qr_toolkit/features/scanner/view/widgets/custom_scanner.dart';
import 'package:easy_qr_toolkit/features/scanner/view/widgets/scanner_app_bar.dart';
import 'package:easy_qr_toolkit/features/scanner/view/widgets/scanner_overlay.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';

class QRScanView extends ConsumerStatefulWidget {
  const QRScanView({super.key});

  @override
  ConsumerState<QRScanView> createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends ConsumerState<QRScanView> {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: [BarcodeFormat.qrCode],
    returnImage: true,
    autoZoom: true,
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _handleScanResult(Uint8List imageBytes, Barcode barcode) async {
    final result = await ref
        .read(qrServiceProvider)
        .processScannedBarcode(imageBytes, barcode);
    if (result != null) {
      await ref.read(scannerProvider.notifier).updateResult(
            content: result.content,
            image: result.image,
            type: result.type,
          );

      if (mounted) {
        // Stop the camera before navigating to save resources
        await controller.stop();
        if (!mounted) return;
        
        // Navigate to result view (state is already updated above)
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const QRResultView()),
        );
        
        if (!mounted) return;
        // When we return here, reset scanner and restart camera
        ref.read(scannerProvider.notifier).reset();
        await controller.start();
      }
    }
  }

  Future<void> _handleGalleryScan() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    final capturedBarcode = await controller.analyzeImage(image.path);
    if (capturedBarcode != null && capturedBarcode.barcodes.isNotEmpty) {
      final imageBytes = await image.readAsBytes();
      final barcode = capturedBarcode.barcodes.first;
      await _handleScanResult(imageBytes, barcode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.of(context).size.center(Offset.zero),
      width: 240,
      height: 240,
    );
    ref.watch(scannerProvider).scannedData;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: ScannerAppBar(
        controller: controller,
        onGalleryTap: _handleGalleryScan,
      ),
      body: Stack(
        children: [
          CustomScanner(
            scanWindow: scanWindow,
            controller: controller,
            onDetect: (capture) async {
              final image = capture.image;
              if (image != null && capture.barcodes.isNotEmpty) {
                final barcode = capture.barcodes.first;
                await _handleScanResult(image, barcode);
              }
            },
          ),
          const ScannerOverlay(),
        ],
      ),
    );
  }
}
