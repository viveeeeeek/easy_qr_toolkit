import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:easy_qr_toolkit/features/generator/generator_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:share_plus/share_plus.dart';

import '../enums/qr_shape.dart';

part 'qr_service.g.dart';

@Riverpod(keepAlive: true)
QRService qrService(QrServiceRef ref) => QRService();

class QRService {
  /// Processes a scanned Barcode to crop the QR image and extract content
  Future<({String content, Uint8List image, String type})?>
      processScannedBarcode(
    Uint8List rawImage,
    Barcode barcode,
  ) async {
    final decodedImage = img.decodeImage(rawImage);
    if (decodedImage == null || barcode.rawValue == null) return null;

    final corners = barcode.corners;
    if (corners.length != 4) return null;

    final left = corners.map((e) => e.dx).reduce(min);
    final top = corners.map((e) => e.dy).reduce(min);
    final right = corners.map((e) => e.dx).reduce(max);
    final bottom = corners.map((e) => e.dy).reduce(max);

    final width = (right - left).toInt();
    final height = (bottom - top).toInt();

    final croppedImage = img.copyCrop(
      decodedImage,
      x: left.toInt(),
      y: top.toInt(),
      width: width,
      height: height,
    );

    final croppedImageData = Uint8List.fromList(img.encodePng(croppedImage));

    // Convert BarcodeType enum to string
    // Refine the type based on content
    final type = _refineScanType(barcode.type.name, barcode.rawValue!);

    return (
      content: barcode.rawValue!,
      image: croppedImageData,
      type: type,
    );
  }

  String _refineScanType(String originalType, String content) {
    if (content.startsWith('geo:')) return 'geo';
    if (content.contains('google.com/maps') ||
        content.contains('maps.google.com') ||
        content.contains('goo.gl/maps')) {
      return 'geo';
    }

    if (content.startsWith('WIFI:')) return 'wifi';
    if (content.contains('BEGIN:VCARD')) return 'contactInfo';

    return originalType;
  }

  /// Generates QrImage object from data
  QrImage generateQrImageObject(String data) {
    final qrCode = QrCode.fromData(
      data: data,
      errorCorrectLevel: QrErrorCorrectLevel.H,
    );
    return QrImage(qrCode);
  }

  /// Generates a high-quality QR image with white padding from existing bytes
  Future<Uint8List?> generatePaddedQrImage(Uint8List qrBytes) async {
    final img.Image? decodedQr = img.decodePng(qrBytes);
    if (decodedQr == null) return null;

    // Add padding (approx 5% of size)
    const int padding = 32;
    final int totalSize = decodedQr.width + (padding * 2);

    final img.Image paddedImage =
        img.Image(width: totalSize, height: totalSize);

    // Fill background with white
    img.fill(paddedImage, color: img.ColorRgb8(255, 255, 255));

    // Draw QR in center
    img.compositeImage(paddedImage, decodedQr, dstX: padding, dstY: padding);

    return Uint8List.fromList(img.encodePng(paddedImage));
  }

  /// Shares an image
  Future<void> shareImage(Uint8List imageBytes) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/shared_qr.png').create();
      await file.writeAsBytes(imageBytes);
      await Share.shareXFiles([XFile(file.path)]);
    } catch (e) {
      debugPrint('Error sharing image: $e');
    }
  }

  /// Saves image to gallery
  Future<bool> saveToGallery(Uint8List imageBytes) async {
    final result = await SaverGallery.saveImage(
      imageBytes,
      quality: 100,
      name: 'QR_${DateTime.now().millisecondsSinceEpoch}',
      androidRelativePath: "Pictures/Easy QR Toolkit/",
      androidExistNotSave: false,
    );
    return result.isSuccess;
  }

  /// Generates a high-quality padded QR image based on shape
  Future<Uint8List?> generateFullQrImage({
    required String data,
    required QrShape shape,
    required Color color,
  }) async {
    final qrImage = generateQrImageObject(data);

    final qrImageAsBytes = await qrImage.toImageAsBytes(
      size: 512,
      format: ImageByteFormat.png,
      decoration: getDecoration(shape, color),
    );

    if (qrImageAsBytes == null) return null;

    return generatePaddedQrImage(qrImageAsBytes.buffer.asUint8List());
  }

  /// Returns the decoration based on the selected shape and color
  PrettyQrDecoration getDecoration(QrShape shape, Color color) {
    return PrettyQrDecoration(
      shape: shape == QrShape.smooth
          ? PrettyQrSmoothSymbol(
              color: color,
              roundFactor: 1.0, // Fully rounded for clear contrast
            )
          : shape == QrShape.rounded
              ? PrettyQrRoundedSymbol(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                )
              : PrettyQrSmoothSymbol(
                  color: color,
                  roundFactor: 0.0, // Perfectly sharp
                ),
    );
  }
}
