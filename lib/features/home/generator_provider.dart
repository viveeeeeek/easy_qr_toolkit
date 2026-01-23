import 'dart:io';
import 'dart:ui';

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
  final Uint8List? generatedQrImage;
  // Cache the logical QR object to avoid main-thread re-computation in UI
  final QrImage? qrImageObject;

  const GeneratorState({
    this.data = '',
    this.shape = QrShape.smooth,
    this.qrColor = Colors.black,
    this.logo,
    this.generatedQrImage,
    this.qrImageObject,
  });

  GeneratorState copyWith({
    String? data,
    QrShape? shape,
    Color? qrColor,
    File? logo,
    bool clearLogo = false,
    Uint8List? generatedQrImage,
    QrImage? qrImageObject,
  }) {
    return GeneratorState(
      data: data ?? this.data,
      shape: shape ?? this.shape,
      qrColor: qrColor ?? this.qrColor,
      logo: clearLogo ? null : (logo ?? this.logo),
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
        listEquals(other.generatedQrImage, generatedQrImage) &&
        other.qrImageObject == qrImageObject;
  }

  @override
  int get hashCode =>
      data.hashCode ^
      shape.hashCode ^
      qrColor.hashCode ^
      logo.hashCode ^
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
    QrImage? qrImageObject,
  }) {
    state = state.copyWith(
      data: data,
      generatedQrImage: generatedQrImage,
      shape: shape,
      qrColor: qrColor,
      logo: logo,
      clearLogo: clearLogo,
      qrImageObject: qrImageObject,
    );
  }

  Future<void> generateImage([String? overrideData]) async {
    final data = overrideData ?? state.data;
    if (data.isEmpty) return;

    final qrService = ref.read(qrServiceProvider);

    // 1. Offload Heavy Math to Isolate
    // This returns the standard QrImage object (logic only, no pixels)
    final qrImageObject = await compute(_generateQrIsolate, data);

    // Initial state update with the calculated QR object
    // This allows the UI to render the PrettyQrView immediately without blocking
    updateState(data: data, qrImageObject: qrImageObject);

    // 2. Generate Full Image for Sharing/Saving (Still async but less urgent)
    final paddedQrBytes = await qrService.generateFullQrImage(
      data: data,
      shape: state.shape,
      color: state.qrColor,
      logo: state.logo,
    );

    // Race condition check: Ensure the data hasn't changed while we were generating
    if (state.data != data || paddedQrBytes == null) return;

    updateState(
      data: data,
      generatedQrImage: paddedQrBytes,
      // No need to pass qrImageObject again, it's already there
    );
  }

  void reset() {
    state = const GeneratorState();
  }
}
