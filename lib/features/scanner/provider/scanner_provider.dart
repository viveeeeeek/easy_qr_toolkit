import 'package:easy_qr_toolkit/features/history/scan_data_model.dart';
import 'package:easy_qr_toolkit/features/scanner/provider/scanner_state.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../history/provider/history_provider.dart';

part 'scanner_provider.g.dart';

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
    required String type,
  }) async {
    state = state.copyWith(
      scannedData: content,
      scannedType: type,
      scannedImage: image,
    );

    final scanModel = ScanDataModel(
      content: content,
      image: image,
      date: DateTime.now().millisecondsSinceEpoch,
      type: type,
    );

    await ref.read(historyProvider.notifier).addScan(scanModel);
  }
}
