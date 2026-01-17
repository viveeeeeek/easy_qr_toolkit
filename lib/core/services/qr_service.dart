import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:share_plus/share_plus.dart';

part 'qr_service.g.dart';

@Riverpod(keepAlive: true)
QRService qrService(QrServiceRef ref) => QRService();

class QRService {
  /// Processes a scanned Barcode to crop the QR image and extract content
  Future<({String content, Uint8List image, String type})?> processScannedBarcode(
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
    final type = barcode.type.name;

    return (
      content: barcode.rawValue!,
      image: croppedImageData,
      type: type,
    );
  }

  /// Generates QrImage object from data
  QrImage generateQrImageObject(String data) {
    final qrCode = QrCode.fromData(
      data: data,
      errorCorrectLevel: QrErrorCorrectLevel.H,
    );
    return QrImage(qrCode);
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
}
