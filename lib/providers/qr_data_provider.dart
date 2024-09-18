import 'package:flutter/foundation.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

/// A class that provides data for QR codes.
///
/// This class uses the [ChangeNotifier] mixin to notify listeners when
/// the data changes.
class QrDataProvider with ChangeNotifier {
  /// The scanned QR data.
  String _scannedQRData = '';

  /// Getter for the scanned QR data.
  String get scannedQRData => _scannedQRData;

  /// Setter for the scanned QR data.
  ///
  /// Calls [notifyListeners] to inform listeners about the change.
  void setScannedQrValue(String qrData) {
    _scannedQRData = qrData;
    notifyListeners();
  }

  /// Clears the scanned QR data.
  void clearScannedQrValue() {
    _scannedQRData = '';
    notifyListeners();
  }

  /// The QR image data.
  Uint8List? _qrImage;

  /// Getter for the QR image data.
  Uint8List? get qrImage => _qrImage;

  /// Setter for the QR image data.
  void setQrImage(Uint8List qrImage) {
    _qrImage = qrImage;
    notifyListeners();
  }

  /// The generated QR code.
  String _generatedQrCode = '';

  /// Getter for the generated QR code.
  String get generatedQrCode => _generatedQrCode;

  /// Setter for the generated QR code.
  setGeneratedQrValue(String generatedQrCode) {
    _generatedQrCode = generatedQrCode;
    notifyListeners();
  }

  Uint8List? _generatedQrImage;
  Uint8List? get generatedQrImage => _generatedQrImage;
  void setGeneratedQrImage(Uint8List qrImage) {
    _generatedQrImage = qrImage;
    notifyListeners();
  }

  QrImage? _qrImageObject;
  QrImage? get qrImageObject => _qrImageObject;
  void setQrImageObject(QrImage qrImage) {
    _qrImageObject = qrImage;
    notifyListeners();
  }
}
