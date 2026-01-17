import 'package:easy_qr_toolkit/features/history/scan_data_model.dart';
import 'package:easy_qr_toolkit/features/history/history_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'scanner_provider.g.dart';

class ScannerState {
  final String scannedData;
  final Uint8List? scannedImage;

  const ScannerState({
    this.scannedData = '',
    this.scannedImage,
  });

  ScannerState copyWith({
    String? scannedData,
    Uint8List? scannedImage,
  }) {
    return ScannerState(
      scannedData: scannedData ?? this.scannedData,
      scannedImage: scannedImage ?? this.scannedImage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScannerState &&
        other.scannedData == scannedData &&
        listEquals(other.scannedImage, scannedImage);
  }

  @override
  int get hashCode => scannedData.hashCode ^ scannedImage.hashCode;
}

@riverpod
class Scanner extends _$Scanner {
  @override
  ScannerState build() {
    return const ScannerState();
  }

  void reset() {
    state = const ScannerState();
  }

  Future<void> updateResult({
    required String content,
    required Uint8List image,
  }) async {
    state = state.copyWith(
      scannedData: content,
      scannedImage: image,
    );

    final scanModel = ScanDataModel(
      content: content,
      image: image,
      date: DateTime.now().millisecondsSinceEpoch,
    );

    await ref.read(historyProvider.notifier).addScan(scanModel);
  }
}
