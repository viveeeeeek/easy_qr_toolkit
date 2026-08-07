import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'scanner_state.freezed.dart';

@freezed
class ScannerState with _$ScannerState {
  const factory ScannerState({
    @Default('') String scannedData,
    @Default('text') String scannedType,
    Uint8List? scannedImage,
  }) = _ScannerState;
}