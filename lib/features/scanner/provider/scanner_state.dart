import 'package:flutter/foundation.dart';

class ScannerState {
  final String scannedData;
  final String scannedType;
  final Uint8List? scannedImage;

  const ScannerState({
    this.scannedData = '',
    this.scannedType = 'text',
    this.scannedImage,
  });

  ScannerState copyWith({
    String? scannedData,
    String? scannedType,
    Uint8List? scannedImage,
  }) {
    return ScannerState(
      scannedData: scannedData ?? this.scannedData,
      scannedType: scannedType ?? this.scannedType,
      scannedImage: scannedImage ?? this.scannedImage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScannerState &&
        other.scannedData == scannedData &&
        other.scannedType == scannedType &&
        listEquals(other.scannedImage, scannedImage);
  }

  @override
  int get hashCode =>
      scannedData.hashCode ^ scannedType.hashCode ^ scannedImage.hashCode;
}