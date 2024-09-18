import 'dart:developer';
import 'dart:math';
import 'dart:typed_data';

import 'package:easy_qr_toolkit/models/scan_data_model.dart';
import 'package:easy_qr_toolkit/core/services/database_service.dart';
import 'package:easy_qr_toolkit/providers/qr_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

class QrScanViewmodel {
  late final DatabaseService databaseService;

  QrScanViewmodel() {
    _initDB();
  }

  void _initDB() {
    databaseService = DatabaseService.instance;
  }

  /// Common method to process and save QR data
  Future<void> _processAndSaveQRData(
    BuildContext context,
    Uint8List imageBytes,
    Barcode barcode,
  ) async {
    final QrDataProvider qrDataProvider =
        Provider.of<QrDataProvider>(context, listen: false);

    // Decode the image
    img.Image? decodedImage = img.decodeImage(imageBytes);
    if (decodedImage != null) {
      // Get the corners of the detected QR code
      final List<Offset> corners = barcode.corners;
      final rawValue = barcode.rawValue;
      if (corners.length == 4) {
        // Calculate the bounding box from the corners
        final left = corners.map((e) => e.dx).reduce(min);
        final top = corners.map((e) => e.dy).reduce(min);
        final right = corners.map((e) => e.dx).reduce(max);
        final bottom = corners.map((e) => e.dy).reduce(max);

        final width = (right - left).toInt();
        final height = (bottom - top).toInt();

        // Crop the image to the bounding box
        img.Image croppedImage = img.copyCrop(
          decodedImage,
          x: left.toInt(),
          y: top.toInt(),
          width: width,
          height: height,
        );

        // Convert the cropped image back to Uint8List
        Uint8List croppedImageData =
            Uint8List.fromList(img.encodePng(croppedImage));

        // Save the scanned QR data and image inside QrDataProvider
        qrDataProvider.setScannedQrValue(rawValue!);
        qrDataProvider.setQrImage(croppedImageData);

        // Add the scanned data to the database
        databaseService.addData(ScanDataModel(
          content: qrDataProvider.scannedQRData,
          image: qrDataProvider.qrImage!,
          date: DateTime.now().millisecondsSinceEpoch,
        ));
      }
    }
  }

  /// Process scanned barcode image
  Future<void> handleScannedQR(
    BuildContext context,
    BarcodeCapture barcodes,
  ) async {
    final image = barcodes.image;
    if (image == null) {
      return;
    }

    final barcode = barcodes.barcodes.first;
    await _processAndSaveQRData(context, image, barcode);
  }

  /// Scan barcode from gallery image
  Future<void> handleGalleryBarcode(
    BuildContext context,
    MobileScannerController controller,
  ) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image == null) {
      if (context.mounted) Navigator.of(context).pop();
      return;
    }

    final BarcodeCapture? capturedBarcode = await controller.analyzeImage(
      image.path,
    );

    if (!context.mounted) {
      return;
    }

    if (capturedBarcode != null) {
      final Uint8List imageBytes = await image.readAsBytes();
      final barcode = capturedBarcode.barcodes.first;
      if (context.mounted)
        await _processAndSaveQRData(context, imageBytes, barcode);
    }
  }
}
