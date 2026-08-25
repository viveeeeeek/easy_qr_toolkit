import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/enums/qr_shape.dart';
import '../../core/services/qr_service.dart';
import 'generator_state.dart';

export 'generator_state.dart';

part 'generator_provider.g.dart';

// Independent function for Isolate
QrImage _generateQrIsolate(String data) {
  final qrCode = QrCode.fromData(
    data: data,
    errorCorrectLevel: QrErrorCorrectLevel.H,
  );
  return QrImage(qrCode);
}

@riverpod
class Generator extends _$Generator {
  @override
  GeneratorState build() {
    return const GeneratorState();
  }

  void updateState({
    String? data,
    QrShape? shape,
    Color? qrColor,
    File? logo,
    bool clearLogo = false,
    double? logoScale,
    QrImage? qrImageObject,
  }) {
    state = GeneratorState(
      data: data ?? state.data,
      shape: shape ?? state.shape,
      qrColor: qrColor ?? state.qrColor,
      logo: clearLogo ? null : (logo ?? state.logo),
      logoScale: logoScale ?? state.logoScale,
      qrImageObject: qrImageObject ?? state.qrImageObject,
    );
  }

  /// Called when user types new data - generates QR matrix in isolate
  Future<void> generateImage([String? overrideData]) async {
    final data = overrideData ?? state.data;
    if (data.isEmpty) return;

    // Offload Heavy Math to Isolate
    final qrImageObject = await compute(_generateQrIsolate, data);

    // Update state with calculated QR object - preview will work immediately
    state = state.copyWith(
      data: data,
      qrImageObject: qrImageObject,
    );
  }

  /// Generates the high-res export image on demand (Save/Share)
  Future<Uint8List?> ensureExportImage() async {
    // Always generate fresh based on current state to avoid stale data issues
    final qrService = ref.read(qrServiceProvider);
    return await qrService.generateFullQrImage(
      data: state.data,
      shape: state.shape,
      color: state.qrColor,
      logo: state.logo,
      logoScale: state.logoScale,
    );
  }

  void reset() {
    state = const GeneratorState();
  }
}
