import 'dart:io';


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/enums/qr_shape.dart';
import '../../core/services/qr_service.dart';

part 'generator_provider.g.dart';

class GeneratorState {
  final String data;
  final QrShape shape;
  final Color qrColor;
  final File? logo;
  final double logoScale; // 0.1 to 0.3
  final Uint8List? generatedQrImage;
  // Cache the logical QR object to avoid main-thread re-computation in UI
  final QrImage? qrImageObject;

  const GeneratorState({
    this.data = '',
    this.shape = QrShape.smooth,
    this.qrColor = Colors.black,
    this.logo,
    this.logoScale = 0.2,
    this.generatedQrImage,
    this.qrImageObject,
  });

  GeneratorState copyWith({
    String? data,
    QrShape? shape,
    Color? qrColor,
    File? logo,
    bool clearLogo = false,
    double? logoScale,
    Uint8List? generatedQrImage,
    QrImage? qrImageObject,
  }) {
    return GeneratorState(
      data: data ?? this.data,
      shape: shape ?? this.shape,
      qrColor: qrColor ?? this.qrColor,
      logo: clearLogo ? null : (logo ?? this.logo),
      logoScale: logoScale ?? this.logoScale,
      generatedQrImage: generatedQrImage ?? this.generatedQrImage,
      qrImageObject: qrImageObject ?? this.qrImageObject,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GeneratorState &&
        other.data == data &&
        other.shape == shape &&
        other.qrColor == qrColor &&
        other.logo?.path == logo?.path &&
        other.logoScale == logoScale &&
        listEquals(other.generatedQrImage, generatedQrImage) &&
        other.qrImageObject == qrImageObject;
  }

  @override
  int get hashCode =>
      data.hashCode ^
      shape.hashCode ^
      qrColor.hashCode ^
      logo.hashCode ^
      logoScale.hashCode ^
      generatedQrImage.hashCode ^
      qrImageObject.hashCode;
}

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
    Uint8List? generatedQrImage,
    QrShape? shape,
    Color? qrColor,
    File? logo,
    bool clearLogo = false,
    double? logoScale,
    QrImage? qrImageObject,
  }) {
    // Check if visual properties are changing (affects export but not QR matrix)
    final isVisualChange = shape != null || qrColor != null || logo != null || clearLogo || logoScale != null;
    
    state = state.copyWith(
      data: data,
      generatedQrImage: isVisualChange ? null : generatedQrImage, // Invalidate cache on visual change
      shape: shape,
      qrColor: qrColor,
      logo: logo,
      clearLogo: clearLogo,
      logoScale: logoScale,
      qrImageObject: qrImageObject,
    );
  }

  /// Called when user types new data - generates QR matrix in isolate
  Future<void> generateImage([String? overrideData]) async {
    final data = overrideData ?? state.data;
    if (data.isEmpty) return;

    // 1. Offload Heavy Math to Isolate
    // This returns the standard QrImage object (logic only, no pixels)
    final qrImageObject = await compute(_generateQrIsolate, data);

    // Update state with calculated QR object - preview will work immediately
    state = state.copyWith(
      data: data,
      qrImageObject: qrImageObject,
      generatedQrImage: null, // Invalidate old export
    );
  }

  /// Lazily generates the high-res export image only when needed (Save/Share)
  Future<Uint8List?> ensureExportImage() async {
    // If we already have a cached export, return it
    if (state.generatedQrImage != null) {
      return state.generatedQrImage;
    }

    // Generate the export image
    final qrService = ref.read(qrServiceProvider);
    final paddedQrBytes = await qrService.generateFullQrImage(
      data: state.data,
      shape: state.shape,
      color: state.qrColor,
      logo: state.logo,
      logoScale: state.logoScale,
    );

    if (paddedQrBytes != null) {
      // Cache it for future use
      state = state.copyWith(generatedQrImage: paddedQrBytes);
    }

    return paddedQrBytes;
  }

  void reset() {
    state = const GeneratorState();
  }
}
