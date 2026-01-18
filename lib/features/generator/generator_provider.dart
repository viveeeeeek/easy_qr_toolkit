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

  const GeneratorState({
    this.data = '',
    this.shape = QrShape.smooth,
    this.qrColor = Colors.black,
    this.logo,
    this.generatedQrImage,
  });

  GeneratorState copyWith({
    String? data,
    QrShape? shape,
    Color? qrColor,
    File? logo,
    bool clearLogo = false,
    Uint8List? generatedQrImage,
  }) {
    return GeneratorState(
      data: data ?? this.data,
      shape: shape ?? this.shape,
      qrColor: qrColor ?? this.qrColor,
      logo: clearLogo ? null : (logo ?? this.logo),
      generatedQrImage: generatedQrImage ?? this.generatedQrImage,
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
        listEquals(other.generatedQrImage, generatedQrImage);
  }

  @override
  int get hashCode =>
      data.hashCode ^
      shape.hashCode ^
      qrColor.hashCode ^
      logo.hashCode ^
      generatedQrImage.hashCode;
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
  }) {
    state = state.copyWith(
      data: data,
      generatedQrImage: generatedQrImage,
      shape: shape,
      qrColor: qrColor,
      logo: logo,
      clearLogo: clearLogo,
    );
  }

  Future<void> generateImage([String? overrideData]) async {
    final data = overrideData ?? state.data;
    if (data.isEmpty) return;

    final qrService = ref.read(qrServiceProvider);

    // Initial state update
    updateState(data: data);

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
    );
  }

  void reset() {
    state = const GeneratorState();
  }
}
