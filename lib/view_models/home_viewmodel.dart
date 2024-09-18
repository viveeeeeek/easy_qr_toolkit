import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:share_plus/share_plus.dart';
import 'package:saver_gallery/saver_gallery.dart';

class HomeViewModel {
  Future<void> shareImageAsBytes(Uint8List qrImage) async {
    try {
      // Get the temporary directory
      final tempDir = await getTemporaryDirectory();
      // Create a temporary file
      final file = await File('${tempDir.path}/shared_image.png').create();

      // Write the image bytes to the file
      await file.writeAsBytes(qrImage);
      // Share the file using share_plus
      await Share.shareXFiles([XFile(file.path)]);
    } catch (e) {
      // print('Error sharing image: $e');
    }
  }

  /// Save QR Code
  ///
  /// Save the QR code image to the gallery.
  Future<void> saveQrToGallery(Uint8List qrImageAsUint8List) async {
    // use saver_gallery to save image to gallery
    final result = await SaverGallery.saveImage(
      Uint8List.fromList(qrImageAsUint8List),
      quality: 60,
      name: DateTime.now().millisecondsSinceEpoch.toString(),
      androidRelativePath: "Pictures/Easy QR Toolkit/",
      androidExistNotSave: false,
    );
    if (result.isSuccess) {
      /// show material snackbar that image has been saved successfully
    } else {
      log('Image not saved to gallery');
    }
  }
}
