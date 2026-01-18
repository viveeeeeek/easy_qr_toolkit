import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/enums/qr_shape.dart';

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
