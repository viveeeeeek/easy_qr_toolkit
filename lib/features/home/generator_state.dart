import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import '../../core/enums/qr_shape.dart';

part 'generator_state.freezed.dart';

@freezed
class GeneratorState with _$GeneratorState {
  const factory GeneratorState({
    @Default('') String data,
    @Default(QrShape.smooth) QrShape shape,
    @Default(Colors.black) Color qrColor,
    File? logo,
    @Default(0.2) double logoScale,
    QrImage? qrImageObject,
  }) = _GeneratorState;
}
